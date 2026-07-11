import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';
import '../models/category_model.dart';
import '../services/api/api_service.dart';
import '../services/storage/storage_service.dart';
import '../services/playlist/m3u_parser.dart';
import '../services/playlist/playlist_import_service.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// Provider for the API interface.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Provider for local SharedPreferences storage database.
/// Must be overridden in main.dart during app bootstrap using pre-initialized values.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in main.dart with a real instance');
});

// ============================================================================
// REPOSITORIES & STATES PROVIDERS (Riverpod)
// ============================================================================

/// StateNotifier handling the active list of IPTV playlists.
class PlaylistsNotifier extends StateNotifier<List<PlaylistModel>> {
  final StorageService _storageService;

  PlaylistsNotifier(this._storageService) : super([]) {
    _loadPlaylists();
    // Defer loading real playlist contents until after the first frame to optimize startup speed
    Future.microtask(() {
      _loadRealPlaylistContents();
    });
  }

  void _loadPlaylists() {
    try {
      final loaded = _storageService.loadPlaylists();
      if (loaded.isEmpty) {
        // Pre-populate with beautiful, premium default IPTV playlist sources on initial boot
        final defaultPlaylists = [
          PlaylistModel(
            id: '1',
            name: 'FIFA World Cup 2026 Broadcasts (UHD)',
            sourceUrl: 'https://cdn.nexora.sports/fifa2026/live_feeds.m3u8',
            type: PlaylistType.m3u,
            lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
            channelCount: 4,
          ),
          PlaylistModel(
            id: '2',
            name: 'Nexora Stadium Sports VIP Access',
            sourceUrl: 'http://vip.nexora-iptv.club:8080',
            type: PlaylistType.xtream,
            lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
            channelCount: 3,
          ),
          PlaylistModel(
            id: '3',
            name: 'Europe Football Leagues HD Feed',
            sourceUrl: 'https://streams.eurofooty.net/premium_channels.m3u',
            type: PlaylistType.m3u,
            lastUpdated: DateTime.now().subtract(const Duration(days: 12)),
            channelCount: 4,
          ),
        ];
        state = defaultPlaylists;
        try {
          _storageService.savePlaylists(defaultPlaylists);
        } catch (e) {
          print('PlaylistsNotifier: Error saving initial playlists: $e');
        }
      } else {
        state = loaded;
      }
    } catch (e) {
      print('PlaylistsNotifier: Error loading playlists: $e');
      state = [];
    }
  }

  Future<void> _loadRealPlaylistContents() async {
    try {
      bool updatedAny = false;
      bool cacheUpdated = false;
      final updatedPlaylists = <PlaylistModel>[];

      for (final playlist in state) {
        try {
          final oldContent = PlaylistImportService.playlistContentCache[playlist.sourceUrl];
          final content = await PlaylistImportService.loadRealContent(playlist.sourceUrl);
          
          if (oldContent != content) {
            cacheUpdated = true;
          }

          final parsedChannels = PlaylistImportService.getParsedChannels(playlist.sourceUrl, content);
          
          if (playlist.channelCount != parsedChannels.length) {
            updatedPlaylists.add(playlist.copyWith(channelCount: parsedChannels.length));
            updatedAny = true;
          } else {
            updatedPlaylists.add(playlist);
          }
        } catch (e) {
          print('Error loading playlist content for ${playlist.name}: $e');
          updatedPlaylists.add(playlist);
        }
      }

      if (updatedAny) {
        state = updatedPlaylists;
        try {
          await _storageService.savePlaylists(updatedPlaylists);
        } catch (e) {
          print('PlaylistsNotifier: Error saving updated channel counts: $e');
        }
      } else if (cacheUpdated) {
        // Re-trigger notification only if the cached content has actually updated
        state = [...state];
      }
    } catch (e) {
      print('PlaylistsNotifier: Error in _loadRealPlaylistContents: $e');
    }
  }

