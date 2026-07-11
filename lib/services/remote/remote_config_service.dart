import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/remote_config_model.dart';

/// Abstract Remote Provider interface.
/// Allows swapping the underlying hosting layer (e.g. GitHub, Supabase, Firebase)
/// without changing the core repository, business logic, or UI.
abstract class RemoteConfigProvider {
  Future<Map<String, dynamic>> fetchConfigJson();
  Future<void> saveConfigJson(Map<String, dynamic> jsonMap);
}

/// GitHub concrete implementation of [RemoteConfigProvider].
/// Fetches single-source configuration JSON from a designated public/private repo url.
class GitHubProvider implements RemoteConfigProvider {
  final String configUrl;

  GitHubProvider({
    this.configUrl = 'https://raw.githubusercontent.com/tonmoymir9/nexora-config/main/config.json',
  });

  @override
  Future<Map<String, dynamic>> fetchConfigJson() async {
    try {
      final response = await http.get(Uri.parse(configUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw Exception('Invalid JSON structure: expected Map<String, dynamic>');
      }
      throw Exception('Server returned status code: ${response.statusCode}');
    } catch (e) {
      throw Exception('GitHubProvider networking error: $e');
    }
  }

  @override
  Future<void> saveConfigJson(Map<String, dynamic> jsonMap) async {
    // Future architectural implementation:
    // This will perform an authenticated PUT request to the GitHub Contents API:
    // PUT /repos/:owner/:repo/contents/:path
    // with headers: { "Authorization": "token $githubToken", "Content-Type": "application/json" }
    // body: { "message": "Update config.json via Admin Dashboard", "content": base64Encode(json.encode(jsonMap)), "sha": currentFileSha }
    print('GitHubProvider.saveConfigJson: Simulating GitHub Commit to $configUrl');
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

/// FUTURE PLUG-AND-PLAY PROVIDER:
/// Supabase concrete implementation of [RemoteConfigProvider].
/// Simply uncomment and register in [remote_provider.dart] to switch providers.
class SupabaseProvider implements RemoteConfigProvider {
  final String tableName;

  SupabaseProvider({this.tableName = 'remote_config'});

  @override
  Future<Map<String, dynamic>> fetchConfigJson() async {
    // Example: Select first record from remote_config table
    // final response = await supabaseClient.from(tableName).select().single();
    // return response as Map<String, dynamic>;
    print('SupabaseProvider: Simulating config fetching from table: $tableName');
    throw UnimplementedError('Supabase config fetching is scaffolded for future integration.');
  }

  @override
  Future<void> saveConfigJson(Map<String, dynamic> jsonMap) async {
    // Example: Update the remote_config table
    // await supabaseClient.from(tableName).update(jsonMap).eq('id', 1);
    print('SupabaseProvider: Simulating config saving to table: $tableName');
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

/// High-performance Repository orchestrating network fetching,
/// local persistence, offline caching, and graceful fallback.
class RemoteConfigRepository {
  final RemoteConfigProvider _provider;
  static const String _cacheKey = 'cached_remote_config_json';

  RemoteConfigRepository(this._provider);

  /// Load Remote Configuration.
  /// If [forceRefresh] is false, reads cached local data instantly to eliminate loading spinners,
  /// and updates the cache asynchronously in the background.
  /// If network is unavailable or fails, returns local cache, falling back to static offline defaults.
  Future<RemoteConfigModel> getRemoteConfig({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _getCachedConfig();
      if (cached != null) {
        // Auto background refresh to keep cache fresh without blocking the user
        _fetchAndCacheInBackground();
        return cached;
      }
    }

    try {
      final jsonMap = await _provider.fetchConfigJson();
      await _saveCache(jsonMap);
      return RemoteConfigModel.fromJson(jsonMap);
    } catch (e) {
      print('RemoteConfigRepository: Failed to load online config ($e). Attempting cache fallback.');
      final cached = await _getCachedConfig();
      if (cached != null) {
        return cached;
      }
      print('RemoteConfigRepository: Cache empty. Yielding hardcoded fallback configurations.');
      return RemoteConfigModel.fallback();
    }
  }

  /// Refreshes and updates cache silently in the background
  Future<void> _fetchAndCacheInBackground() async {
    try {
      final jsonMap = await _provider.fetchConfigJson();
      await _saveCache(jsonMap);
      print('RemoteConfigRepository: Background cache refresh succeeded.');
    } catch (e) {
      print('RemoteConfigRepository: Silent background refresh failed: $e');
    }
  }

  /// Retrieve cached config map from SharedPreferences
  Future<RemoteConfigModel?> _getCachedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_cacheKey);
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(cachedStr);
        return RemoteConfigModel.fromJson(decoded);
      }
    } catch (e) {
      print('RemoteConfigRepository: Cache read exception: $e');
    }
    return null;
  }

  /// Store config JSON safely into local SharedPreferences database
  Future<void> _saveCache(Map<String, dynamic> jsonMap) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(jsonMap));
    } catch (e) {
      print('RemoteConfigRepository: Cache write exception: $e');
    }
  }

  /// Push config updates to the remote provider and cache locally.
  Future<void> saveRemoteConfig(RemoteConfigModel updatedConfig) async {
    final jsonMap = updatedConfig.toJson();
    // Update local cache first
    await _saveCache(jsonMap);
    // Push to remote provider
    await _provider.saveConfigJson(jsonMap);
  }

  /// Save config locally only (for instant local previews)
  Future<void> saveConfigLocally(RemoteConfigModel updatedConfig) async {
    await _saveCache(updatedConfig.toJson());
  }
}
