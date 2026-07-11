import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel_model.dart';
import '../../providers/player_provider.dart';
import '../../providers/epg_provider.dart';
import '../../screens/player/player_page.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A premium, glassmorphic card widget representing a single IPTV streaming channel.
/// Follows Material 3 styling with custom image fallbacks, interactive selection state, and live indicators.
class ChannelCard extends ConsumerWidget {
  final ChannelModel channel;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const ChannelCard({
    super.key,
    required this.channel,
    this.isSelected = false,
    required this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epgId = (channel.epgId != null && channel.epgId!.isNotEmpty) ? channel.epgId! : channel.id;
    final currentProgram = ref.watch(currentProgramProvider(epgId));

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withOpacity(0.08) 
            : AppColors.surface,
        borderRadius: AppDimensions.borderMedium,
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : AppColors.borderTranslucent,
          width: 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: AppDimensions.borderMedium,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Update selected channel state inside player provider
              ref.read(selectedChannelProvider.notifier).state = channel;
              
              // Invoke local UI highlights & trigger connection messages
              onTap();

              // Smoothly push premium media player screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlayerPage(channel: channel),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
                vertical: AppDimensions.paddingMD,
              ),
              child: Row(
                children: [
                  // Channel Logo / Cover Placeholder
                  _buildLogoWidget(),
                  const SizedBox(width: AppDimensions.space16),

                  // Channel Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            // Live badge (green/red dot + text)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4.0),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.2),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    'LIVE',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.5,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            // Quality label or category shorthand if available
                            if (channel.quality != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  channel.quality!.toUpperCase(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                            ],
                            // Stream codec or type indicator
                            Expanded(
                              child: Text(
                                channel.streamUrl.split('/').last.split('?').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.muted,
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (currentProgram != null) ...[
                          const SizedBox(height: 6.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.play_circle_fill_rounded,
                                color: AppColors.primary,
                                size: 12.0,
                              ),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  currentProgram.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                '${_formatTime(currentProgram.start)} - ${_formatTime(currentProgram.end)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.muted,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: LinearProgressIndicator(
                              value: currentProgram.progress,
                              backgroundColor: Colors.white10,
                              color: AppColors.primary,
                              minHeight: 2.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: AppDimensions.space12),

                  // Interactive Favorite Star/Heart Icon (UI-only toggling)
                  IconButton(
                    onPressed: onFavoriteToggle,
                    tooltip: channel.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                    icon: Icon(
                      channel.isFavorite 
                          ? Icons.favorite_rounded 
                          : Icons.favorite_border_rounded,
                      color: channel.isFavorite ? Colors.redAccent : AppColors.muted.withOpacity(0.7),
                      size: 22.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the channel avatar, attempting to fetch logoUrl or resolving with a neon gradient fallback.
  Widget _buildLogoWidget() {
    final hasValidLogo = channel.logoUrl != null && channel.logoUrl!.trim().isNotEmpty;

    return Container(
      width: 52.0,
      height: 52.0,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.borderTranslucent,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall - 1.0),
        child: hasValidLogo
            ? Image.network(
                channel.logoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 1.5,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderWidget(),
              )
            : _buildPlaceholderWidget(),
      ),
    );
  }

  /// Beautiful fallback avatar containing the channel's initials over a high-end sports neon gradient
  Widget _buildPlaceholderWidget() {
    final initial = channel.name.isNotEmpty ? channel.name[0].toUpperCase() : 'C';
    
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceVariant,
            AppColors.primary.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initial,
        style: AppTextStyles.headlineLarge.copyWith(
          fontSize: 20.0,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
