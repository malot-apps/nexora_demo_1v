/// Failure classes mapping exceptions to high-level system errors.
/// Adheres strictly to Clean Architecture design patterns.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Returned when a remote IPTV playlist network request fails.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server response error. Please try again.']);
}

/// Returned when parsing M3U files fails due to malformed file structure.
class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Unable to parse the M3U playlist. File might be corrupted.']);
}

/// Returned when there is a local cache database access error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local playlists or configurations.']);
}

/// Returned when internet access is unavailable during stream playback or playlist fetch.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No Internet connection detected. Please check your network settings.']);
}
