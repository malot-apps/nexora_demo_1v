/// Defines supported playlist type enumeration for the Nexora IPTV player.
enum PlaylistType {
  m3uUrl,
  m3u8Url,
  tsUrl,
  phpUrl,
  mp4Url,
  xtreamCodes,
}

/// Model class representing an imported playlist stream source in Nexora.
/// This houses source configuration data and metadata, keeping the theme aligned with 
/// premium sports streaming system architectures.
class PlaylistSource {
  final String id;
  final String name;
  final PlaylistType type;
  final String url;
  
  // Xtream Codes specific parameters (optional based on type)
  final String? xtreamHost;
  final String? xtreamUsername;
  final String? xtreamPassword;

  final DateTime addedAt;
  final int channelCount;
  final bool isActive;

  const PlaylistSource({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.xtreamHost,
    this.xtreamUsername,
    this.xtreamPassword,
    required this.addedAt,
    this.channelCount = 0,
    this.isActive = true,
  });

  /// Helpful helper to get a user-friendly label for the playlist type.
  String get typeLabel {
    switch (type) {
      case PlaylistType.m3uUrl:
        return 'M3U URL';
      case PlaylistType.m3u8Url:
        return 'M3U8 (HLS) URL';
      case PlaylistType.tsUrl:
        return 'TS Stream URL';
      case PlaylistType.phpUrl:
        return 'PHP Stream Script';
      case PlaylistType.mp4Url:
        return 'MP4 Video Source';
      case PlaylistType.xtreamCodes:
        return 'Xtream Codes API';
    }
  }

  /// Copy constructor for state mutations.
  PlaylistSource copyWith({
    String? id,
    String? name,
    PlaylistType? type,
    String? url,
    String? xtreamHost,
    String? xtreamUsername,
    String? xtreamPassword,
    DateTime? addedAt,
    int? channelCount,
    bool? isActive,
  }) {
    return PlaylistSource(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      xtreamHost: xtreamHost ?? this.xtreamHost,
      xtreamUsername: xtreamUsername ?? this.xtreamUsername,
      xtreamPassword: xtreamPassword ?? this.xtreamPassword,
      addedAt: addedAt ?? this.addedAt,
      channelCount: channelCount ?? this.channelCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
