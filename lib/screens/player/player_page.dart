import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel_model.dart';
import '../../providers/player_provider.dart';
import '../../providers/epg_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/player/video_player_widget.dart';

/// A premium, immersive playback screen for streaming channels.
/// Automatically listens to the [selectedChannelProvider] or falls back to
/// constructor-provided [channel]. Displays the stream inside a hardware-accelerated
/// [VideoPlayerWidget] with native MediaKit playback support (M3U8, TS, and MP4 formats),
/// accompanied by beautiful metadata cards, logos, and high-contrast badges.
class PlayerPage extends ConsumerWidget {
  final ChannelModel? channel;

  const PlayerPage({
    super.key,
    this.channel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch selectedChannelProvider or fallback to constructor parameter
    final selectedChannel = channel ?? ref.watch(selectedChannelProvider);

    if (selectedChannel == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'No channel selected.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final epgId = (selectedChannel.epgId != null && selectedChannel.epgId!.isNotEmpty)
        ? selectedChannel.epgId!
        : selectedChannel.id;
    final currentProgram = ref.watch(currentProgramProvider(epgId));
    final nextProgram = ref.watch(nextProgramProvider(epgId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top immersive header bar with custom back navigation action
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
                vertical: AppDimensions.paddingSM,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'NOW STREAMING',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video player container with 16:9 Aspect Ratio and subtle glow border
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.borderTranslucent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 15.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.5),
                  child: VideoPlayerWidget(
                    url: selectedChannel.streamUrl,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // Channel Details Info Card (Name, Logo, Category, Quality)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Glassmorphic metadata card
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingLG),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: AppColors.borderTranslucent,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Channel Logo with automatic gradient fallback
                            _buildLogoWidget(selectedChannel),
                            const SizedBox(width: AppDimensions.space16),

                            // Channel Text details and live badge
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedChannel.name,
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      // LIVE stream badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6.0),
                                          border: Border.all(
                                            color: AppColors.error.withOpacity(0.2),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5.0),
                                            Text(
                                              'LIVE BROADCAST',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.error,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9.0,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      // Resolution / Quality Badge
                                      if (selectedChannel.quality != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6.0),
                                            border: Border.all(
                                              color: AppColors.primary.withOpacity(0.2),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Text(
                                            selectedChannel.quality!.toUpperCase(),
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9.0,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Program Guide Section (EPG)
                      if (currentProgram != null || nextProgram != null) ...[
                        const SizedBox(height: AppDimensions.space20),
                        Text(
                          'PROGRAM GUIDE (EPG)',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingMD),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current Live Program
                              if (currentProgram != null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(0.3),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        'ON NOW',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9.0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${_formatTime(currentProgram.start)} - ${_formatTime(currentProgram.end)}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.muted,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  currentProgram.title,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                if (currentProgram.description.isNotEmpty) ...[
                                  const SizedBox(height: 4.0),
                                  Text(
                                    currentProgram.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 11.0,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8.0),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2.0),
                                  child: LinearProgressIndicator(
                                    value: currentProgram.progress,
                                    backgroundColor: Colors.white10,
                                    color: AppColors.primary,
                                    minHeight: 3.5,
                                  ),
                                ),
                              ],

                              // Separator if both exist
                              if (currentProgram != null && nextProgram != null) ...[
                                const SizedBox(height: 12.0),
                                const Divider(color: Colors.white10, height: 1.0),
                                const SizedBox(height: 12.0),
                              ],

                              // Next/Upcoming Program
                              if (nextProgram != null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: AppColors.secondary.withOpacity(0.3),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        'UP NEXT',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9.0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${_formatTime(nextProgram.start)} - ${_formatTime(nextProgram.end)}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.muted,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  nextProgram.title,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                                if (nextProgram.description.isNotEmpty) ...[
                                  const SizedBox(height: 4.0),
                                  Text(
                                    nextProgram.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 11.0,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.space20),

                      // Section details header
                      Text(
                        'STREAM DETAILS',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      // List of stream metadata rows
                      _buildDetailRow(Icons.link_rounded, 'Stream URL', selectedChannel.streamUrl),
                      _buildDetailRow(Icons.category_rounded, 'Category ID', selectedChannel.categoryId),
                      _buildDetailRow(Icons.star_rounded, 'Bookmark Status', selectedChannel.isFavorite ? 'Saved in Favorites' : 'Not Bookmarked'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build network image logo or premium placeholder
  Widget _buildLogoWidget(ChannelModel channel) {
    final hasValidLogo = channel.logoUrl != null && channel.logoUrl!.trim().isNotEmpty;

    return Container(
      width: 56.0,
      height: 56.0,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.borderTranslucent,
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.8),
        child: hasValidLogo
            ? Image.network(
                channel.logoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 18.0,
                      height: 18.0,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.0,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderWidget(channel),
              )
            : _buildPlaceholderWidget(channel),
      ),
    );
  }

  /// Fallback gradient placeholder containing the first letter of channel name
  Widget _buildPlaceholderWidget(ChannelModel channel) {
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
          fontSize: 22.0,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Reusable row widget for showing individual key-value channel metadata properties
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.borderTranslucent,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.muted,
                    fontSize: 9.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
