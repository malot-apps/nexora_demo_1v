import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category_model.dart';
import '../../models/channel_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/cards/channel_card.dart';
import '../../widgets/common/category_chip.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/navigation/bottom_navigation.dart';
import '../../providers/state_providers.dart';
import '../../providers/remote_provider.dart';

/// Premium Live TV screen for Nexora.
/// centures category-driven stream classification, real-time local search filters,
/// and interactive bookmarks.
class LiveTvPage extends ConsumerStatefulWidget {
  const LiveTvPage({super.key});

  @override
  ConsumerState<LiveTvPage> createState() => _LiveTvPageState();
}

class _LiveTvPageState extends ConsumerState<LiveTvPage> {
  // Local state for interactive UI management
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  bool _isSearching = false;
  String? _activeSelectedChannelId;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Toggle search bar UI state
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  /// Handle toggle favorites using Riverpod provider
  void _toggleFavorite(String channelId, List<ChannelModel> channels) {
    final channel = channels.firstWhere((ch) => ch.id == channelId);
    ref.read(favoritesProvider.notifier).toggleFavorite(channelId);

    final willBeFavorite = !channel.isFavorite;
    // Show responsive feedback HUD feedback toast
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willBeFavorite
              ? 'Added ${channel.name} to Favorites'
              : 'Removed ${channel.name} from Favorites',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: willBeFavorite ? AppColors.tertiary : AppColors.surface,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch reactive providers for channels and categories from imported playlists
    final channels = ref.watch(parsedChannelsProvider);
    var categories = ref.watch(parsedCategoriesProvider);
    final remoteConfigAsync = ref.watch(remoteConfigNotifierProvider);

    // Dynamic remote categories sort order and overrides integration
    remoteConfigAsync.whenData((config) {
      if (config.categories.isNotEmpty) {
        final sortOrderMap = {for (var c in config.categories) c.id: c.sortOrder};
        final remoteNames = {for (var c in config.categories) c.id: c.name};

        // Apply custom name overrides
        categories = categories.map((cat) {
          if (remoteNames.containsKey(cat.id)) {
            return cat.copyWith(name: remoteNames[cat.id]!);
          }
          return cat;
        }).toList();

        // Apply remote sort order
        categories.sort((a, b) {
          if (a.id == 'all') return -1;
          if (b.id == 'all') return 1;
          final orderA = sortOrderMap[a.id] ?? 999;
          final orderB = sortOrderMap[b.id] ?? 999;
          return orderA.compareTo(orderB);
        });
      }
    });

    // 1. Filter channels by category and search query
    final filteredChannels = channels.where((ch) {
      final matchesCategory = _selectedCategoryId == 'all' || ch.categoryId == _selectedCategoryId;
      final matchesSearch = ch.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ch.streamUrl.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Custom Live TV AppBar / Welcome Header
            _buildHeader(),

            // 3. Horizontal Categories Chip bar
            _buildCategoryBar(categories, channels),

            const SizedBox(height: AppDimensions.space12),

            // 4. Scrollable Channel List OR Empty States
            Expanded(
              child: filteredChannels.isEmpty
                  ? _buildEmptyState()
                  : _buildChannelListView(filteredChannels, channels),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
    );
  }

  /// Builds the top app bar or search input field
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSearching ? _buildSearchField() : _buildTitleBar(),
      ),
    );
  }

  /// Builds standard title bar layout
  Widget _buildTitleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'LIVE TELEVISION',
                  style: AppTextStyles.headlineMedium.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.black,
                  ),
                ),
                const SizedBox(width: 8.0),
                // Pulsing broadcast icon
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error,
                        blurRadius: 6.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            Text(
              'WORLD CUP 2026 BROADCASTS',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),

        // Interactive UI search trigger button
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.borderTranslucent,
              width: 1.0,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.search_rounded),
            color: Colors.white,
            onPressed: _toggleSearch,
          ),
        ),
      ],
    );
  }

  /// Builds active search field bar with back button
  Widget _buildSearchField() {
    return Container(
      height: 52.0,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            onPressed: _toggleSearch,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search channel name or streaming URL...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white60),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  /// Builds the scrollable list of categories at the top
  Widget _buildCategoryBar(List<CategoryModel> categories, List<ChannelModel> channels) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategoryId == category.id;
          
          // Calculate active items in category
          int count = category.id == 'all'
              ? channels.length
              : channels.where((ch) => ch.categoryId == category.id).length;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CategoryChip(
              label: category.name,
              isSelected: isSelected,
              count: count,
              onTap: () {
                setState(() {
                  _selectedCategoryId = category.id;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds smooth list view of filtered channel cards
  Widget _buildChannelListView(List<ChannelModel> list, List<ChannelModel> allChannels) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final channel = list[index];
        final isSelected = _activeSelectedChannelId == channel.id;

        return ChannelCard(
          channel: channel,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _activeSelectedChannelId = channel.id;
            });
            // Show responsive broadcast connection snackbar
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Connected to ${channel.name} (${channel.quality ?? 'HD'})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          onFavoriteToggle: () => _toggleFavorite(channel.id, allChannels),
        );
      },
    );
  }

  /// Beautiful empty state fallback widget if search or filter query returns 0 items
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Center(
        child: EmptyState(
          icon: _isSearching ? Icons.search_off_rounded : Icons.tv_off_rounded,
          title: _isSearching ? 'No Search Results found' : 'No Channels in Category',
          message: _isSearching
              ? 'We couldn\'t find any active streams matching "$_searchQuery". Verify spelling or try another keyword.'
              : 'There are no live broadcasts currently active under this stream classification.',
          actionLabel: _isSearching ? 'Clear Search' : 'Reset Filters',
          onActionPressed: () {
            setState(() {
              _selectedCategoryId = 'all';
              _searchQuery = '';
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
      ),
    );
  }
}
