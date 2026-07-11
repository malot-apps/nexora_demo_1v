/// Playlist Model representing an IPTV resource/playlist.
/// This can be a local/remote M3U file, or an Xtream Codes server configuration.
enum PlaylistType { m3u, xtream }

class PlaylistModel {
  /// Unique identifier of the playlist
  final String id;

  /// Custom name given by the user (e.g., "My Premium IPTV")
  final String name;

  /// The local file path or remote HTTP URL of the playlist source
  final String sourceUrl;

  /// Protocol type: m3u file or xtream codes portal
  final PlaylistType type;

  /// Timestamp of when this playlist was imported/last sync'd
  final DateTime lastUpdated;

  /// Total number of channels parsed from the playlist
  final int channelCount;

  /// Optional login credentials for Xtream Codes type
  final String? username;
  final String? password;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.sourceUrl,
    required this.type,
    required this.lastUpdated,
    this.channelCount = 0,
    this.username,
    this.password,
  });

  /// Factory constructor to create a PlaylistModel from JSON
  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Playlist',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      type: PlaylistType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PlaylistType.m3u,
      ),
      lastUpdated: DateTime.parse(
          json['lastUpdated'] as String? ?? DateTime.now().toIso8601String()),
      channelCount: json['channelCount'] as int? ?? 0,
      username: json['username'] as String?,
      password: json['password'] as String?,
    );
  }

  /// Converts PlaylistModel to a JSON map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sourceUrl': sourceUrl,
      'type': type.toString(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'channelCount': channelCount,
      'username': username,
      'password': password,
    };
  }

  /// Copy constructor
  PlaylistModel copyWith({
    String? id,
    String? name,
    String? sourceUrl,
    PlaylistType? type,
    DateTime? lastUpdated,
    int? channelCount,
    String? username,
    String? password,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      type: type ?? this.type,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      channelCount: channelCount ?? this.channelCount,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
