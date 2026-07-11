import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// A premium, cinematic loading screen for the video player.
/// Displays a high-fidelity animated progress indicator and informative text.
class PlayerLoading extends StatelessWidget {
  final String message;

  const PlayerLoading({
    super.key,
    this.message = 'Optimizing buffer and establishing stream...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // True cinema black for player container
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Progress Indicator styled with Neon Cyan
          const SizedBox(
            width: 48.0,
            height: 48.0,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3.5,
            ),
          ),
          const SizedBox(height: 20.0),
          // Loading Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white70,
                fontSize: 13.0,
                letterSpacing: 0.2,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
