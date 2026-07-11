import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_gradients.dart';

/// A premium, glassmorphism-inspired empty state component.
/// Ideal for displaying feedback when a listing (Favorites, Playlists, Channels) is unpopulated.
class EmptyState extends StatelessWidget {
  /// The material icon glyph representing the domain state.
  final IconData icon;

  /// Primary headline of the empty status.
  final String title;

  /// Supporting descriptive text.
  final String message;

  /// Optional label for a call-to-action button.
  final String? actionLabel;

  /// Callback action triggered by the button.
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutQuart,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * animValue),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
          vertical: AppDimensions.paddingXL,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.borderTranslucent,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 8),
              blurRadius: 18.0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Elegant double-ring stadium-light glow background around the icon
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.12),
                  width: 1.0,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 16.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 40.0,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.space20),
            
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            
            const SizedBox(height: AppDimensions.space8),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.muted,
                  height: 1.45,
                  fontSize: 13.0,
                ),
              ),
            ),
            
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: AppDimensions.space20),
              Container(
                height: 40.0,
                decoration: BoxDecoration(
                  gradient: AppGradients.buttonGradient,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onActionPressed,
                    borderRadius: BorderRadius.circular(10.0),
                    splashColor: Colors.black.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Center(
                        widthFactor: 1.0,
                        child: Text(
                          actionLabel!,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