  Future<void> addPlaylist(PlaylistModel playlist) async {
    try {
      // Prevent duplicate imports based on the trimmed, lowercased source URL
      final isDuplicate = state.any((p) => p.sourceUrl.trim().toLowerCase() == playlist.sourceUrl.trim().toLowerCase());
      if (isDuplicate) {
        print('PlaylistsNotifier: Skipping duplicate playlist import for URL: ${playlist.sourceUrl}');
        return;
      }

      int realCount = playlist.channelCount;
      try {
        final content = await PlaylistImportService.loadRealContent(playlist.sourceUrl);
        final parsedChannels = PlaylistImportService.getParsedChannels(playlist.sourceUrl, content);
        realCount = parsedChannels.length;
      } catch (e) {
        print('Error loading imported playlist content: $e');
      }

      final updatedPlaylist = playlist.copyWith(channelCount: realCount);
      final updated = [...state, updatedPlaylist];
      state = updated;
      try {
        await _storageService.savePlaylists(updated);
      } catch (e) {
        print('PlaylistsNotifier: Error saving new playlist: $e');
      }
    } catch (e) {
      print('PlaylistsNotifier: Error in addPlaylist: $e');
    }
  }

  Future<void> removePlaylist(String id) async {
    try {
      final updated = state.where((p) => p.id != id).toList();
      state = updated;
      try {
        await _storageService.savePlaylists(updated);
      } catch (e) {
        print('PlaylistsNotifier: Error removing playlist: $e');
      }
    } catch (e) {
      print('PlaylistsNotifier: Error in removePlaylist: $e');
    }
  }
}

/// Riverpod provider for the Playlists state list.
final playlistsProvider = StateNotifierProvider<PlaylistsNotifier, List<PlaylistModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PlaylistsNotifier(storage);
});

// ============================================================================
// FAVORITES STATE MANAGEMENT (Riverpod)
// ============================================================================

class FavoritesNotifier extends StateNotifier<List<String>> {
  final StorageService _storageService;

  FavoritesNotifier(this._storageService) : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = _storageService.getFavorites();
  }

  Future<void> toggleFavorite(String channelId) async {
    final isFav = state.contains(channelId);
    final updated = List<String>.from(state);
    if (isFav) {
      updated.remove(channelId);
    } else {
      updated.add(channelId);
    }
    state = updated;
    await _storageService.toggleFavoriteChannel(channelId, !isFav);
  }
}

/// Riverpod provider for the Favorites list.
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FavoritesNotifier(storage);
});

// ============================================================================
// ACTIVE STREAM STATE MANAGEMENT
// ============================================================================

/// Keeps track of the selected category filter ID.
final selectedCategoryIdProvider = StateProvider<String>((ref) => 'all');

/// Keeps track of the channel model currently playing.
final activeChannelProvider = StateProvider<ChannelModel?>((ref) => null);

/// Keeps track of the search query input.
final searchQueryProvider = StateProvider<String>((ref) => '');

// ============================================================================
// PARSED CHANNELS & CATEGORIES FROM IMPORTS
// ============================================================================

/// Provider aggregating all raw (unfavorited) channels across all active playlists.
/// This prevents rebuilding other dependent providers when only the favorites list updates.
final rawChannelsProvider = Provider<List<ChannelModel>>((ref) {
  try {
    final playlists = ref.watch(playlistsProvider);
    final List<ChannelModel> allChannels = [];

    for (final playlist in playlists) {
      try {
        // 1. Fetch real content from our static cache
        String? content = PlaylistImportService.playlistContentCache[playlist.sourceUrl];
        if (content == null || content.isEmpty) {
          // Fallback: If not loaded yet, use mock content as a placeholder
          content = M3uParser.getMockContent(playlist.sourceUrl);
        }
        // Retrieve cached parsed channel models instead of redundant parsing
        final parsed = PlaylistImportService.getParsedChannels(playlist.sourceUrl, content);
        allChannels.addAll(parsed);
      } catch (e) {
        print('Error processing playlist ${playlist.name} in rawChannelsProvider: $e');
      }
    }

    // Fallback to pre-configured defaults if no channels parsed/active
    if (allChannels.isEmpty) {
      allChannels.addAll(_defaultChannels);
    }

    return allChannels;
  } catch (e) {
    print('Critical error in rawChannelsProvider: $e');
    return _defaultChannels;
  }
});

