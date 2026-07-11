import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';
import 'app_gradients.dart';
import 'app_shadows.dart';

/// Central theme configurations for the Nexora IPTV & Sports application.
/// Formulates a complete, cohesive Material 3 Dark Theme optimized for high-end cinematic
/// layouts, fluid navigation, and FIFA World Cup 2026 sports broadcasting dynamics.
class AppTheme {
  // Prevent instantiation of this utility class.
  const AppTheme._();

  /// Customized Material 3 Dark ColorScheme.
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.black,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    tertiary: AppColors.tertiary,
    onTertiary: Colors.black,
    error: AppColors.error,
    onError: Colors.white,
    background: AppColors.background,
    onBackground: AppColors.onSurface,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurface,
    outline: AppColors.muted,
  );

  /// Compiles and returns the unified Dark [ThemeData] for the Flutter application.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: AppColors.background,

      // ------------------------------------------------------------------------
      // Typography (TextTheme)
      // ------------------------------------------------------------------------
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
      ),

      // ------------------------------------------------------------------------
      // AppBar Styling
      // ------------------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: AppDimensions.iconMedium,
        ),
        titleTextStyle: AppTextStyles.titleLarge,
      ),

      // ------------------------------------------------------------------------
      // Card Styling
      // ------------------------------------------------------------------------
      cardTheme: const CardTheme(
        color: AppColors.surface,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderMedium,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ------------------------------------------------------------------------
      // Button Themes
      // ------------------------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(AppDimensions.buttonMedium),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
          textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.black),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderSmall,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: Colors.white,
          elevation: 4.0,
          shadowColor: Colors.black45,
          minimumSize: const Size.fromHeight(AppDimensions.buttonMedium),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
          textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.white),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderSmall,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(AppDimensions.buttonMedium),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
          textStyle: AppTextStyles.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderSmall,
          ),
        ),
      ),

      // ------------------------------------------------------------------------
      // Bottom Navigation Bar Styling
      // ------------------------------------------------------------------------
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.0,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 12.0,
      ),

      // ------------------------------------------------------------------------
      // Form Input Styling
      // ------------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingMD,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSmall,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSmall,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSmall,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSmall,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
      ),

      // ------------------------------------------------------------------------
      // Divider Styling
      // ------------------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color: AppColors.borderTranslucent,
        thickness: 1.0,
        space: AppDimensions.space24,
      ),

      // ------------------------------------------------------------------------
      // Progress Indicator Styling
      // ------------------------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surface,
      ),

      // ------------------------------------------------------------------------
      // Snackbar / Toast Styling
      // ------------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderSmall,
        ),
      ),

      // ------------------------------------------------------------------------
      // Dialog / Modal Styling
      // ------------------------------------------------------------------------
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.surface,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderLarge,
        ),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
    );
  }
}
