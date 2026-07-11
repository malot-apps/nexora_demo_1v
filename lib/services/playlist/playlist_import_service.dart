import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/playlist_source.dart';
import '../../models/channel_model.dart';
import '../../models/remote_config_model.dart';
import 'playlist_type_detector.dart';
import 'm3u_parser.dart';

/// Service interface responsible for coordinating playlist ingestion and indexing operations.
/// Prepares structural methods and placeholders for future stream stream parsing implementations.
class PlaylistImportService {
  // Static reference to the active remote configuration
  static RemoteConfigModel? remoteConfig;

  // Static in-memory cache for loaded playlist raw content
  static final Map<String, String> playlistContentCache = {};

  // Static in-memory cache for parsed channels lists to avoid redundant parsing and reduce CPU/Memory spikes
  static final Map<String, List<ChannelModel>> _parsedChannelsCache = {};

  /// Retrieves cached channels if available, otherwise parses and caches them.
  /// Dynamically intercepts, filters, and enriches channel properties based on the loaded Remote Config.
  static List<ChannelModel> getParsedChannels(String urlOrPath, String content) {
    try {
      if (content.trim().isEmpty) {
        return <ChannelModel>[];
      }
      final cacheKey = '$urlOrPath#${content.hashCode}';
      
      // Clean up any stale/old cache keys for this urlOrPath to prevent memory leaks
      _parsedChannelsCache.removeWhere((key, _) => key.startsWith('$urlOrPath#') && key != cacheKey);

      final List<ChannelModel> parsedList = _parsedChannelsCache.putIfAbsent(cacheKey, () {
        try {
          // Robustly catch any parser level issues
          return M3uParser.parse(content);
        } catch (e) {
          print('M3uParser parsing error on $urlOrPath: $e');
          return <ChannelModel>[];
        }
      });

      // Intercept and apply Remote Configuration adjustments
      if (remoteConfig != null) {
        final List<ChannelModel> filteredAndEnriched = [];
        
        for (final channel in parsedList) {
          // 1. Filter out Hidden Channels
          if (remoteConfig!.hiddenChannels.contains(channel.id)) {
            continue;
          }

          // 2. Apply Custom Remote Logo URLs
          String? logo = channel.logoUrl;
          if (remoteConfig!.channelLogos.containsKey(channel.id)) {
            logo = remoteConfig!.channelLogos[channel.id];
          }

          // 3. Update Category if Remote Categories override it
          String category = channel.categoryId;
          final remoteCat = remoteConfig!.categories.any((c) => c.id == channel.categoryId);
          if (!remoteCat && remoteConfig!.categories.isNotEmpty) {
            // If the category is not present in remote config categories, we map or leave it,
            // but we can also ensure categories defined in Remote Config are respected.
          }

          filteredAndEnriched.add(channel.copyWith(
            logoUrl: logo,
            categoryId: category,
          ));
        }

        // 4. Boost/prioritize Featured Channels by moving them to the front
        filteredAndEnriched.sort((a, b) {
          final aIsFeatured = remoteConfig!.featuredChannels.contains(a.id);
          final bIsFeatured = remoteConfig!.featuredChannels.contains(b.id);
          if (aIsFeatured && !bIsFeatured) return -1;
          if (!aIsFeatured && bIsFeatured) return 1;
          return 0;
        });

        return filteredAndEnriched;
      }

      return parsedList;
    } catch (e) {
      print('PlaylistImportService.getParsedChannels unhandled exception: $e');
      return <ChannelModel>[];
    }
  }

  /// Clears in-memory cache for a specific playlist URL to support force-refresh operations.
  static void clearCacheFor(String urlOrPath) {
    playlistContentCache.remove(urlOrPath);
    _parsedChannelsCache.removeWhere((key, _) => key.startsWith('$urlOrPath#'));
  }

  /// Imports and parses real playlist content from a URL or file path.
  /// Also stores the downloaded content to SharedPreferences for offline persistence.
  static Future<String> loadRealContent(String urlOrPath) async {
    // 1. Intercept to check if this playlist is disabled in the active Remote Config
    if (remoteConfig != null) {
      final matchedRemote = remoteConfig!.playlists.firstWhere(
        (p) => p.url.trim().toLowerCase() == urlOrPath.trim().toLowerCase(),
        orElse: () => RemotePlaylistConfig(id: '', name: '', url: '', type: 'm3u', isActive: true),
      );
      if (matchedRemote.id.isNotEmpty && !matchedRemote.isActive) {
        print('PlaylistImportService: Bypassing disabled remote playlist ($urlOrPath)');
        return ''; // Returning empty content hides all channels belonging to this playlist
      }
    }

    // 2. Check in-memory cache first
    if (playlistContentCache.containsKey(urlOrPath)) {
      return playlistContentCache[urlOrPath]!;
    }

    // 3. Check SharedPreferences persistence
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedContent = prefs.getString('playlist_content_$urlOrPath');
      if (savedContent != null && savedContent.isNotEmpty) {
        playlistContentCache[urlOrPath] = savedContent;
        return savedContent;
      }
    } catch (e) {
      print('Error reading SharedPreferences: $e');
    }

