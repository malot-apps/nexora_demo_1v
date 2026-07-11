import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// A cinematic, high-contrast error display for stream loading failures.
/// Provides a descriptive message and an accessible retry mechanism.
class PlayerError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const PlayerError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Dark cinema background
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Warning Symbol
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 54.0,
          ),
          const SizedBox(height: 16.0),
          // Error Title
          Text(
            'STREAM PLAYBACK ERROR',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8.0),
          // Error Detail Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              error.isNotEmpty
                  ? error
                  : 'The stream format is unsupported, offline, or timed out. Please check your network connection.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white60,
                fontSize: 12.0,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          // Retry Button (Minimum height 48dp for premium touch targets)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20.0, color: Colors.black),
            label: const Text(
              'RETRY CONNECTION',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                letterSpacing: 0.8,
                color: Colors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}
