import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_logo.dart';

/// A premium, highly polished About Screen for Nexora.
/// Showcases branding, developer identity (Tonmoy Mir Malot / Malot Apps),
/// app versioning, device context, and open-source licenses.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation == Orientation.portrait ? 'Portrait' : 'Landscape';
    final screenSize = '${mediaQuery.size.width.toInt()} x ${mediaQuery.size.height.toInt()}';
    final devicePixelRatio = mediaQuery.devicePixelRatio.toStringAsFixed(1);
    final locale = Localizations.localeOf(context).toString();

    // Determine Platform OS name safely
    String osName = 'Android';
    try {
      if (Platform.isAndroid) osName = 'Android';
      else if (Platform.isIOS) osName = 'iOS';
      else if (Platform.isMacOS) osName = 'macOS';
      else if (Platform.isWindows) osName = 'Windows';
      else if (Platform.isLinux) osName = 'Linux';
    } catch (_) {
      osName = 'Web/Unknown';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'ABOUT NEXORA',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.black,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD, vertical: AppDimensions.paddingSM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.space16),
              
              // 1. Premium Brand Header
              const AppLogo(size: 96.0),
              const SizedBox(height: AppDimensions.space16),
              Text(
                AppConstants.appName,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.black,
                  letterSpacing: 2.0,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                AppConstants.appSlogan.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space32),

              // 2. Developer & Studio Information Card
              _buildSectionTitle('DEVELOPER & STUDIO'),
              _buildInfoCard(
                children: [
                  _buildInfoTile(
                    icon: Icons.person_rounded,
                    title: 'Lead Developer',
                    value: AppConstants.developerName,
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.storefront_rounded,
                    title: 'Publisher Studio',
                    value: AppConstants.developerStudio,
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.copyright_rounded,
                    title: 'Copyright',
                    value: AppConstants.copyright,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),

              // 3. App Information Card
              _buildSectionTitle('APP INFORMATION'),
              _buildInfoCard(
                children: [
                  _buildInfoTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version Name',
                    value: AppConstants.appVersion,
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.developer_mode_rounded,
                    title: 'Build Number',
                    value: 'Build #${AppConstants.buildVersion}',
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.tune_rounded,
                    title: 'Release Channel',
                    value: AppConstants.releaseChannel,
                    valueColor: AppColors.primary,
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.flutter_dash_rounded,
                    title: 'Development Framework',
                    value: 'Flutter (Dart)',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),

              // 4. Device Information Card
              _buildSectionTitle('DEVICE METRICS'),
              _buildInfoCard(
                children: [
                  _buildInfoTile(
                    icon: Icons.phone_android_rounded,
                    title: 'Operating System',
                    value: osName,
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.aspect_ratio_rounded,
                    title: 'Screen Size',
                    value: screenSize,
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.texture_rounded,
                    title: 'Device Pixel Ratio',
                    value: devicePixelRatio,
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.language_rounded,
                    title: 'Locale Configuration',
                    value: locale,
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildInfoTile(
                    icon: Icons.screen_rotation_rounded,
                    title: 'Screen Orientation',
                    value: orientation,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),

              // 5. Open Source Licenses Card
              _buildSectionTitle('OPEN SOURCE LICENSES'),
              _buildInfoCard(
                children: [
                  _buildLicenseTile(
                    packageName: 'flutter_riverpod',
                    description: 'A reactive caching and state-management framework.',
                    license: 'MIT License',
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildLicenseTile(
                    packageName: 'media_kit',
                    description: 'A premium, high-performance video and audio playback engine.',
                    license: 'MIT License',
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildLicenseTile(
                    packageName: 'wakelock_plus',
                    description: 'Enables keeping the screen awake during playback sessions.',
                    license: 'Apache 2.0 / MIT',
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildLicenseTile(
                    packageName: 'go_router',
                    description: 'A declarative routing package for Flutter apps.',
                    license: 'BSD-3-Clause',
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 1.0),
                  _buildLicenseTile(
                    packageName: 'shared_preferences',
                    description: 'Wraps platform-specific persistent data storage.',
                    license: 'BSD-3-Clause',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space32),

              // Bottom Brand Note
              Text(
                'Nexora is designed for absolute high-performance sports and IPTV stream playback. Thank you for choosing Malot Apps.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.muted.withOpacity(0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build section headers
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.muted.withOpacity(0.8),
            fontWeight: FontWeight.black,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // Wrapper card container to keep list segments unified
  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
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

  // Row builder for key-value info tiles
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20.0),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? AppColors.muted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Special license list tile builder
  Widget _buildLicenseTile({
    required String packageName,
    required String description,
    required String license,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                packageName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.black,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  license,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
