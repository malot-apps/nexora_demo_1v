import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Represents a single alert item in the News Banner.
class NewsItem {
  final String category;
  final String message;
  final IconData icon;
  final Color categoryColor;

  const NewsItem({
    required this.category,
    required this.message,
    required this.icon,
    required this.categoryColor,
  });
}

/// A premium, auto-scrolling news banner designed for IPTV enthusiast feeds.
/// Uses a self-animating periodic timer with high-performance [AnimatedSwitcher]
/// to cycle through Live Match Alerts, Server Status, and App News smoothly.
class NewsBanner extends StatefulWidget {
  const NewsBanner({super.key});

  @override
  State<NewsBanner> createState() => _NewsBannerState();
}

class _NewsBannerState extends State<NewsBanner> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<NewsItem> _newsItems = const [
    NewsItem(
      category: 'LIVE MATCH',
      message: '⚽ UEFA Champions League Final: Real Madrid vs Man City live broadcast in UHD starts in 2 hours!',
      icon: Icons.sports_soccer_rounded,
      categoryColor: AppColors.primary,
    ),
    NewsItem(
      category: 'SERVER STATUS',
      message: '⚡ High-speed streaming clusters in EU & US are 100% operational. Low-latency HLS stream decoding active.',
      icon: Icons.dns_rounded,
      categoryColor: AppColors.tertiary,
    ),
    NewsItem(
      category: 'APP NEWS',
      message: '🔥 Nexora Update: Sprint 13 Real Playlist Ingestion & local .m3u8 offline synchronization now active.',
      icon: Icons.rocket_launch_rounded,
      categoryColor: AppColors.secondary,
    ),
    NewsItem(
      category: 'LIVE MATCH',
      message: '🏎️ Formula 1 Monaco Grand Prix Main Race: UHD live streaming channels are pre-cached and ready for playback.',
      icon: Icons.sports_motorsports_rounded,
      categoryColor: AppColors.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _newsItems.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeItem = _newsItems[_currentIndex];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderSmall,
        border: Border.all(
          color: AppColors.borderTranslucent,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Optional click detail action for News Alerts
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Alert Detail: "${activeItem.message}"',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
                backgroundColor: AppColors.surface,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD,
              vertical: 11.0,
            ),
            child: Row(
              children: [
                // 1. Alert Icon Left (Animated relative to category)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    activeItem.icon,
                    key: ValueKey('icon_${activeItem.category}_$_currentIndex'),
                    color: activeItem.categoryColor,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),

                // 2. Main Scrolling Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.4),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey('msg_container_$_currentIndex'),
                      children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: activeItem.categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                              color: activeItem.categoryColor.withOpacity(0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            activeItem.category,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: activeItem.categoryColor,
                              fontWeight: FontWeight.black,
                              fontSize: 8.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),

                        // Alert Message String
                        Expanded(
                          child: Text(
                            activeItem.message,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Mini Action Chevron Indicator
                const SizedBox(width: 4.0),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted.withOpacity(0.6),
                  size: 16.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
