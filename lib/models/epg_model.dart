/// Electronic Program Guide (EPG) Model representing a scheduled program or broadcast
/// for a specific IPTV streaming channel.
class EpgModel {
  /// Unique identifier of the channel this program belongs to
  final String channelId;

  /// Title of the program (e.g. "Champions League Studio", "Evening News")
  final String title;

  /// Detailed description or synopsis of the program
  final String description;

  /// The scheduled start time of the program
  final DateTime start;

  /// The scheduled end time of the program
  final DateTime end;

  const EpgModel({
    required this.channelId,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
  });

  /// Helper getter to check if the program is currently live
  bool get isLive {
    final now = DateTime.now();
    return (now.isAfter(start) || now.isAtSameMomentAs(start)) &&
        (now.isBefore(end) || now.isAtSameMomentAs(end));
  }

  /// Helper getter returning progress of the current program as a double value between 0.0 and 1.0.
  /// If the program hasn't started yet, returns 0.0. If ended, returns 1.0.
  double get progress {
    final now = DateTime.now();
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 1.0;
    final totalDuration = end.difference(start).inMilliseconds;
    if (totalDuration <= 0) return 1.0;
    final elapsedDuration = now.difference(start).inMilliseconds;
    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  /// Factory constructor to create an EpgModel from a JSON map
  factory EpgModel.fromJson(Map<String, dynamic> json) {
    return EpgModel(
      channelId: json['channelId'] as String? ?? '',
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? '',
      start: DateTime.parse(json['start'] as String? ?? DateTime.now().toIso8601String()),
      end: DateTime.parse(json['end'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Converts the EpgModel into a JSON map for storage/serialization
  Map<String, dynamic> toJson() {
    return {
      'channelId': channelId,
      'title': title,
      'description': description,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  /// Copy constructor to facilitate simple state mutation
  EpgModel copyWith({
    String? channelId,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
  }) {
    return EpgModel(
      channelId: channelId ?? this.channelId,
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
