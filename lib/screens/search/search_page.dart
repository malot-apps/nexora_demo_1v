import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category_model.dart';
import '../../providers/state_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/cards/channel_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/navigation/bottom_navigation.dart';

/// A premium, ultra-responsive Search Screen for Nexora.
/// Allows real-time search of channels by name or category, complete with quick filter category chips.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    // Initialize search controller with current provider state
    final currentQuery = ref.read(searchQueryProvider);
    _searchController = TextEditingController(text: currentQuery);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
  }

  void _clearSearch() {
    _searchController.clear();
    _onQueryChanged('');
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider).trim();
    final queryLower = query.toLowerCase();
    
    final allChannels = ref.watch(parsedChannelsProvider);
    final categories = ref.watch(parsedCategoriesProvider);

    // Filter channels in real-time by Name or Category Name / Category ID
    final filteredChannels = allChannels.where((channel) {
      if (queryLower.isEmpty) return true;

      // 1. Check channel name
      final nameMatches = channel.name.toLowerCase().contains(queryLower);

      // 2. Check channel's category details
      final category = categories.firstWhere(
        (cat) => cat.id.toLowerCase() == channel.categoryId.toLowerCase(),
        orElse: () => CategoryModel(id: channel.categoryId, name: channel.categoryId),
      );
      final categoryMatches = category.name.toLowerCase().contains(queryLower) ||
          channel.categoryId.toLowerCase().contains(queryLower);

      return nameMatches || categoryMatches;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        title: Text(
          'SEARCH CHANNELS',
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 20.0,
            letterSpacing: 1.2,
            fontWeight: FontWeight.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Premium Search Input Container
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
                vertical: AppDimensions.paddingSM,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimensions.borderMedium,
                  border: Border.all(
                    color: _searchFocusNode.hasFocus 
                        ? AppColors.primary 
                        : AppColors.borderTranslucent,
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onQueryChanged,
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by channel name or category...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 22.0,
                    ),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: AppColors.muted,
                              size: 20.0,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMD,
                    ),
                  ),
                  onTap: () {
                    setState(() {}); // Trigger repaint to update border color focus state
                  },
                ),
              ),
            ),

            // 2. Category Quick-Filter Chips
            if (categories.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.space4),
              SizedBox(
                height: 48.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    // Skip 'All Channels' as we want specific categories
                    if (cat.id == 'all') return const SizedBox.shrink();
                    
                    final isSelected = queryLower == cat.name.toLowerCase();

                    return Padding(
                      padding: const EdgeInsets.only(right: AppDimensions.space8, top: 4.0, bottom: 4.0),
                      child: FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        label: Text(
                          '${cat.name.toUpperCase()} (${cat.channelCount})',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isSelected ? Colors.black : AppColors.muted,
                          ),
                        ),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.borderTranslucent,
                            width: 1.0,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            _searchController.text = cat.name;
                            _onQueryChanged(cat.name);
                          } else {
                            _clearSearch();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.space8),

            // 3. Search Results or Empty State
            Expanded(
              child: filteredChannels.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(AppDimensions.paddingLG),
                        child: EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No Matches Found',
                          message: 'We couldn\'t find any channel or category matching "$query". Double-check spelling or try searching other sports/news tags.',
                          actionLabel: 'CLEAR SEARCH',
                          onActionPressed: _clearSearch,
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
                      itemCount: filteredChannels.length,
                      itemBuilder: (context, index) {
                        final channel = filteredChannels[index];
                        return ChannelCard(
                          key: ValueKey('search_channel_${channel.id}'),
                          channel: channel,
                          isSelected: false,
                          onTap: () {
                            // Automatically triggers state updates & player push inside ChannelCard
                          },
                          onFavoriteToggle: () {
                            ref.read(favoritesProvider.notifier).toggleFavorite(channel.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
    );
  }
}
