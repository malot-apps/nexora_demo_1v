/// Validator class for verifying IPTV playlist links and credentials.
/// Formulates clear, localized, user-facing validation errors for input controls.
class PlaylistValidator {
  // Prevent instantiation of this utility class.
  const PlaylistValidator._();

  /// Validates a playlist stream URL against standards.
  /// Returns null if valid, or a readable error message if invalid.
  static String? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return 'The playlist or stream URL cannot be empty.';
    }

    final trimmedUrl = url.trim();

    // Verify correct HTTP/HTTPS protocol
    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      return 'Invalid protocol. URL must begin with http:// or https://';
    }

    // Basic URL pattern matching
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?.*$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(trimmedUrl)) {
      return 'Invalid URL format. Please check the address structure.';
    }

    // Supported playlist formats warning check (Optional warning check, but valid format)
    final path = trimmedUrl.toLowerCase();
    final isSupported = path.contains('.m3u') ||
        path.contains('.m3u8') ||
        path.contains('.ts') ||
        path.contains('.php') ||
        path.contains('.mp4') ||
        path.contains('/get.php') || // Common Xtream Codes stream endpoint
        path.contains('/live/');     // Common Xtream Live channel endpoint

    if (!isSupported) {
      // We don't block saving but we warn the user or provide a flexible validation
      return null;
    }

    return null;
  }

  /// Validates a customized text field to ensure it is not empty.
  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is a required field and cannot be empty.';
    }
    return null;
  }

  /// Validates Xtream Codes server host address.
  static String? validateXtreamHost(String? host) {
    if (host == null || host.trim().isEmpty) {
      return 'Xtream Server Host is required.';
    }
    
    final trimmedHost = host.trim();
    if (!trimmedHost.startsWith('http://') && !trimmedHost.startsWith('https://')) {
      return 'Host must begin with http:// or https:// (including port if needed).';
    }

    return null;
  }
}
