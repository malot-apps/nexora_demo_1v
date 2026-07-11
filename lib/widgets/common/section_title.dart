import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Reusable section title header with a high-contrast Neon Accent bar.
/// Complements Material Design 3 and gives lists/grids a sports-broadcast feel.
class SectionTitle extends StatelessWidget {
  /// The header text.
  final String title;

  /// Optional text label for secondary actions (e.g., "See All").
  final String? actionLabel;

  /// Callback when the secondary action is triggered.
  final VoidCallback? onActionPressed;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left portion containing title and high-contrast prefix indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4.0,
                height: 18.0,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Optional right action trigger
          if (actionLabel != null && onActionPressed != null)
            GestureDetector(
              onTap: onActionPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10.0,
                      color: AppColors.primary,
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
