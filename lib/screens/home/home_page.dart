import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../providers/remote_provider.dart';
import '../../models/remote_config_model.dart';
import '../../services/playlist/playlist_import_service.dart';
import '../../services/epg/epg_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/cards/home_banner.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/dialogs/telegram_dialog.dart';
import '../../widgets/navigation/bottom_navigation.dart';

/// The primary Home landing screen for Nexora.
/// Optimized for a stadium-inspired sports-centric feed layout using Material 3.
/// Displays Telegram dialog on first launch and embeds a self-animating news alert banner.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Run after build frame completes to prompt the Join Community dialog safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTelegramDialog();
    });
  }

  void _checkTelegramDialog() {
    // Read current preference state
    final status = ref.read(telegramSettingsProvider);
    status.whenData((value) {
      if (value == TelegramDialogStatus.show) {
        showDialog(
          context: context,
          barrierDismissible: false, // Forces user to actively decide or dismiss
          builder: (context) => const TelegramJoinDialog(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfigAsync = ref.watch(remoteConfigNotifierProvider);

    return remoteConfigAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (err, stack) => _buildMainScaffold(context, RemoteConfigModel.fallback()),
      data: (config) {
        // Cache the config in the import service so other synchronous services can leverage it
        PlaylistImportService.remoteConfig = config;

        // If maintenance mode is active, block the UI with a beautiful scheduled maintenance screen
        if (config.appConfig.maintenanceMode) {
          return _buildMaintenanceScreen(context, config.appConfig.maintenanceMessage);
        }

        return _buildMainScaffold(context, config);
      },
    );
  }

  Widget _buildMaintenanceScreen(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    color: AppColors.error,
                    size: 64.0,
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'NEXORA UNDER MAINTENANCE',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.black,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(remoteConfigNotifierProvider.notifier).loadConfig(forceRefresh: true);
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                  label: const Text('RETRY CONNECTION'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainScaffold(BuildContext context, RemoteConfigModel config) {
    final banner = config.homeBanner;
    final announce = config.announcement;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Customized Welcome Header Block
              _FadeSlideEntrance(
                delay: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingMD,
                    AppDimensions.paddingMD,
                    AppDimensions.paddingMD,
                    AppDimensions.paddingSM,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEXORA',
                            style: AppTextStyles.headlineMedium.copyWith(
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.black,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Row(
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  color: AppColors.tertiary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.tertiary,
                                      blurRadius: 4.0,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                "REMOTELY MANAGED CONTENT ACTIVE",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Top quick-actions panel with Management & Notifications
                      Row(
                        children: [
                          // Admin management panel trigger
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: AppColors.borderTranslucent,
                                width: 1.0,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.settings_suggest_rounded, size: 22.0, color: AppColors.primary),
                              onPressed: () => _showContentManager(context, config),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: Border.all(
                                    color: AppColors.borderTranslucent,
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_none_rounded, size: 22.0),
                                  color: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('No new sports notifications'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                right: 2.0,
                                top: 2.0,
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary,
                                        blurRadius: 4.0,
                                      ),
                                    ],
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

              const SizedBox(height: AppDimensions.space8),

              // Dynamic Scrolling Remote News Alerts Banner
              _FadeSlideEntrance(
                delay: 1,
                child: _RemoteNewsTicker(alerts: config.newsBanner.newsAlerts),
              ),

              const SizedBox(height: AppDimensions.space12),

              // Remote Announcement Box
              if (announce.showAnnouncement)
                _FadeSlideEntrance(
                  delay: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.12),
                            AppColors.secondary.withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20.0),
                              const SizedBox(width: 8.0),
                              Text(
                                announce.title,
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.black, fontSize: 14.0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            announce.message,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted, fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: AppDimensions.space12),

              // 2. Large Live Match Feature Banner (Remotely managed)
              HomeBanner(
                statusTag: banner.statusTag,
                homeTeam: banner.homeTeam,
                awayTeam: banner.awayTeam,
                scoreText: banner.scoreText,
                matchTime: banner.matchTime,
                tournament: banner.tournament,
              ),

              // Custom remote poster images if present
              if (config.posterImages.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.space16),
                _FadeSlideEntrance(
                  delay: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Spotlight Event'),
                      const SizedBox(height: AppDimensions.space12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                        child: Row(
                          children: config.posterImages.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.network(
                                  entry.value,
                                  width: 240,
                                  height: 130,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) => Container(
                                    width: 240,
                                    height: 130,
                                    color: AppColors.surface,
                                    child: const Icon(Icons.broken_image_rounded, color: AppColors.muted),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.space24),

              // 3. Quick Action: Import Playlist Button Block
              _FadeSlideEntrance(
                delay: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.12),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 14.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.15),
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.playlist_add_rounded,
                            color: AppColors.primary,
                            size: 26.0,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import IPTV Playlist',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                              const SizedBox(height: 3.0),
                              Text(
                                'Load M3U streams or file sources',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.muted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 38.0,
                          decoration: BoxDecoration(
                            gradient: AppGradients.buttonGradient,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 8.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.push('/import_playlist'),
                              borderRadius: BorderRadius.circular(10.0),
                              splashColor: Colors.black.withOpacity(0.15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Center(
                                  child: Text(
                                    'Import',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.black,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // 4. Section: Continue Watching
              _FadeSlideEntrance(
                delay: 4,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'Continue Watching'),
                    SizedBox(height: AppDimensions.space12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                      child: EmptyState(
                        icon: Icons.play_circle_outline_rounded,
                        title: 'No Streams In Progress',
                        message: 'Your recently viewed live TV channels and streams will be saved here.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // 5. Section: Trending Channels
              _FadeSlideEntrance(
                delay: 5,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'Trending Sports Channels'),
                    SizedBox(height: AppDimensions.space12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                      child: EmptyState(
                        icon: Icons.trending_up_rounded,
                        title: 'No Playlist Configured',
                        message: 'Trending live channels will populate once an M3U stream source is loaded.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // 6. Section: Favorites
              _FadeSlideEntrance(
                delay: 6,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'My Favorites'),
                    SizedBox(height: AppDimensions.space12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                      child: EmptyState(
                        icon: Icons.favorite_border_rounded,
                        title: 'Your Favorites List is Empty',
                        message: 'Bookmark channels from the Live TV viewer to retrieve them instantly.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48.0), // Spacing before the bottom nav bar bounds
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }

  /// Opens the dynamic Content Management panel.
  /// Lets the user test adding/editing/deleting/toggling remote properties locally.
  void _showContentManager(BuildContext context, RemoteConfigModel config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  'REMOTE CONTENT MANAGER',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.black, color: AppColors.primary),
                ),
                const SizedBox(height: 12.0),
                const TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  tabs: [
                    Tab(icon: Icon(Icons.playlist_play_rounded), text: 'Playlists'),
                    Tab(icon: Icon(Icons.category_rounded), text: 'Categories'),
                    Tab(icon: Icon(Icons.tv_rounded), text: 'Channels'),
                    Tab(icon: Icon(Icons.rss_feed_rounded), text: 'EPG'),
                  ],
                ),
                const SizedBox(height: 12.0),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPlaylistsTab(config),
                      _buildCategoriesTab(config),
                      _buildChannelsTab(config),
                      _buildEpgTab(config),
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

  Widget _buildPlaylistsTab(RemoteConfigModel config) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setTabState) => Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: config.playlists.length,
              itemBuilder: (context, index) {
                final playlist = config.playlists[index];
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(playlist.url, style: TextStyle(color: AppColors.muted, fontSize: 11.0), maxLines: 1),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: playlist.isActive,
                          activeColor: AppColors.primary,
                          onChanged: (val) async {
                            await PlaylistImportService.toggleRemotePlaylistActive(playlist.id, val);
                            ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                            setTabState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                          onPressed: () async {
                            await PlaylistImportService.deleteRemotePlaylist(playlist.id);
                            ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                            setTabState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Playlist Name', labelStyle: TextStyle(color: AppColors.muted)),
                ),
                TextField(
                  controller: urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Playlist URL', labelStyle: TextStyle(color: AppColors.muted)),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                      await PlaylistImportService.addRemotePlaylist(RemotePlaylistConfig(
                        id: 'remote_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        url: urlController.text,
                        type: 'm3u',
                        isActive: true,
                      ));
                      nameController.clear();
                      urlController.clear();
                      ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                      setTabState(() {});
                    }
                  },
                  child: const Text('Add Playlist', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(RemoteConfigModel config) {
    final catIdController = TextEditingController();
    final catNameController = TextEditingController();
    final catImageController = TextEditingController();
    final catSortController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setTabState) => Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: config.categories.length,
              itemBuilder: (context, index) {
                final category = config.categories[index];
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text('ID: ${category.id} | Order: ${category.sortOrder}', style: TextStyle(color: AppColors.muted)),
                    trailing: Icon(Icons.category, color: AppColors.primary.withOpacity(0.5)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: catIdController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Category ID', labelStyle: TextStyle(color: AppColors.muted)),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: catNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: AppColors.muted)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: catImageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Image URL', labelStyle: TextStyle(color: AppColors.muted)),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: catSortController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Sort Order', labelStyle: TextStyle(color: AppColors.muted)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (catIdController.text.isNotEmpty && catNameController.text.isNotEmpty) {
                      await PlaylistImportService.addRemoteCategory(RemoteCategoryConfig(
                        id: catIdController.text,
                        name: catNameController.text,
                        image: catImageController.text,
                        sortOrder: int.tryParse(catSortController.text) ?? 1,
                      ));
                      catIdController.clear();
                      catNameController.clear();
                      catImageController.clear();
                      catSortController.clear();
                      ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                      setTabState(() {});
                    }
                  },
                  child: const Text('Add Category', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChannelsTab(RemoteConfigModel config) {
    final chanIdController = TextEditingController();
    final logoController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setTabState) => Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SectionTitle(title: 'Featured Channels'),
                ...config.featuredChannels.map((chId) => ListTile(
                  title: Text(chId, style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.star_rounded, color: AppColors.primary),
                    onPressed: () async {
                      await PlaylistImportService.toggleFeaturedChannel(chId, false);
                      ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                      setTabState(() {});
                    },
                  ),
                )),
                const SectionTitle(title: 'Hidden Channels'),
                ...config.hiddenChannels.map((chId) => ListTile(
                  title: Text(chId, style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility_off_rounded, color: AppColors.error),
                    onPressed: () async {
                      await PlaylistImportService.toggleHiddenChannel(chId, false);
                      ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                      setTabState(() {});
                    },
                  ),
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: chanIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Channel ID (e.g. sky_sports)', labelStyle: TextStyle(color: AppColors.muted)),
                ),
                TextField(
                  controller: logoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Custom Logo URL', labelStyle: TextStyle(color: AppColors.muted)),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () async {
                        if (chanIdController.text.isNotEmpty) {
                          await PlaylistImportService.toggleFeaturedChannel(chanIdController.text, true);
                          ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                          chanIdController.clear();
                          setTabState(() {});
                        }
                      },
                      child: const Text('Feature', style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () async {
                        if (chanIdController.text.isNotEmpty) {
                          await PlaylistImportService.toggleHiddenChannel(chanIdController.text, true);
                          ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                          chanIdController.clear();
                          setTabState(() {});
                        }
                      },
                      child: const Text('Hide', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                      onPressed: () async {
                        if (chanIdController.text.isNotEmpty && logoController.text.isNotEmpty) {
                          await PlaylistImportService.updateChannelLogo(chanIdController.text, logoController.text);
                          ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                          chanIdController.clear();
                          logoController.clear();
                          setTabState(() {});
                        }
                      },
                      child: const Text('Logo', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEpgTab(RemoteConfigModel config) {
    final urlController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setTabState) => Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: config.epgUrls.length,
              itemBuilder: (context, index) {
                final epg = config.epgUrls[index];
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    title: Text(epg.url, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(epg.isDefault ? 'Default EPG' : 'EPG Source', style: const TextStyle(color: AppColors.primary)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: epg.isEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (val) async {
                            await EpgService.toggleEpgEnabled(epg.url, val);
                            ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                            setTabState(() {});
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.star_rounded, color: epg.isDefault ? AppColors.primary : AppColors.muted),
                          onPressed: () async {
                            await EpgService.setDefaultEpg(epg.url);
                            ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                            setTabState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'EPG XMLTV URL', labelStyle: TextStyle(color: AppColors.muted)),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (urlController.text.isNotEmpty) {
                      await EpgService.addRemoteEpg(RemoteEpgConfig(
                        url: urlController.text,
                        isEnabled: true,
                        isDefault: false,
                      ));
                      urlController.clear();
                      ref.read(remoteConfigNotifierProvider.notifier).loadConfig();
                      setTabState(() {});
                    }
                  },
                  child: const Text('Add EPG URL', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Dynamic automatic scrolling news banner widget inline on the HomePage
class _RemoteNewsTicker extends StatefulWidget {
  final List<String> alerts;
  const _RemoteNewsTicker({required this.alerts});

  @override
  State<_RemoteNewsTicker> createState() => _RemoteNewsTickerState();
}

class _RemoteNewsTickerState extends State<_RemoteNewsTicker> {
  int _currentIndex = 0;
  Timer? _timer;

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
    if (widget.alerts.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.alerts.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();
    final message = widget.alerts[_currentIndex];

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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: 11.0,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.campaign_rounded,
              color: AppColors.primary,
              size: 20.0,
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Row(
                  key: ValueKey('remote_msg_$_currentIndex'),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.4),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'NEWS FEED',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.black,
                          fontSize: 8.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Expanded(
                      child: Text(
                        message,
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
          ],
        ),
      ),
    );
  }
}

/// A staggered fade-and-slide entrance transition container.
class _FadeSlideEntrance extends StatelessWidget {
  final Widget child;
  final int delay;

  const _FadeSlideEntrance({
    required this.child,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (delay * 80)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0.0, 16.0 * (1.0 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
