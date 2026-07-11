import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/remote_config_model.dart';
import '../services/remote/remote_config_service.dart';

/// Provider for the abstract RemoteConfigProvider implementation.
/// Currently defaults to GitHubProvider.
/// Swapping to Supabase in the future requires only replacing [GitHubProvider()] with [SupabaseProvider()]
/// inside this single provider block, leaving the rest of the app untouched.
final remoteConfigProviderImpl = Provider<RemoteConfigProvider>((ref) {
  return GitHubProvider();
});

/// Provider for the RemoteConfigRepository.
final remoteConfigRepositoryProvider = Provider<RemoteConfigRepository>((ref) {
  final provider = ref.watch(remoteConfigProviderImpl);
  return RemoteConfigRepository(provider);
});

/// StateNotifier that coordinates loading, caching, automatic updates,
/// and manual refreshes of the application-wide [RemoteConfigModel].
class RemoteConfigNotifier extends StateNotifier<AsyncValue<RemoteConfigModel>> {
  final RemoteConfigRepository _repository;
  Timer? _autoRefreshTimer;

  RemoteConfigNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadConfig();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// Fetches/loads the remote configuration.
  /// Uses repository caching strategies internally.
  /// Pass [forceRefresh: true] to trigger a hard network fetch.
  Future<void> loadConfig({bool forceRefresh = false}) async {
    if (forceRefresh) {
      state = const AsyncValue.loading();
    }
    try {
      final config = await _repository.getRemoteConfig(forceRefresh: forceRefresh);
      state = AsyncValue.data(config);
    } catch (e, stack) {
      // Graceful error fallback to mock fallback model inside AsyncValue
      state = AsyncValue.data(RemoteConfigModel.fallback());
      print('RemoteConfigNotifier: Error loading config: $e. Falling back to default data.');
    }
  }

  /// Push config updates to remote provider and update the StateNotifier state immediately.
  Future<void> updateConfig(RemoteConfigModel updatedConfig) async {
    state = AsyncValue.data(updatedConfig);
    try {
      await _repository.saveRemoteConfig(updatedConfig);
    } catch (e) {
      print('RemoteConfigNotifier: Error saving config: $e');
    }
  }

  /// Update the config only locally for fast previews
  Future<void> updateConfigLocally(RemoteConfigModel updatedConfig) async {
    state = AsyncValue.data(updatedConfig);
    await _repository.saveConfigLocally(updatedConfig);
  }

  /// Sets up a standard cron-like background refresh interval
  /// to automatically fetch and apply updates silently every 10 minutes.
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      try {
        final config = await _repository.getRemoteConfig(forceRefresh: true);
        if (mounted) {
          state = AsyncValue.data(config);
          print('RemoteConfigNotifier: Auto periodic refresh synchronized successfully.');
        }
      } catch (e) {
        print('RemoteConfigNotifier: Auto periodic refresh failed: $e');
      }
    });
  }
}

/// Core application-wide provider exposing the reactive [RemoteConfigModel] state.
final remoteConfigNotifierProvider = StateNotifierProvider<RemoteConfigNotifier, AsyncValue<RemoteConfigModel>>((ref) {
  final repository = ref.watch(remoteConfigRepositoryProvider);
  return RemoteConfigNotifier(repository);
});
