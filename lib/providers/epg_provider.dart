import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/epg_model.dart';
import '../services/epg/epg_service.dart';

/// Provider for the EpgService singleton instance.
final epgServiceProvider = Provider<EpgService>((ref) {
  return EpgService();
});

/// A StateNotifier that caches loaded [EpgModel] items by parsing XMLTV strings
/// or fetching them from remote URLs.
class EpgNotifier extends StateNotifier<List<EpgModel>> {
  final EpgService _epgService;
  
  // A simple in-memory cache to record URLs that have already been loaded
  final Set<String> _loadedUrls = {};

  EpgNotifier(this._epgService) : super([]);

  /// Loads EPG data from a remote URL. If already loaded or cached,
  /// it returns immediately to optimize bandwidth.
  Future<void> loadEpgFromUrl(String url) async {
    if (_loadedUrls.contains(url)) return;
    _loadedUrls.add(url);

    try {
      final newPrograms = await _epgService.loadFromUrl(url);
      if (newPrograms.isNotEmpty) {
        state = [...state, ...newPrograms];
      }
    } catch (e) {
      _loadedUrls.remove(url);
      print('EpgNotifier: Error loading URL $url: $e');
    }
  }

  /// Appends EPG programs directly from a raw XML string.
  void loadEpgFromString(String xmlContent) {
    try {
      final parsed = _epgService.loadFromString(xmlContent);
      if (parsed.isNotEmpty) {
        state = [...state, ...parsed];
      }
    } catch (e) {
      print('EpgNotifier: Error loading XML content: $e');
    }
  }

  /// Clears the loaded EPG memory cache and resets status tracker.
  void clearCache() {
    _loadedUrls.clear();
    state = const [];
  }
}

/// Provider for the collection of parsed Electronic Program Guide (EPG) schedules.
final epgProvider = StateNotifierProvider<EpgNotifier, List<EpgModel>>((ref) {
  final service = ref.watch(epgServiceProvider);
  return EpgNotifier(service);
});

/// Family provider that retrieves the currently live EpgModel for a given channelId (tvg-id).
/// Returns null if no program matches or if no program is currently active.
final currentProgramProvider = Provider.family<EpgModel?, String>((ref, channelId) {
  final epgList = ref.watch(epgProvider);
  if (epgList.isEmpty || channelId.isEmpty) return null;

  // Find all programs matching the specified channelId (or tvg-id) case-insensitively
  final matchingPrograms = epgList.where(
    (epg) => epg.channelId.toLowerCase() == channelId.toLowerCase()
  );

  for (final program in matchingPrograms) {
    if (program.isLive) {
      return program;
    }
  }
  return null;
});

/// Family provider that retrieves the next scheduled EpgModel for a given channelId (tvg-id).
/// Returns null if no upcoming program exists.
final nextProgramProvider = Provider.family<EpgModel?, String>((ref, channelId) {
  final epgList = ref.watch(epgProvider);
  if (epgList.isEmpty || channelId.isEmpty) return null;

  // Filter programs matching the specified channelId (or tvg-id) case-insensitively
  final matchingPrograms = epgList.where(
    (epg) => epg.channelId.toLowerCase() == channelId.toLowerCase()
  ).toList();

  if (matchingPrograms.isEmpty) return null;

  // Sort programs by their scheduled start times
  matchingPrograms.sort((a, b) => a.start.compareTo(b.start));

  final now = DateTime.now();

  // Find the first scheduled program starting after the current time
  for (final program in matchingPrograms) {
    if (program.start.isAfter(now)) {
      return program;
    }
  }
  return null;
});
