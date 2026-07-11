import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/state_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/cards/channel_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/navigation/bottom_navigation.dart';

/// A premium, highly polished Favorites screen displaying all bookmarked IPTV channels.
/// Offers direct play features and real-time state synchronization via Riverpod.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all channels (which have updated isFavorite status based on favoritesProvider)
    final allChannels = ref.watch(parsedChannelsProvider);
    final favoriteChannels = allChannels.where((ch) => ch.isFavorite).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        title: Text(
          'FAVORITES',
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 20.0,
            letterSpacing: 1.2,
            fontWeight: FontWeight.black,
          ),
        ),
        centerTitle: false,
        actions: [
          if (favoriteChannels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.paddingMD),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.primary,
                      size: 14.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${favoriteChannels.length} CHANNELS',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: favoriteChannels.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmptyState(
                        icon: Icons.favorite_border_rounded,
                        title: 'No Favorites Saved',
                        message: 'Bookmark premium channels, matches, and broadcasts to access them instantly here.',
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMD,
                  AppDimensions.paddingSM,
                  AppDimensions.paddingMD,
                  AppDimensions.paddingLG,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: favoriteChannels.length,
                itemBuilder: (context, index) {
                  final channel = favoriteChannels[index];
                  return ChannelCard(
                    key: ValueKey('fav_channel_${channel.id}'),
                    channel: channel,
                    isSelected: false,
                    onTap: () {
                      // PlayerPage is automatically pushed from ChannelCard onTap
                    },
                    onFavoriteToggle: () {
                      // Toggle favorite status in state provider
                      ref.read(favoritesProvider.notifier).toggleFavorite(channel.id);
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
    );
  }
}
