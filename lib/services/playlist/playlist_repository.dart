import '../../models/playlist_source.dart';

/// Contract definition for managing playlist sources following clean architecture rules.
abstract class PlaylistRepository {
  /// Retrieves all loaded playlist sources from database or memory.
  Future<List<PlaylistSource>> getAllPlaylists();

  /// Persists a new or updated playlist source.
  Future<void> savePlaylist(PlaylistSource source);

  /// Deletes a loaded playlist source by its unique ID.
  Future<void> deletePlaylist(String id);

  /// Toggles the active status state of a loaded playlist source.
  Future<void> togglePlaylistActive(String id, bool isActive);
}

/// A clean in-memory implementation of [PlaylistRepository].
/// Serves as the foundation before database integration is introduced in future sprints.
class InMemoryPlaylistRepository implements PlaylistRepository {
  final List<PlaylistSource> _playlists = [];

  InMemoryPlaylistRepository() {
    // Populate with premium default mock playlists for immediate visual polish in UI
    _playlists.addAll([
      PlaylistSource(
        id: '1',
        name: 'FIFA World Cup 2026 Broadcasts (UHD)',
        type: PlaylistType.m3u8Url,
        url: 'https://cdn.nexora.sports/fifa2026/live_feeds.m3u8',
        addedAt: DateTime.now().subtract(const Duration(days: 2)),
        channelCount: 148,
        isActive: true,
      ),
      PlaylistSource(
        id: '2',
        name: 'Nexora Stadium Sports VIP Access',
        type: PlaylistType.xtreamCodes,
        url: 'http://vip.nexora-iptv.club:8080',
        xtreamHost: 'http://vip.nexora-iptv.club:8080',
        xtreamUsername: 'worldcup_guest',
        xtreamPassword: '••••••••••••',
        addedAt: DateTime.now().subtract(const Duration(days: 5)),
        channelCount: 3840,
        isActive: true,
      ),
      PlaylistSource(
        id: '3',
        name: 'Europe Football Leagues HD Feed',
        type: PlaylistType.m3uUrl,
        url: 'https://streams.eurofooty.net/premium_channels.m3u',
        addedAt: DateTime.now().subtract(const Duration(days: 12)),
        channelCount: 65,
        isActive: false,
      ),
    ]);
  }

  @override
  Future<List<PlaylistSource>> getAllPlaylists() async {
    // Simulate lightweight disk access latency
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_playlists);
  }

  @override
  Future<void> savePlaylist(PlaylistSource source) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _playlists.indexWhere((p) => p.id == source.id);
    if (index != -1) {
      _playlists[index] = source;
    } else {
      _playlists.insert(0, source);
    }
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _playlists.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> togglePlaylistActive(String id, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(isActive: isActive);
    }
  }
}
