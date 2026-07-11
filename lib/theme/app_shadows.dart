import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Standardized shadows and glows for the Nexora IPTV & Sports application.
/// Provides depth, glassmorphic highlights, and ambient illumination on active states.
class AppShadows {
  // Prevent instantiation of this utility class.
  const AppShadows._();

  /// Elegant subtle shadow to elevate list and playlist cards.
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.35),
    offset: const Offset(0, 4),
    blurRadius: 12.0,
    spreadRadius: 1.0,
  );

  /// Low-opacity frosted glass ambient glow.
  static final BoxShadow glassShadow = BoxShadow(
    color: Colors.white.withOpacity(0.04),
    offset: const Offset(0, -2),
    blurRadius: 8.0,
    spreadRadius: 0.0,
  );

  /// Futuristic ambient glow matching the neon primary brand accent.
  static final BoxShadow glowShadow = BoxShadow(
    color: AppColors.primary.withOpacity(0.25),
    offset: const Offset(0, 0),
    blurRadius: 16.0,
    spreadRadius: 2.0,
  );

  /// Active elevated button pressure shadow.
  static final BoxShadow buttonShadow = BoxShadow(
    color: AppColors.secondary.withOpacity(0.2),
    offset: const Offset(0, 6),
    blurRadius: 14.0,
    spreadRadius: -2.0,
  );

  /// Pulse neon halo specifically for the active football live badges or stream tags.
  static final BoxShadow liveBadgeShadow = BoxShadow(
    color: AppColors.tertiary.withOpacity(0.4),
    offset: const Offset(0, 0),
    blurRadius: 10.0,
    spreadRadius: 1.5,
  );
}
