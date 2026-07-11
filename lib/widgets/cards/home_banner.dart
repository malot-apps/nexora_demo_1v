import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_text_styles.dart';

/// A premium, high-impact sports match banner.
/// Styled with linear athletic gradients, team identifiers, live tickers, and quick watch actions.
class HomeBanner extends StatelessWidget {
  /// Match status or broadcast tag (e.g., "LIVE NOW", "UPCOMING").
  final String statusTag;

  /// Left home team indicator.
  final String homeTeam;

  /// Right away team indicator.
  final String awayTeam;

  /// Score or tournament subtitle.
  final String scoreText;

  /// Game clock or kickoff time (e.g., "74'", "19:00").
  final String matchTime;

  /// Current tournament title.
  final String tournament;

  /// Callback when "Watch Stream" is selected.
  final VoidCallback? onWatchPressed;

  const HomeBanner({
    super.key,
    this.statusTag = 'LIVE NOW',
    this.homeTeam = 'ARGENTINA',
    this.awayTeam = 'FRANCE',
    this.scoreText = '2 - 1',
    this.matchTime = '74\'',
    this.tournament = 'FIFA WORLD CUP 2026 • FINAL',
    this.onWatchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0.0, 24.0 * (1.0 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              offset: const Offset(0, 12),
              blurRadius: 28.0,
              spreadRadius: -6.0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.secondaryGradient,
            ),
            child: Stack(
              children: [
                // Radial spotlight background layer - top right neon cyan
                Positioned(
                  right: -50.0,
                  top: -50.0,
                  child: Container(
                    width: 220.0,
                    height: 220.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.12),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Radial spotlight background layer - bottom left electric blue
                Positioned(
                  left: -60.0,
                  bottom: -60.0,
                  child: Container(
                    width: 240.0,
                    height: 240.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.1),
                          AppColors.secondary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Decorative pitch line pattern
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Opacity(
                    opacity: 0.04,
                    child: Container(
                      height: 80.0,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                ),

                // Core content column
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top header block with Live Tag and Tournament
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Glassmorphic status tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: AppColors.tertiary.withOpacity(0.35),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Pulse live ticker circle
                                const _LivePulseDot(),
                                const SizedBox(width: 6.0),
                                Text(
                                  statusTag,
                                  style: AppTextStyles.matchTime.copyWith(
                                    color: AppColors.tertiary,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Tournament subtitle
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                tournament,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.space20),

                      // Teams Matchup section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Team
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.06),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.shield_rounded,
                                    size: 32.0,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  homeTeam,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.0,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Score Block
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  scoreText,
                                  style: AppTextStyles.scoreText.copyWith(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.black,
                                    color: AppColors.primary,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.primary.withOpacity(0.4),
                                        blurRadius: 8.0,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                // Match clock
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.25),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    matchTime,
                                    style: AppTextStyles.matchTime.copyWith(
                                      fontSize: 11.0,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Team
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.06),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.shield_rounded,
                                    size: 32.0,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  awayTeam,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.0,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.space24),

                      // Play stream action trigger
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: double.infinity,
                          height: 48.0,
                          decoration: BoxDecoration(
                            gradient: AppGradients.buttonGradient,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 14.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onWatchPressed,
                              borderRadius: BorderRadius.circular(12.0),
                              splashColor: Colors.black.withOpacity(0.15),
                              highlightColor: Colors.black.withOpacity(0.08),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.black,
                                      size: 24.0,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      'WATCH STREAM',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Self-animating live breathing indicator widget.
class _LivePulseDot extends StatefulWidget {
  const _LivePulseDot();

  @override
  State<_LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<_LivePulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: 8.0,
        height: 8.0,
        decoration: const BoxDecoration(
          color: AppColors.tertiary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiary,
              blurRadius: 6.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}
