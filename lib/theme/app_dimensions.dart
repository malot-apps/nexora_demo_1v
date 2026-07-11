import 'package:flutter/material.dart';

/// AppDimensions contains standardized layout constants for the Nexora IPTV & Sports application.
/// It defines consistent spacing, padding, borders, and component sizes according to Material 3.
class AppDimensions {
  // Prevent instantiation of this utility class.
  const AppDimensions._();

  // ============================================================================
  // Border Radius Constants
  // ============================================================================
  
  /// Small corner radius (10.0) typically used for small tags, chips, or badge overlays.
  static const double radiusSmall = 10.0;

  /// Medium corner radius (18.0) typically used for IPTV channel cards, stream lists, or input fields.
  static const double radiusMedium = 18.0;

  /// Large corner radius (28.0) typically used for main dialogs, sheets, or highlight containers.
  static const double radiusLarge = 28.0;

  /// Reusable [BorderRadius] objects for direct usage in widgets.
  static const BorderRadius borderSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderLarge = BorderRadius.all(Radius.circular(radiusLarge));

  // ============================================================================
  // Padding Constants
  // ============================================================================
  
  /// Extra small padding (4.0) for tiny spacers or inner badge margins.
  static const double paddingXS = 4.0;

  /// Small padding (8.0) for dense listings or tight spacing constraints.
  static const double paddingSM = 8.0;

  /// Medium padding (16.0) - the default padding for standard content grids and text bounds.
  static const double paddingMD = 16.0;

  /// Large padding (24.0) for major screen margins or card content layouts.
  static const double paddingLG = 24.0;

  /// Extra large padding (32.0) for hero banners, empty screens, or top margin alignments.
  static const double paddingXL = 32.0;

  // ============================================================================
  // Spacing (Gap) Constants
  // ============================================================================
  
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // ============================================================================
  // Icon Sizes
  // ============================================================================
  
  /// Small icon size (18.0) for meta-information chips or inline icons.
  static const double iconSmall = 18.0;

  /// Medium icon size (24.0) - the default size for interactive navigation items or list actions.
  static const double iconMedium = 24.0;

  /// Large icon size (32.0) for playback controller buttons or splash indicators.
  static const double iconLarge = 32.0;

  // ============================================================================
  // Avatar Sizes
  // ============================================================================
  
  /// Small avatar size (32.0) for inline comment sections or dense app header panels.
  static const double avatarSmall = 32.0;

  /// Medium avatar size (48.0) - the standard user profile indicator size.
  static const double avatarMedium = 48.0;

  /// Large avatar size (64.0) for settings account panels or team emblem cards.
  static const double avatarLarge = 64.0;

  // ============================================================================
  // Button Heights
  // ============================================================================
  
  /// Small button height (36.0) for auxiliary controls or badge buttons.
  static const double buttonSmall = 36.0;

  /// Medium button height (48.0) for regular forms, CTA buttons, and interactive triggers.
  static const double buttonMedium = 48.0;

  /// Large button height (56.0) for major premium actions or play/pause stream controllers.
  static const double buttonLarge = 56.0;

  // ============================================================================
  // Core Platform Heights
  // ============================================================================
  
  /// Standard Material Design 3 AppBar height.
  static const double appBarHeight = 56.0;

  /// Standard Material Design 3 Bottom Navigation bar height.
  static const double bottomNavigationHeight = 80.0;
}
