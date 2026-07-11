import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// A premium, highly reusable buffering overlay and progress widget.
/// Can be wrapped around any widget (e.g., video player canvas) or used standalone.
/// Shows a glassmorphic blur with a beautiful pulsing neon ring when [isBuffering] is true.
class PlayerBuffer extends StatefulWidget {
  final bool isBuffering;
  final Widget child;
  final String message;
  final double blurSigma;
  final double indicatorSize;

  const PlayerBuffer({
    super.key,
    required this.isBuffering,
    required this.child,
    this.message = 'Optimizing buffer for seamless streaming...',
    this.blurSigma = 2.0,
    this.indicatorSize = 50.0,
  });

  /// A standalone version of the buffer indicator for simple centered placements.
  static Widget indicator({
    Key? key,
    String message = 'Buffering stream...',
    double size = 40.0,
  }) {
    return _StandaloneBufferIndicator(
      key: key,
      message: message,
      size: size,
    );
  }

  @override
  State<PlayerBuffer> createState() => _PlayerBufferState();
}

class _PlayerBufferState extends State<PlayerBuffer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The underlying player content
        widget.child,

        // Buffering Glassmorphic Overlay
        if (widget.isBuffering)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blurSigma,
                  sigmaY: widget.blurSigma,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing Neon Cyan Loading Indicator
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: widget.indicatorSize,
                            height: widget.indicatorSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3 * _pulseAnimation.value),
                                  blurRadius: 16.0 * _pulseAnimation.value,
                                  spreadRadius: 2.0 * _pulseAnimation.value,
                                ),
                              ],
                            ),
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              strokeWidth: 3.5,
                              backgroundColor: AppColors.primary.withOpacity(0.15),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18.0),
                      // Readable message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: (0.7 + (0.3 * _pulseAnimation.value)).clamp(0.0, 1.0),
                              child: Text(
                                widget.message,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                  height: 1.4,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Standalone indicator helper widget
class _StandaloneBufferIndicator extends StatelessWidget {
  final String message;
  final double size;

  const _StandaloneBufferIndicator({
    super.key,
    required this.message,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.borderTranslucent,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11.0,
            ),
          ),
        ],
      ),
    );
  }
}
