import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/epg_model.dart';
import '../../models/remote_config_model.dart';
import '../playlist/playlist_import_service.dart';

/// A premium, high-performance Electronic Program Guide (EPG) service
/// for parsing and managing XMLTV broadcast data.
class EpgService {
  /// Regular expressions for robust XML parsing without external dependencies.
  static final _programmeRegExp = RegExp(
    r'<programme\s+([^>]*?)>(.*?)</programme>',
    dotAll: true,
    caseSensitive: false,
  );

  // In-memory cache for parsed EPG models
  static final Map<String, List<EpgModel>> _epgCache = {};
  
  // Timestamps tracking when each EPG source was last loaded
  static final Map<String, DateTime> _lastLoadedTimes = {};
  
  // Coalescing concurrent request futures to prevent duplicate network calls
  static final Map<String, Future<List<EpgModel>>> _pendingRequests = {};
  
  // Cache Time-To-Live (TTL) duration
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Loads XMLTV EPG data from a remote URL.
  /// Uses in-memory TTL caching, request de-duplication, and falls back to stale cache gracefully if network fails.
  /// Dynamically respects Remote Config enabled/disabled and default states.
  Future<List<EpgModel>> loadFromUrl(String url, {bool forceRefresh = false}) async {
    // 0. Check if the EPG is disabled in the active Remote Config
    final config = PlaylistImportService.remoteConfig;
    if (config != null) {
      final matchedEpg = config.epgUrls.firstWhere(
        (e) => e.url.trim().toLowerCase() == url.trim().toLowerCase(),
        orElse: () => RemoteEpgConfig(url: '', isEnabled: true, isDefault: false),
      );
      if (matchedEpg.url.isNotEmpty && !matchedEpg.isEnabled) {
        print('EpgService: Bypassing loading of disabled EPG source ($url)');
        return <EpgModel>[];
      }
    }

    final now = DateTime.now();

    // 1. Check if we have valid cached data and can reuse it without forceRefresh
    if (!forceRefresh && _epgCache.containsKey(url)) {
      final lastLoaded = _lastLoadedTimes[url];
      if (lastLoaded != null && now.difference(lastLoaded) < _cacheDuration) {
        return _epgCache[url]!;
      }
    }

    // 2. Coalesce duplicate concurrent request futures to prevent multiple network hits
    if (_pendingRequests.containsKey(url)) {
      return _pendingRequests[url]!;
    }

    final future = () async {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final epgs = loadFromString(response.body);
          _epgCache[url] = epgs;
          _lastLoadedTimes[url] = DateTime.now();
          return epgs;
        }
      } catch (e) {
        // Safely catch all networking, handshake, DNS or timeout issues
        print('EpgService: Failed to load EPG from URL: $url. Error: $e');
      } finally {
        // Clean up pending request map when completed
        _pendingRequests.remove(url);
      }