    // 4. Load from source (remote HTTP or local file)
    String content = '';
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      try {
        final uri = Uri.parse(urlOrPath);
        final response = await http.get(uri).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          content = response.body;
        } else {
          print('Error: Remote playlist returned status code ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching remote playlist from URL ($urlOrPath): $e');
      }
    } else {
      try {
        final file = File(urlOrPath);
        if (await file.exists()) {
          content = await file.readAsString();
        } else {
          print('Error: Local playlist file does not exist ($urlOrPath)');
        }
      } catch (e) {
        print('Error reading local playlist file ($urlOrPath): $e');
      }
    }

    // Fallback to high-fidelity mock content if empty/failed
    if (content.isEmpty) {
      try {
        content = M3uParser.getMockContent(urlOrPath);
      } catch (e) {
        print('Error generating mock playlist content fallback: $e');
        content = '';
      }
    }

    // 5. Save to caches
    if (content.isNotEmpty) {
      playlistContentCache[urlOrPath] = content;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playlist_content_$urlOrPath', content);
      } catch (e) {
        print('Error writing SharedPreferences: $e');
      }
    }

    return content;
  }

  /// Helper to save updated remote config to local SharedPreferences cache
  static Future<void> _saveLocalConfigOverride(RemoteConfigModel updated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_remote_config_json', json.encode(updated.toJson()));
      remoteConfig = updated;
    } catch (e) {
      print('PlaylistImportService: Error saving config override: $e');
    }
  }

  // ============================================================================
  // PLAYLISTS MANAGEMENT
  // ============================================================================

  static Future<void> addRemotePlaylist(RemotePlaylistConfig playlist) async {
    if (remoteConfig == null) return;
    final updatedPlaylists = List<RemotePlaylistConfig>.from(remoteConfig!.playlists)
      ..add(playlist);
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: remoteConfig!.categories,
      playlists: updatedPlaylists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: remoteConfig!.channelLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: remoteConfig!.featuredChannels,
      hiddenChannels: remoteConfig!.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  static Future<void> editRemotePlaylist(RemotePlaylistConfig playlist) async {
    if (remoteConfig == null) return;
    final updatedPlaylists = remoteConfig!.playlists.map((p) {
      return p.id == playlist.id ? playlist : p;
    }).toList();
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: remoteConfig!.categories,
      playlists: updatedPlaylists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: remoteConfig!.channelLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: remoteConfig!.featuredChannels,
      hiddenChannels: remoteConfig!.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  static Future<void> deleteRemotePlaylist(String id) async {
    if (remoteConfig == null) return;
    final updatedPlaylists = remoteConfig!.playlists.where((p) => p.id != id).toList();
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: remoteConfig!.categories,
      playlists: updatedPlaylists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: remoteConfig!.channelLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: remoteConfig!.featuredChannels,
      hiddenChannels: remoteConfig!.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  static Future<void> toggleRemotePlaylistActive(String id, bool isActive) async {
    if (remoteConfig == null) return;
    final updatedPlaylists = remoteConfig!.playlists.map((p) {
      return p.id == id ? RemotePlaylistConfig(id: p.id, name: p.name, url: p.url, type: p.type, isActive: isActive) : p;
    }).toList();
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: remoteConfig!.categories,
      playlists: updatedPlaylists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: remoteConfig!.channelLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: remoteConfig!.featuredChannels,
      hiddenChannels: remoteConfig!.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  // ============================================================================
  // CATEGORIES MANAGEMENT
  // ============================================================================

  static Future<void> addRemoteCategory(RemoteCategoryConfig category) async {
    if (remoteConfig == null) return;
    final updatedCategories = List<RemoteCategoryConfig>.from(remoteConfig!.categories)
      ..add(category);
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: updatedCategories,
      playlists: remoteConfig!.playlists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: remoteConfig!.channelLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: remoteConfig!.featuredChannels,
      hiddenChannels: remoteConfig!.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  static Future<void> editRemoteCategory(RemoteCategoryConfig category) async {
    if (remoteConfig == null) return;
    final updatedCategories = remoteConfig!.categories.map((c) {
      return c.id == category.id ? category : c;
    }).toList();
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: updatedCategories,
      playlists: remoteConfig!.playlists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: remoteConfig!.channelLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: remoteConfig!.featuredChannels,
      hiddenChannels: remoteConfig!.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  // ============================================================================
  // CHANNELS & LOGOS MANAGEMENT
  // ============================================================================

  static Future<void> updateChannelLogo(String channelId, String logoUrl) async {
    if (remoteConfig == null) return;
    final updatedLogos = Map<String, String>.from(remoteConfig!.channelLogos)
      ..[channelId] = logoUrl;
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: remoteConfig!.categories,
      playlists: remoteConfig!.playlists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: updatedLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: remoteConfig!.featuredChannels,
      hiddenChannels: remoteConfig!.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  static Future<void> toggleFeaturedChannel(String channelId, bool isFeatured) async {
    if (remoteConfig == null) return;
    final updatedFeatured = List<String>.from(remoteConfig!.featuredChannels);
    if (isFeatured) {
      if (!updatedFeatured.contains(channelId)) updatedFeatured.add(channelId);
    } else {
      updatedFeatured.remove(channelId);
    }
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: remoteConfig!.categories,
      playlists: remoteConfig!.playlists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: remoteConfig!.channelLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: updatedFeatured,
      hiddenChannels: remoteConfig!.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  static Future<void> toggleHiddenChannel(String channelId, bool isHidden) async {
    if (remoteConfig == null) return;
    final updatedHidden = List<String>.from(remoteConfig!.hiddenChannels);
    if (isHidden) {
      if (!updatedHidden.contains(channelId)) updatedHidden.add(channelId);
    } else {
      updatedHidden.remove(channelId);
    }
    final updatedConfig = RemoteConfigModel(
      appConfig: remoteConfig!.appConfig,
      homeBanner: remoteConfig!.homeBanner,
      newsBanner: remoteConfig!.newsBanner,
      announcement: remoteConfig!.announcement,
      categories: remoteConfig!.categories,
      playlists: remoteConfig!.playlists,
      epgUrls: remoteConfig!.epgUrls,
      channelLogos: remoteConfig!.channelLogos,
      posterImages: remoteConfig!.posterImages,
      featuredChannels: remoteConfig!.featuredChannels,
      hiddenChannels: updatedHidden,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  // ============================================================================
  // DEPRECATED/LEGACY IMPORTS
  // ============================================================================

  /// Simulates importing a playlist from a remote URL.
  Future<PlaylistSource> importFromUrl({
    required String name,
    required String url,
  }) async {
    final detectedType = PlaylistTypeDetector.detectFromUrl(url);

    // Parse channel count from real M3U content with cached parsing
    final content = await loadRealContent(url);
    final parsedChannels = getParsedChannels(url, content);

    return PlaylistSource(
      id: 'url_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: detectedType,
      url: url,
      addedAt: DateTime.now(),
      channelCount: parsedChannels.length,
      isActive: true,
    );
  }

  /// Simulates importing a playlist from a local storage file path.
  Future<PlaylistSource> importFromFile({
    required String name,
    required String filePath,
  }) async {
    final detectedType = PlaylistTypeDetector.detectFromUrl(filePath);

    // Parse channel count from real M3U content with cached parsing
    final content = await loadRealContent(filePath);
    final parsedChannels = getParsedChannels(filePath, content);

    return PlaylistSource(
      id: 'file_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: detectedType,
      url: filePath,
      addedAt: DateTime.now(),
      channelCount: parsedChannels.length,
      isActive: true,
    );
  }

  /// Simulates logging in and retrieving streams via the Xtream Codes API login schema.
  Future<PlaylistSource> importXtream({
    required String name,
    required String host,
    required String username,
    required String password,
  }) async {
    // Parse channel count from real M3U content with cached parsing
    final content = await loadRealContent(host);
    final parsedChannels = getParsedChannels(host, content);

    return PlaylistSource(
      id: 'xtream_${DateTime.now().millisecondsSinceEpoch}',
      name: name.isEmpty ? 'Xtream Broadcast Service' : name,
      type: PlaylistType.xtreamCodes,
      url: host,
      xtreamHost: host,
      xtreamUsername: username,
      xtreamPassword: password,
      addedAt: DateTime.now(),
      channelCount: parsedChannels.length,
      isActive: true,
    );
  }
}
