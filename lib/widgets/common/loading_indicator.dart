import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

/// A premium, custom-styled circular loading indicator.
/// Integrates an ambient brand glow behind the tracking line to provide a high-end feel.
class LoadingIndicator extends StatelessWidget {
  /// Overall bounding box dimension.
  final double size;

  /// Thickness of the rotating line.
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size = 32.0,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow behind the progress loader
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                AppShadows.glowShadow,
              ],
            ),
          ),
          CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            backgroundColor: AppColors.surfaceVariant.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
