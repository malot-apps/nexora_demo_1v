import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/epg_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/navigation/bottom_navigation.dart';
import '../about/about_page.dart';
import '../../core/constants/app_constants.dart';

/// The premium Settings page for the Nexora application.
/// Provides configuration for theme settings, autoplay, stream quality, buffer duration,
/// cache clearance, and community resource links with full SharedPreferences persistence.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Bar Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMD,
                  AppDimensions.paddingMD,
                  AppDimensions.paddingMD,
                  AppDimensions.paddingSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SETTINGS',
                      style: AppTextStyles.headlineMedium.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.black,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          "CONFIGURE YOUR STREAMING ENGINE",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space12),

              // 2. Settings Group: Player & Streaming
              _buildSectionHeader('PLAYER & STREAMING'),
              _buildSettingsCard(
                children: [
                  // Autoplay Toggle
                  _buildToggleTile(
                    icon: Icons.play_circle_outline_rounded,
                    title: 'Auto Play Stream',
                    subtitle: 'Initiate channel playback immediately on selection',
                    value: settings.autoPlay,
                    onChanged: (val) {
                      ref.read(appSettingsProvider.notifier).setAutoPlay(val);
                    },
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),

                  // Default Quality Selector
                  _buildDropdownTile<String>(
                    icon: Icons.high_quality_rounded,
                    title: 'Default Video Quality',
                    subtitle: 'Preferred streaming resolution',
                    currentValue: settings.defaultQuality,
                    items: const [
                      DropdownMenuItem(value: 'Auto', child: Text('Auto (Adaptive)')),
                      DropdownMenuItem(value: 'UHD (4K)', child: Text('UHD (4K)')),
                      DropdownMenuItem(value: 'FHD (1080p)', child: Text('FHD (1080p)')),
                      DropdownMenuItem(value: 'HD (720p)', child: Text('HD (720p)')),
                      DropdownMenuItem(value: 'SD (480p)', child: Text('SD (480p)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(appSettingsProvider.notifier).setDefaultQuality(val);
                      }
                    },
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),

                  // Buffer settings
                  _buildDropdownTile<int>(
                    icon: Icons.hourglass_empty_rounded,
                    title: 'Buffer Duration',
                    subtitle: 'Pre-cache size to prevent video stuttering',
                    currentValue: settings.bufferDuration,
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('2 Seconds (Low Latency)')),
                      DropdownMenuItem(value: 5, child: Text('5 Seconds (Balanced)')),
                      DropdownMenuItem(value: 10, child: Text('10 Seconds (Stable)')),
                      DropdownMenuItem(value: 20, child: Text('20 Seconds (High Latency)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(appSettingsProvider.notifier).setBufferDuration(val);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space16),

              // 3. Settings Group: Appearance
              _buildSectionHeader('APPEARANCE'),
              _buildSettingsCard(
                children: [
                  _buildDropdownTile<String>(
                    icon: Icons.color_lens_outlined,
                    title: 'Application Theme',
                    subtitle: 'Select the primary visual identity',
                    currentValue: settings.themeMode,
                    items: const [
                      DropdownMenuItem(value: 'dark', child: Text('Stadium Dark')),
                      DropdownMenuItem(value: 'light', child: Text('Stadium Light')),
                      DropdownMenuItem(value: 'system', child: Text('System Default')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(appSettingsProvider.notifier).setThemeMode(val);
                        _showFeedback(context, 'Theme mode updated successfully!');
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space16),

              // 4. Settings Group: Cache & Performance
              _buildSectionHeader('CACHE & PERFORMANCE'),
              _buildSettingsCard(
                children: [
                  // Clear Cache Button
                  _buildActionTile(
                    icon: Icons.cleaning_services_rounded,
                    title: 'Clear Cache',
                    subtitle: 'Remove cached EPG schedules & loaded streams',
                    actionLabel: 'CLEAR',
                    onPressed: () {
                      // Clear in-memory EPG cache
                      ref.read(epgProvider.notifier).clearCache();
                      _showFeedback(context, 'EPG schedule & stream cache cleared successfully!');
                    },
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),

                  // Reset Defaults
                  _buildActionTile(
                    icon: Icons.settings_backup_restore_rounded,
                    title: 'Reset Defaults',
                    subtitle: 'Restore Nexora to factory state configurations',
                    actionLabel: 'RESET',
                    actionColor: AppColors.error,
                    onPressed: () {
                      _showConfirmationDialog(
                        context: context,
                        title: 'Reset All Settings?',
                        message: 'Are you sure you want to revert all configurations back to factory defaults?',
                        confirmLabel: 'RESET ALL',
                        onConfirm: () async {
                          await ref.read(appSettingsProvider.notifier).resetToDefaults();
                          if (context.mounted) {
                            _showFeedback(context, 'All settings reset to defaults.');
                          }
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space16),

              // 5. Settings Group: About Section
              _buildSectionHeader('ABOUT & COMMUNITY'),
              _buildSettingsCard(
                children: [
                  // About Banner with Logo Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMD),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppDimensions.borderSmall,
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.black,
                            size: 28.0,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NEXORA IPTV PLAYER',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.black,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                'Next-gen sports entertainment and playlist decoder platform.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),

                   // App Version Info
                   _buildAboutTile(
                     icon: Icons.info_outline_rounded,
                     title: 'App Version',
                     trailingText: '${AppConstants.appVersion} (${AppConstants.releaseChannel})',
                   ),
                   const Divider(color: AppColors.borderTranslucent, height: 1.0),
 
                   // About Nexora Option
                   _buildLinkTile(
                     icon: Icons.stars_rounded,
                     title: 'About Nexora',
                     subtitle: 'Developer details, device metrics & licenses',
                     onPressed: () {
                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (context) => const AboutPage(),
                         ),
                       );
                     },
                   ),
                   const Divider(color: AppColors.borderTranslucent, height: 1.0),

                  // Telegram Link
                  _buildLinkTile(
                    icon: Icons.send_rounded,
                    title: 'Join Our Telegram Community',
                    subtitle: 't.me/nexora_iptv_official',
                    onPressed: () {
                      _showLinkRedirectFeedback(context, 't.me/nexora_iptv_official');
                    },
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),

                  // GitHub Link
                  _buildLinkTile(
                    icon: Icons.code_rounded,
                    title: 'Official GitHub Repository',
                    subtitle: 'github.com/nexora-iptv/nexora',
                    onPressed: () {
                      _showLinkRedirectFeedback(context, 'github.com/nexora-iptv/nexora');
                    },
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),

                  // Website Link
                  _buildLinkTile(
                    icon: Icons.language_rounded,
                    title: 'Nexora Web Portal',
                    subtitle: 'www.nexora.app',
                    onPressed: () {
                      _showLinkRedirectFeedback(context, 'www.nexora.app');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 100.0), // Padding to avoid clipping under the floating botnav bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 4),
    );
  }

  // Helper builder for section grouping labels
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD + 4,
        vertical: AppDimensions.paddingSM,
      ),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.muted.withOpacity(0.8),
          fontSize: 11.0,
          fontWeight: FontWeight.black,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // Wrapper card container to keep list segments unified
  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderMedium,
        border: Border.all(
          color: AppColors.borderTranslucent,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // Toggle switch row builder
  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22.0),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.2),
            inactiveThumbColor: AppColors.muted,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Dropdown list tile builder
  Widget _buildDropdownTile<T>({
    required IconData icon,
    required String title,
    required String subtitle,
    required T currentValue,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22.0),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: AppColors.borderTranslucent, width: 1.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: currentValue,
                items: items,
                onChanged: onChanged,
                dropdownColor: AppColors.surfaceVariant,
                iconEnabledColor: AppColors.primary,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Trigger Action list tile builder
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onPressed,
    Color actionColor = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: actionColor, size: 22.0),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor.withOpacity(0.15),
              foregroundColor: actionColor,
              elevation: 0,
              side: BorderSide(color: actionColor.withOpacity(0.4), width: 1.0),
              minimumSize: const Size(80.0, 36.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              actionLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: actionColor,
                fontWeight: FontWeight.black,
                fontSize: 11.5,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Static Metadata text list tile builder
  Widget _buildAboutTile({
    required IconData icon,
    required String title,
    required String trailingText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted, size: 22.0),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            trailingText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Redirect Link Action list tile builder
  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22.0),
            const SizedBox(width: AppDimensions.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted.withOpacity(0.5),
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  // Show customized action feedback snackbar
  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show customized community link redirect snackbar
  void _showLinkRedirectFeedback(BuildContext context, String destination) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Redirecting to $destination...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Dialog for safety-critical action confirmation (e.g. factory reset)
  void _showConfirmationDialog({
    required WidgetRef ref,
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.borderLarge,
            border: Border.all(
              color: AppColors.error.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 28.0,
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space12),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderTranslucent),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderSmall,
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.muted, fontSize: 11.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderSmall,
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 11.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
