import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/loading_indicator.dart';

/// A premium, immersive landing Splash Screen for the Nexora IPTV & Sports application.
/// Incorporates smooth ease-out entry animations, stadium-lit backdrop, and loading telemetry.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Initialize the dual animation parameters (Fade & Scale)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // 2. Start animation playback immediately
    _animationController.forward();

    // 3. Set a 2-second delay to proceed to the main home interface
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient stadium background illumination with center glow spotlight
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Color(0x1B00E5FF), // Extremely low-opacity brand primary spotlight
                  AppColors.background,
                ],
              ),
            ),
          ),

          // Central branding card wrapping animate widgets
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 104.0),
                  const SizedBox(height: 32.0),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 42.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    AppConstants.appSlogan,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                        width: 1.0,
                      ),
                    ),
                    child: const Text(
                      'v' + AppConstants.appVersion,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom alignment loading telemetry indicators
          const Positioned(
            bottom: 64.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingIndicator(size: 26.0, strokeWidth: 2.5),
                  SizedBox(height: 14.0),
                  Text(
                    'LOADING STREAM ENGINE...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
