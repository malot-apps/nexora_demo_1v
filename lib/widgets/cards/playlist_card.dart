import 'package:flutter/material.dart';
import '../../models/playlist_source.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A premium, glassmorphic card widget representing a single loaded playlist stream source.
/// Follows FIFA World Cup 2026 sports UI guidelines with high-visibility neon accent borders.
class PlaylistCard extends StatelessWidget {
  final PlaylistSource playlist;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleActive;
  final VoidCallback? onTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onDelete,
    this.onToggleActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Select an aesthetic icon based on the playlist type
    IconData typeIcon;
    Color accentColor;

    switch (playlist.type) {
      case PlaylistType.m3uUrl:
      case PlaylistType.m3u8Url:
        typeIcon = Icons.playlist_play_rounded;
        accentColor = AppColors.primary;
        break;
      case PlaylistType.tsUrl:
      case PlaylistType.phpUrl:
        typeIcon = Icons.settings_input_component_rounded;
        accentColor = AppColors.secondary;
        break;
      case PlaylistType.mp4Url:
        typeIcon = Icons.video_library_rounded;
        accentColor = Colors.purpleAccent;
        break;
      case PlaylistType.xtreamCodes:
        typeIcon = Icons.dns_rounded;
        accentColor = AppColors.tertiary;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderMedium,
        border: Border.all(
          color: playlist.isActive 
              ? accentColor.withOpacity(0.2) 
              : AppColors.borderTranslucent,
          width: 1.0,
        ),
        boxShadow: playlist.isActive
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.05),
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
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with Type Chip, Title, Active Toggle
                  Row(
                    children: [
                      // Type Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              typeIcon,
                              size: 12.0,
                              color: accentColor,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              playlist.typeLabel,
                              style: AppTextStyles.matchTime.copyWith(
                                color: accentColor,
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Active Indicator Dot
                      Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: playlist.isActive ? AppColors.tertiary : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        playlist.isActive ? 'ACTIVE' : 'INACTIVE',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: playlist.isActive ? AppColors.tertiary : AppColors.muted,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),

                  // Playlist Name
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),

                  // URL
                  Text(
                    playlist.type == PlaylistType.xtreamCodes
                        ? 'Host: ${playlist.xtreamHost ?? playlist.url}'
                        : playlist.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.muted,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  const Divider(height: 1.0),

                  const SizedBox(height: AppDimensions.space12),

                  // Footer actions row (Channel count, Active switch, Delete button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Channel/Stream count info
                      Row(
                        children: [
                          const Icon(
                            Icons.layers_outlined,
                            size: 16.0,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            '${playlist.channelCount} STREAMS AVAILABLE',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),

                      // Actions
                      Row(
                        children: [
                          if (onToggleActive != null) ...[
                            Switch.adaptive(
                              value: playlist.isActive,
                              activeColor: AppColors.primary,
                              onChanged: onToggleActive,
                            ),
                            const SizedBox(width: 4.0),
                          ],
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              tooltip: 'Remove Playlist',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20.0,
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
        ),
      ),
    );
  }
}
