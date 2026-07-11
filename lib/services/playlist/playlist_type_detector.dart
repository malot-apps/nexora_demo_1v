import '../../models/playlist_source.dart';

/// Detector for identifying IPTV playlist formats, stream types, and login schemas.
/// Maps media URLs and configurations to standard [PlaylistType] values.
class PlaylistTypeDetector {
  /// Detects the playlist type based on URL path or file extensions.
  static PlaylistType detectFromUrl(String url) {
    final cleanUrl = url.trim().toLowerCase();

    // 1. Detect M3U playlists
    if (cleanUrl.contains('.m3u') && !cleanUrl.contains('.m3u8')) {
      return PlaylistType.m3uUrl;
    }

    // 2. Detect M3U8 (HLS Live Streams)
    if (cleanUrl.contains('.m3u8')) {
      return PlaylistType.m3u8Url;
    }

    // 3. Detect MPEG-TS Live Video stream
    if (cleanUrl.contains('.ts')) {
      return PlaylistType.tsUrl;
    }

    // 4. Detect PHP scripts that render streams dynamically
    if (cleanUrl.contains('.php')) {
      return PlaylistType.phpUrl;
    }

    // 5. Detect MP4 physical video assets
    if (cleanUrl.contains('.mp4')) {
      return PlaylistType.mp4Url;
    }

    // Default fallback to M3U URL standard
    return PlaylistType.m3uUrl;
  }

  /// Detects the playlist type based on server credentials.
  static PlaylistType detectFromCredentials({
    required String host,
    required String username,
    required String password,
  }) {
    if (host.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      return PlaylistType.xtreamCodes;
    }
    return PlaylistType.m3uUrl;
  }
}
