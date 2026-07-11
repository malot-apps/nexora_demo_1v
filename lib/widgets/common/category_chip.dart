import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A premium, highly aesthetic selectable chip used for classifying streaming channels.
/// Features a smooth glow transition and standard Material 3 interactive boundaries.
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.12) 
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.borderTranslucent,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.muted,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                fontSize: 10.5,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withOpacity(0.18) 
                      : Colors.black26,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9.0,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.muted,
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
