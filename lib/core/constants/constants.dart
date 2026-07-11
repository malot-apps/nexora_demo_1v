/// Application Constants for the Nexora IPTV Player.
/// Houses database keys, cache configuration, route mappings, and asset paths.
class AppConstants {
  // App Info
  static const String appName = 'Nexora';
  static const String appVersion = '1.4.0-RC1';

  // Shared Preferences Keys
  static const String prefPlaylistsKey = 'nexora_playlists_list';
  static const String prefThemeModeKey = 'nexora_selected_theme_mode';
  static const String prefActivePlaylistId = 'nexora_active_playlist_id';
  static const String prefFavoritesKey = 'nexora_favorite_channels';

  // Media Cache Settings
  static const int maxCacheDurationDays = 7;
  static const int networkTimeoutSeconds = 15;

  // Assets Reference Constants
  static const String logoPath = 'assets/logos/logo_main.png';
  static const String logoMonochromePath = 'assets/logos/logo_mono.png';
}
