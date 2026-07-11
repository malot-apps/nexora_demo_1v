import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A premium, highly polished dialog inviting users to join the official Nexora Telegram community.
/// Follows AppTheme styling and updates user preferences using SharedPreferences.
class TelegramJoinDialog extends ConsumerWidget {
  const TelegramJoinDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.borderLarge,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 24.0,
              spreadRadius: 4.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Premium Header Icon Badge
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded, // Matches the Telegram angle look
                  color: Colors.black,
                  size: 32.0,
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // 2. Title & Slogan
              Text(
                'JOIN NEXORA COMMUNITY',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.black,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  'REAL-TIME MATCH ALERTS & LIVE FEEDS',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    fontSize: 9.5,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // 3. Body Message
              Text(
                'Connect with over 15,000+ streaming enthusiasts. Get instant live match alerts, server maintenance updates, and request premium sports channels directly from our active team!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.muted,
                  height: 1.5,
                  fontSize: 12.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space24),

              // 4. Action Buttons Stack
              Column(
                children: [
                  // Primary Join Button
                  Container(
                    width: double.infinity,
                    height: 48.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppDimensions.borderSmall,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mark preference as dismissed (joined / don't show again)
                        await ref
                            .read(telegramSettingsProvider.notifier)
                            .updateStatus(TelegramDialogStatus.dontShowAgain);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          
                          // Show redirection feedback to user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      'Redirecting to t.me/nexora_iptv_official...',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.surface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        shadowColor: Colors.transparent,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderSmall,
                        ),
                      ),
                      child: Text(
                        'JOIN COMMUNITY NOW',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.extrabold,
                          fontSize: 12.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),

                  // Secondary: Later & Don't Show Again
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(telegramSettingsProvider.notifier)
                                .updateStatus(TelegramDialogStatus.later);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.borderTranslucent,
                              width: 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderSmall,
                            ),
                          ),
                          child: Text(
                            'LATER',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.muted,
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(telegramSettingsProvider.notifier)
                                .updateStatus(TelegramDialogStatus.dontShowAgain);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.borderTranslucent,
                              width: 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderSmall,
                            ),
                          ),
                          child: Text(
                            "DON'T SHOW AGAIN",
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.muted,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
