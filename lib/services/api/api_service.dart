import 'package:http/http.dart' as http;

/// API Service for the Nexora player.
/// Handles remote downloads of M3U playlists and makes queries to Xtream Codes portals.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches an IPTV playlist raw M3U text content from a remote URL.
  Future<String> fetchM3uPlaylist(String url) async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to fetch playlist. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }

  /// Logs into an Xtream Codes compatible server panel using raw credentials.
  Future<Map<String, dynamic>> loginXtream(String serverUrl, String username, String password) async {
    final loginEndpoint = '$serverUrl/player_api.php?username=$username&password=$password';
    try {
      final response = await _client.get(Uri.parse(loginEndpoint));
      if (response.statusCode == 200) {
        // Return parsed login credentials / streams data
        return {}; 
      } else {
        throw Exception('Xtream Auth failed: Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Xtream Login network error: $e');
    }
  }
}