      // If network call fails but we have stale cache, return it rather than returning empty list
      if (_epgCache.containsKey(url)) {
        return _epgCache[url]!;
      }
      return <EpgModel>[];
    }();

    _pendingRequests[url] = future;
    return future;
  }

  // In-memory cache for parsed XML strings to avoid redundant CPU-heavy XML parsing
  static final Map<int, List<EpgModel>> _xmlParsedCache = {};

  /// Parses a raw XMLTV XML string into a structured list of [EpgModel] items.
  /// Extremely robust against missing attributes, invalid XML nodes, or wrong dates.
  List<EpgModel> loadFromString(String xmlContent) {
    if (xmlContent.isEmpty) return <EpgModel>[];
    
    final hash = xmlContent.hashCode;
    if (_xmlParsedCache.containsKey(hash)) {
      return _xmlParsedCache[hash]!;
    }

    // Keep the cache size bounded to prevent memory growth/leaks
    if (_xmlParsedCache.length >= 5) {
      _xmlParsedCache.remove(_xmlParsedCache.keys.first);
    }

    final List<EpgModel> epgList = [];
    try {
      final matches = _programmeRegExp.allMatches(xmlContent);
      for (final match in matches) {
        final attributes = match.group(1) ?? '';
        final children = match.group(2) ?? '';

        // Extract attributes from <programme ...> tag
        final startMatch = RegExp(r'start=["\']([^"\']*)["\']', caseSensitive: false).firstMatch(attributes);
        final stopMatch = RegExp(r'stop=["\']([^"\']*)["\']', caseSensitive: false).firstMatch(attributes);
        final channelMatch = RegExp(r'channel=["\']([^"\']*)["\']', caseSensitive: false).firstMatch(attributes);

        final startStr = startMatch?.group(1);
        final stopStr = stopMatch?.group(1);
        final channelId = channelMatch?.group(1) ?? '';

        // Safely skip if critical XMLTV information is missing
        if (channelId.isEmpty || startStr == null || stopStr == null) {
          continue;
        }

        final start = _parseXmltvDate(startStr);
        final end = _parseXmltvDate(stopStr);

        if (start == null || end == null) {
          continue;
        }

        // Extract nested element tags (<title> and <desc> / <description>)
        final titleMatch = RegExp(r'<title\s*[^>]*>(.*?)</title>', dotAll: true, caseSensitive: false).firstMatch(children);
        final descMatch = RegExp(r'<(desc|description)\s*[^>]*>(.*?)</\1>', dotAll: true, caseSensitive: false).firstMatch(children);

        final title = _stripCdataAndHtml(titleMatch?.group(1) ?? 'No Title');
        final description = _stripCdataAndHtml(descMatch?.group(2) ?? '');

        epgList.add(EpgModel(
          channelId: channelId,
          title: title,
          description: description,
          start: start,
          end: end,
        ));
      }
      _xmlParsedCache[hash] = epgList;
    } catch (e) {
      print('EpgService: Failed to parse XMLTV string. Error: $e');
    }
    return epgList;
  }

  /// Parses typical XMLTV dates which can follow:
  /// YYYYMMDDhhmmss [+-]HHMM (e.g. "20260709120000 +0000") or just "20260709120000"
  DateTime? _parseXmltvDate(String dateStr) {
    try {
      final clean = dateStr.trim();
      if (clean.length < 14) return null;

      final year = int.parse(clean.substring(0, 4));
      final month = int.parse(clean.substring(4, 6));
      final day = int.parse(clean.substring(6, 8));
      final hour = int.parse(clean.substring(8, 10));
      final minute = int.parse(clean.substring(10, 12));
      final second = int.parse(clean.substring(12, 14));

      if (clean.length > 14) {
        final offsetPart = clean.substring(14).trim();
        if (offsetPart.isNotEmpty) {
          final sign = offsetPart.substring(0, 1);
          if (sign == '+' || sign == '-') {
            final offsetHours = int.parse(offsetPart.substring(1, 3));
            final offsetMinutes = int.parse(offsetPart.substring(3, 5));
            final offsetDuration = Duration(hours: offsetHours, minutes: offsetMinutes);

            // Construct UTC DateTime, subtract/add the offset, and return in local timezone
            final utcTime = DateTime.utc(year, month, day, hour, minute, second);
            if (sign == '+') {
              return utcTime.subtract(offsetDuration).toLocal();
            } else {
              return utcTime.add(offsetDuration).toLocal();
            }
          }
        }
      }

      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  /// Strips XML CDATA wrappers and decodes common XML entity patterns.
  String _stripCdataAndHtml(String value) {
    var text = value.trim();
    if (text.startsWith('<![CDATA[') && text.endsWith(']]>')) {
      text = text.substring(9, text.length - 3).trim();
    }
    
    // Decode HTML/XML entity encodings safely
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
    return text;
  }

  // ============================================================================
  // REMOTE EPG CONFLICT & CACHE OVERRIDE SERVICES
  // ============================================================================

  static Future<void> _saveLocalConfigOverride(RemoteConfigModel updated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_remote_config_json', json.encode(updated.toJson()));
      PlaylistImportService.remoteConfig = updated;
    } catch (e) {
      print('EpgService: Error saving config override: $e');
    }
  }

  static Future<void> addRemoteEpg(RemoteEpgConfig epg) async {
    final config = PlaylistImportService.remoteConfig;
    if (config == null) return;

    // If this is set as default, clear default tag from other EPG sources
    final updatedEpgs = config.epgUrls.map((e) {
      if (epg.isDefault) {
        return RemoteEpgConfig(url: e.url, isEnabled: e.isEnabled, isDefault: false);
      }
      return e;
    }).toList();

    updatedEpgs.add(epg);

    final updatedConfig = RemoteConfigModel(
      appConfig: config.appConfig,
      homeBanner: config.homeBanner,
      newsBanner: config.newsBanner,
      announcement: config.announcement,
      categories: config.categories,
      playlists: config.playlists,
      epgUrls: updatedEpgs,
      channelLogos: config.channelLogos,
      posterImages: config.posterImages,
      featuredChannels: config.featuredChannels,
      hiddenChannels: config.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  static Future<void> toggleEpgEnabled(String url, bool isEnabled) async {
    final config = PlaylistImportService.remoteConfig;
    if (config == null) return;

    final updatedEpgs = config.epgUrls.map((e) {
      if (e.url.trim().toLowerCase() == url.trim().toLowerCase()) {
        return RemoteEpgConfig(url: e.url, isEnabled: isEnabled, isDefault: e.isDefault);
      }
      return e;
    }).toList();

    final updatedConfig = RemoteConfigModel(
      appConfig: config.appConfig,
      homeBanner: config.homeBanner,
      newsBanner: config.newsBanner,
      announcement: config.announcement,
      categories: config.categories,
      playlists: config.playlists,
      epgUrls: updatedEpgs,
      channelLogos: config.channelLogos,
      posterImages: config.posterImages,
      featuredChannels: config.featuredChannels,
      hiddenChannels: config.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }

  static Future<void> setDefaultEpg(String url) async {
    final config = PlaylistImportService.remoteConfig;
    if (config == null) return;

    final updatedEpgs = config.epgUrls.map((e) {
      final isTarget = e.url.trim().toLowerCase() == url.trim().toLowerCase();
      return RemoteEpgConfig(url: e.url, isEnabled: e.isEnabled, isDefault: isTarget);
    }).toList();

    final updatedConfig = RemoteConfigModel(
      appConfig: config.appConfig,
      homeBanner: config.homeBanner,
      newsBanner: config.newsBanner,
      announcement: config.announcement,
      categories: config.categories,
      playlists: config.playlists,
      epgUrls: updatedEpgs,
      channelLogos: config.channelLogos,
      posterImages: config.posterImages,
      featuredChannels: config.featuredChannels,
      hiddenChannels: config.hiddenChannels,
    );
    await _saveLocalConfigOverride(updatedConfig);
  }
}
