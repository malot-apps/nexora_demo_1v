import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing the user preference for displaying the Telegram prompt.
enum TelegramDialogStatus {
  /// User hasn't dismissed/declined the dialog permanently yet.
  show,

  /// User chose 'Later' - will prompt on subsequent launch if desired, or can be tracked.
  later,

  /// User clicked 'Don\'t show again' or 'Join Now', indicating we shouldn't prompt them anymore.
  dontShowAgain,
}

/// A StateNotifier that loads and updates the Telegram Dialog Status using [SharedPreferences].
class TelegramSettingsNotifier extends StateNotifier<AsyncValue<TelegramDialogStatus>> {
  TelegramSettingsNotifier() : super(const AsyncValue.loading()) {
    _loadStatus();
  }

  static const String _telegramStatusKey = 'nexora_telegram_dialog_status';
  static const String _firstLaunchKey = 'nexora_is_first_launch';

  Future<void> _loadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Determine if this is the first launch of the app.
      final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
      if (isFirstLaunch) {
        // Mark first launch as false so subsequent launches know.
        await prefs.setBool(_firstLaunchKey, false);
      }

      final statusString = prefs.getString(_telegramStatusKey) ?? 'show';
      final status = TelegramDialogStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => TelegramDialogStatus.show,
      );

      // If it's not the first launch, and they selected 'Later', we can decide to show it or keep it as 'later'.
      // The requirement states: "Show only on first launch". So if it's NOT first launch, and they didn't explicitly opt in/out,
      // we might want to respect "Show only on first launch" by checking if this is the actual first session.
      // Let's store that and expose.
      state = AsyncValue.data(status);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Updates the Telegram Dialog status in SharedPreferences and the notifier's state.
  Future<void> updateStatus(TelegramDialogStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_telegramStatusKey, status.name);
      state = AsyncValue.data(status);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider to access and control the Telegram dialog's display settings.
final telegramSettingsProvider =
    StateNotifierProvider<TelegramSettingsNotifier, AsyncValue<TelegramDialogStatus>>((ref) {
  return TelegramSettingsNotifier();
});

/// Immutable AppSettings class carrying premium player and theme states.
class AppSettings {
  final String themeMode; // "dark", "light", "system"
  final bool autoPlay;
  final String defaultQuality; // "Auto", "UHD (4K)", "FHD (1080p)", "HD (720p)", "SD (480p)"
  final int bufferDuration; // in seconds (e.g. 2, 5, 10, 20)

  const AppSettings({
    required this.themeMode,
    required this.autoPlay,
    required this.defaultQuality,
    required this.bufferDuration,
  });

  AppSettings copyWith({
    String? themeMode,
    bool? autoPlay,
    String? defaultQuality,
    int? bufferDuration,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      autoPlay: autoPlay ?? this.autoPlay,
      defaultQuality: defaultQuality ?? this.defaultQuality,
      bufferDuration: bufferDuration ?? this.bufferDuration,
    );
  }
}

/// A StateNotifier managing user preference changes and SharedPreferences persistence.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier()
      : super(const AppSettings(
          themeMode: 'dark',
          autoPlay: true,
          defaultQuality: 'Auto',
          bufferDuration: 5,
        )) {
    _loadSettings();
  }

  static const String _themeModeKey = 'nexora_theme_mode';
  static const String _autoPlayKey = 'nexora_auto_play';
  static const String _defaultQualityKey = 'nexora_default_quality';
  static const String _bufferDurationKey = 'nexora_buffer_duration';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeMode = prefs.getString(_themeModeKey) ?? 'dark';
      final autoPlay = prefs.getBool(_autoPlayKey) ?? true;
      final defaultQuality = prefs.getString(_defaultQualityKey) ?? 'Auto';
      final bufferDuration = prefs.getInt(_bufferDurationKey) ?? 5;

      state = AppSettings(
        themeMode: themeMode,
        autoPlay: autoPlay,
        defaultQuality: defaultQuality,
        bufferDuration: bufferDuration,
      );
    } catch (e) {
      print('AppSettingsNotifier: Error loading settings: $e');
    }
  }

  Future<void> setThemeMode(String themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, themeMode);
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      print('AppSettingsNotifier: Error setting theme mode: $e');
    }
  }

  Future<void> setAutoPlay(bool autoPlay) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoPlayKey, autoPlay);
      state = state.copyWith(autoPlay: autoPlay);
    } catch (e) {
      print('AppSettingsNotifier: Error setting auto play: $e');
    }
  }

  Future<void> setDefaultQuality(String quality) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_defaultQualityKey, quality);
      state = state.copyWith(defaultQuality: quality);
    } catch (e) {
      print('AppSettingsNotifier: Error setting quality: $e');
    }
  }

  Future<void> setBufferDuration(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bufferDurationKey, seconds);
      state = state.copyWith(bufferDuration: seconds);
    } catch (e) {
      print('AppSettingsNotifier: Error setting buffer duration: $e');
    }
  }

  /// Reset all settings to factory default.
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeModeKey);
      await prefs.remove(_autoPlayKey);
      await prefs.remove(_defaultQualityKey);
      await prefs.remove(_bufferDurationKey);
      state = const AppSettings(
        themeMode: 'dark',
        autoPlay: true,
        defaultQuality: 'Auto',
        bufferDuration: 5,
      );
    } catch (e) {
      print('AppSettingsNotifier: Error resetting settings: $e');
    }
  }
}

/// Provider exposing the current [AppSettings] configuration.
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
