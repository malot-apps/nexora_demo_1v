import 'package:flutter/material.dart';

/// Centralized premium color constants for the Nexora IPTV & Sports application.
/// Inspired by the FIFA World Cup 2026 aesthetics and high-end streaming platforms.
class AppColors {
  // Prevent instantiation of this utility class.
  const AppColors._();

  /// Primary color constant used throughout the application (Neon Cyan).
  static const Color primary = Color(0xFF00E5FF);

  /// Secondary color (Electric blue accent).
  static const Color secondary = Color(0xFF2979FF);

  /// Tertiary color (Active Stadium Green).
  static const Color tertiary = Color(0xFF00E676);

  /// Deep cinematic pitch-dark background.
  static const Color background = Color(0xFF0F0F12);

  /// High-end slate/charcoal surface color.
  static const Color surface = Color(0xFF1E1E24);

  /// Elevated surface variant.
  static const Color surfaceVariant = Color(0xFF282830);

  /// High-contrast on-background and on-surface text (Near White).
  static const Color onSurface = Color(0xFFECEFF1);

  /// Muted grey/blue helper for sub-headings, details, and inactive states.
  static const Color muted = Color(0xFF90A4AE);

  /// Translucent white for borders and frosted glass effects.
  static const Color borderTranslucent = Color(0x1AFFFFFF);

  /// Vibrant error color (neon rose/red).
  static const Color error = Color(0xFFFF1744);
}
