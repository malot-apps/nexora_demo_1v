import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_shadows.dart';

/// A premium, highly polished animated logo widget representing the Nexora brand.
/// Certified for production release by Malot Apps (Tonmoy Mir Malot).
/// Designed with glassmorphic border rings, breathing glow shadows, and vibrant primary gradients
/// reflecting high-energy FIFA World Cup stadium vibes with premium animations.
class AppLogo extends StatefulWidget {
  /// Diameter size of the logo widget.
  final double size;

  const AppLogo({
    super.key,
    this.size = 80.0,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Build a pulsing value from 0.0 to 1.0 and back
        final double pulseValue = (math.sin(_controller.value * 2 * math.pi) + 1.0) / 2.0; // 0.0 to 1.0
        final double scale = 0.95 + (pulseValue * 0.08); // 0.95 to 1.03
        final double glowMultiplier = 0.6 + (pulseValue * 0.4); // 0.6 to 1.0

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(size * 0.05),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.12 + (pulseValue * 0.12)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35 * glowMultiplier),
                  blurRadius: 18.0 * glowMultiplier,
                  spreadRadius: 2.0 * glowMultiplier,
                ),
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.20 * (1.0 - glowMultiplier)),
                  blurRadius: 14.0 * (1.0 - glowMultiplier),
                  spreadRadius: 1.0 * (1.0 - glowMultiplier),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating outer ring gradient
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.primaryGradient,
                    ),
                  ),
                ),
                // Inner dark container masking the rotation to create a sleek outer ring
                Container(
                  margin: EdgeInsets.all(size * 0.06),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                  ),
                ),
                // Inner center play icon with premium stadium gradient background
                Container(
                  margin: EdgeInsets.all(size * 0.11),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primaryGradient,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: size * 0.46,
                      color: Colors.black, // High contrast black on bright neon gradient
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