/// Provider aggregating all parsed channels across all active playlists.
final parsedChannelsProvider = Provider<List<ChannelModel>>((ref) {
  try {
    final rawChannels = ref.watch(rawChannelsProvider);
    final favoriteIds = ref.watch(favoritesProvider);

    // Set the favorite flag dynamically from favoritesProvider
    return rawChannels.map((ch) {
      try {
        return ch.copyWith(isFavorite: favoriteIds.contains(ch.id));
      } catch (e) {
        return ch;
      }
    }).toList();
  } catch (e) {
    print('Critical error in parsedChannelsProvider: $e');
    return [];
  }
});

/// Provider aggregating all unique categories with counts from parsed channels.
/// Watches [rawChannelsProvider] instead of [parsedChannelsProvider] to avoid
/// redundant, CPU-heavy category extractions when favorites are toggled.
final parsedCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  try {
    final channels = ref.watch(rawChannelsProvider);
    final categories = M3uParser.extractCategories(channels);

    // Return list prepended with 'All Channels' category
    final List<CategoryModel> completeCategories = [
      CategoryModel(id: 'all', name: 'All Channels', channelCount: channels.length, type: 'live'),
      ...categories,
    ];

    return completeCategories;
  } catch (e) {
    print('Critical error in parsedCategoriesProvider: $e');
    return [
      CategoryModel(id: 'all', name: 'All Channels', channelCount: 0, type: 'live'),
    ];
  }
});

// ============================================================================
// DEFAULT FALLBACK MOCK CHANNELS
// ============================================================================

const List<ChannelModel> _defaultChannels = [
  ChannelModel(
    id: 'sky_sports',
    name: 'Sky Sports Premier League',
    streamUrl: 'https://demo.unified-streaming.com/k8s/live/stable/sintel.smil/.m3u8',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/36/Sky_Sports_logo_2020.svg',
    categoryId: 'sports',
    quality: 'FHD',
  ),
  ChannelModel(
    id: 'bein_sports',
    name: 'beIN Sports 1 HD',
    streamUrl: 'https://playertest.longtailvideo.com/adaptive/bipbop/bipbop.m3u8',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e8/BeIN_Sports_logo.svg',
    categoryId: 'sports',
    quality: 'HD',
  ),
  ChannelModel(
    id: 'bbc_news',
    name: 'BBC News Live',
    streamUrl: 'http://sample.vodobox.com/planete_m3u8/planete.m3u8',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/62/BBC_News_2019.svg',
    categoryId: 'news',
    quality: 'SD',
  ),
  ChannelModel(
    id: 'espn_usa',
    name: 'ESPN USA HD',
    streamUrl: 'https://demo.unified-streaming.com/k8s/live/stable/sintel.smil/.m3u8',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2f/ESPN_wordmark.svg',
    categoryId: 'sports',
    quality: '1080p',
  ),
  ChannelModel(
    id: 'cnn_int',
    name: 'CNN International',
    streamUrl: 'https://playertest.longtailvideo.com/adaptive/bipbop/bipbop.m3u8',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/b1/CNN.svg',
    categoryId: 'news',
    quality: '720p',
  ),
  ChannelModel(
    id: 'hbo_cinema',
    name: 'HBO Cinema HD',
    streamUrl: 'http://sample.vodobox.com/planete_m3u8/planete.m3u8',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/de/HBO_logo.svg',
    categoryId: 'movies',
    quality: 'UHD',
  ),
  ChannelModel(
    id: 'action_prem',
    name: 'Action Premium',
    streamUrl: 'http://sample.vodobox.com/planete_m3u8/planete.m3u8',
    categoryId: 'movies',
    quality: '1080p',
  ),
  ChannelModel(
    id: 'comedy_central',
    name: 'Comedy Central Live',
    streamUrl: 'https://demo.unified-streaming.com/k8s/live/stable/sintel.smil/.m3u8',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Comedy_Central_2018.svg',
    categoryId: 'entertainment',
    quality: 'FHD',
  ),
  ChannelModel(
    id: 'nat_geo',
    name: 'National Geographic',
    streamUrl: 'https://playertest.longtailvideo.com/adaptive/bipbop/bipbop.m3u8',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/cb/National_Geographic_logo_and_wordmark.svg',
    categoryId: 'documentaries',
    quality: 'HD',
  ),
];
