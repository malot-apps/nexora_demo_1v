import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Highly aesthetic and reusable text styles for the Nexora IPTV & Sports application.
/// Formulated strictly with Material 3 typography ratios and optimized for dark UI readability.
class AppTextStyles {
  // Prevent instantiation of this utility class.
  const AppTextStyles._();

  /// Large display headline style for landing pages, hero banners, or splash titles.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: Colors.white,
  );

  /// Medium display headline style for screen titles or major category section headings.
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.0,
    color: Colors.white,
  );

  /// Large title style for app bars, dialog headers, or premium card labels.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: Colors.white,
  );

  /// Medium title style for sub-headers, active list items, or settings groupings.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: Colors.white90,
  );

  /// Large body text style for primary descriptions, messages, and input values.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: Colors.white70,
  );

  /// Medium body text style for secondary metadata, descriptions, or subtitles.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.4,
    color: Colors.white60,
  );

  /// Small body text style for dense layout labels, timestamps, or system logs.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.3,
    color: Colors.white54,
  );

  /// High-contrast label text style for active buttons, status chips, or table headers.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
    color: AppColors.primary,
  );

  /// Specialized bold typography for displaying high-contrast sports match scores.
  /// Inspired by premium FIFA tournament broadcast layouts.
  static const TextStyle scoreText = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 28.0,
    fontWeight: FontWeight.extrabold,
    letterSpacing: 1.5,
    color: AppColors.primary,
  );

  /// Specialized, high-visibility, monospaced style for active live stream runtimes or soccer match timers.
  static const TextStyle matchTime = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    color: AppColors.primary,
  );
}
