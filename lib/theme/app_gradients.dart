import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized gradients class for the Nexora application.
/// Houses highly aesthetic, luxury sports-inspired gradients modeled after
/// premium FIFA World Cup 2026 broadcast designs, cinematic layouts, and glassmorphism cards.
class AppGradients {
  // Prevent instantiation of this utility class.
  const AppGradients._();

  /// Primary linear gradient that transitions from the high-octane neon cyan
  /// to an intense, professional athletic deep blue.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      Color(0xFF0091EA), // High-intensity electric blue
      Color(0xFF0D47A1), // Deep stadium blue
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Secondary linear gradient featuring deep, luxurious cinematic slate
  /// and dark sapphire tones, perfect for content grouping banners or page backdrops.
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF1A237E), // Deep luxury indigo
      Color(0xFF121214), // Midnight black charcoal
    ],
    stops: [0.0, 1.0],
  );

  /// Live Match gradient featuring an energetic, high-visibility broadcast theme.
  /// Blends the brand primary neon cyan with active stadium green to indicate active live matches.
  static const LinearGradient liveMatchGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF00E676), // Vibrant athletic green
      AppColors.primary, // Neon cyan
    ],
  );

  /// Premium, low-contrast dark card gradient optimized for sports statistics,
  /// team lineups, and scheduling overlays. Keeps text highly legible.
  static const LinearGradient sportsCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E1E24), // Nexora custom card grey
      Color(0xFF0F0F12), // Deep stadium pitch-dark grey
    ],
  );

  /// Glassmorphism translucent overlay gradient.
  /// Mimics high-end frosted glass with subtle frosted highlights and edge depth.
  static final LinearGradient glassOverlayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.15), // Semi-transparent highlight
      Colors.white.withOpacity(0.03), // Low opacity dark blend
    ],
    stops: const [0.0, 1.0],
  );

  /// Dynamic high-impact CTA button gradient.
  /// Designed to grab the user's attention on actions like streaming channels or upgrading access.
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      Color(0xFF2979FF), // Vibrant electric blue accent
    ],
  );
}
