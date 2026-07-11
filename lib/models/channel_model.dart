/// Channel Model representing an IPTV streaming channel, movie, or series episode.
/// Compatible with M3U playlists and Xtream Codes API metadata.
class ChannelModel {
  /// Unique identifier of the channel
  final String id;

  /// Human-readable display name of the channel
  final String name;

  /// Stream endpoint URL (HLS, RTMP, HTTP TS, MP4, etc.)
  final String streamUrl;

  /// URL of the channel logo or cover image (tvg-logo)
  final String? logoUrl;

  /// Associated category ID
  final String categoryId;

  /// Secondary description or Electronic Program Guide (EPG) id
  final String? epgId;

  /// Track if this is a favorite channel for quick access
  final bool isFavorite;

  /// Video format details or bitrate quality if known
  final String? quality;

  const ChannelModel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    required this.categoryId,
    this.epgId,
    this.isFavorite = false,
    this.quality,
  });

  /// Check if the channel has a valid, non-empty logo URL
  bool get hasLogo => logoUrl != null && logoUrl!.trim().isNotEmpty;

  /// Check if this channel stream uses the HLS (HTTP Live Streaming) format
  bool get isHlsStream => streamUrl.toLowerCase().contains('.m3u8');

  /// Check if this channel stream uses the MPEG-TS container format
  bool get isTsStream => streamUrl.toLowerCase().contains('.ts');


  /// Factory constructor to create a ChannelModel from JSON
  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Channel',
      streamUrl: json['streamUrl'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      categoryId: json['categoryId'] as String? ?? '',
      epgId: json['epgId'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      quality: json['quality'] as String?,
    );
  }

  /// Converts ChannelModel to a JSON map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'categoryId': categoryId,
      'epgId': epgId,
      'isFavorite': isFavorite,
      'quality': quality,
    };
  }

  /// Copy constructor to facilitate simple state mutation
  ChannelModel copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? categoryId,
    String? epgId,
    bool? isFavorite,
    String? quality,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      categoryId: categoryId ?? this.categoryId,
      epgId: epgId ?? this.epgId,
      isFavorite: isFavorite ?? this.isFavorite,
      quality: quality ?? this.quality,
    );
  }
}
