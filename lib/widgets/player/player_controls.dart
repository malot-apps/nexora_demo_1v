import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Interactive media control HUD overlay for [VideoPlayerWidget].
/// Integrates premium play/pause buttons, a quick stream replay action, position seeker/slider,
/// and responsive auto-hide feedback.
class PlayerControls extends StatelessWidget {
  final Player player;
  final bool visible;
  final String streamUrl;
  final VoidCallback onUserInteraction;

  const PlayerControls({
    super.key,
    required this.player,
    required this.visible,
    required this.streamUrl,
    required this.onUserInteraction,
  });

  /// Action to reset the media stream back to the beginning and resume play
  Future<void> _handleReplay() async {
    onUserInteraction();
    await player.seek(Duration.zero);
    await player.play();
  }

  /// Format duration for display (e.g. HH:MM:SS or MM:SS)
  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = streamUrl.toLowerCase().contains('.m3u8');

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !visible,
        child: Container(
          color: Colors.black45, // Soft overlay contrast tint
          child: Stack(
            children: [
              // Top Information Bar (Live Stream Tag or Stream URL/Title)
              Positioned(
                top: 12.0,
                left: 16.0,
                right: 16.0,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          color: AppColors.borderTranslucent,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isLive ? Colors.redAccent : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            isLive ? 'LIVE' : 'VOD MP4',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.0,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        streamUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Centered Main Actions Grid (Play, Pause, Replay)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // REPLAY Button (Seeks to zero and plays)
                    _ControlButton(
                      icon: Icons.replay_rounded,
                      iconColor: Colors.white,
                      tooltip: 'Replay from start',
                      onPressed: _handleReplay,
                    ),
                    const SizedBox(width: 24.0),

                    // Main PLAY / PAUSE Button
                    StreamBuilder<bool>(
                      stream: player.stream.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return _ControlButton(
                          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          iconColor: AppColors.primary,
                          size: 56.0,
                          iconSize: 36.0,
                          tooltip: isPlaying ? 'Pause' : 'Play',
                          onPressed: () {
                            onUserInteraction();
                            player.playOrPause();
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 24.0),

                    // FAST FORWARD (Skip 10 seconds) or Next stream helper button
                    _ControlButton(
                      icon: Icons.forward_10_rounded,
                      iconColor: Colors.white,
                      tooltip: 'Skip 10 seconds',
                      onPressed: () async {
                        onUserInteraction();
                        final position = await player.stream.position.first;
                        await player.seek(position + const Duration(seconds: 10));
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Progress Seeker Overlay (Only for VOD/MP4 files)
              if (!isLive)
                Positioned(
                  bottom: 12.0,
                  left: 16.0,
                  right: 16.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<Duration>(
                        stream: player.stream.duration,
                        builder: (context, durationSnapshot) {
                          final duration = durationSnapshot.data ?? Duration.zero;

                          return StreamBuilder<Duration>(
                            stream: player.stream.position,
                            builder: (context, positionSnapshot) {
                              final position = positionSnapshot.data ?? Duration.zero;

                              // Ensure valid bounded calculation
                              final double value = duration.inMilliseconds > 0
                                  ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                                  : 0.0;

                              return Column(
                                children: [
                                  // Timeline Seeker Slider
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3.0,
                                      activeTrackColor: AppColors.primary,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: AppColors.primary,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                                      overlayColor: AppColors.primary.withOpacity(0.15),
                                    ),
                                    child: Slider(
                                      value: value,
                                      onChanged: (newValue) {
                                        onUserInteraction();
                                        final target = Duration(
                                          milliseconds: (newValue * duration.inMilliseconds).toInt(),
                                        );
                                        player.seek(target);
                                      },
                                    ),
                                  ),
                                  // Duration timestamps row
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(position),
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: Colors.white70,
                                            fontSize: 10.0,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(duration),
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: Colors.white70,
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper button widget with beautiful custom glass-tinted styling
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final double iconSize;
  final String tooltip;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.iconColor,
    this.size = 46.0,
    this.iconSize = 24.0,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderTranslucent,
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
