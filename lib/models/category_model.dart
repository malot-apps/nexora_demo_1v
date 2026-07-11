/// Category Model representing an IPTV channel group or list category.
/// This is used to organize channels into groups like "Sports", "News", "Movies", etc.
class CategoryModel {
  /// Unique identifier of the category (e.g., from the M3U 'group-title' tag or Xtream API)
  final String id;

  /// Human-readable title or name of the category
  final String name;

  /// Total number of channels belonging to this category (optional)
  final int channelCount;

  /// Type of category: live, movie, series, or general
  final String type;

  const CategoryModel({
    required this.id,
    required this.name,
    this.channelCount = 0,
    this.type = 'live',
  });

  /// Check if the category is configured for live sports/television streams
  bool get isLive => type == 'live';

  /// Check if the category contains video on demand (VOD) movie assets
  bool get isMovie => type == 'movie';

  /// Check if the category contains serialized TV episodes
  bool get isSeries => type == 'series';


  /// Factory constructor to create a CategoryModel from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Category',
      channelCount: json['channelCount'] as int? ?? 0,
      type: json['type'] as String? ?? 'live',
    );
  }

  /// Converts CategoryModel to a JSON map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'channelCount': channelCount,
      'type': type,
    };
  }

  /// Copy constructor to support immutability and state updates
  CategoryModel copyWith({
    String? id,
    String? name,
    int? channelCount,
    String? type,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      channelCount: channelCount ?? this.channelCount,
      type: type ?? this.type,
    );
  }
}
