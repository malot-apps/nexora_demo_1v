import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/remote_config_model.dart';
import '../../providers/remote_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import 'edit_playlist_page.dart';
import 'edit_category_page.dart';
import 'edit_banner_page.dart';
import 'edit_announcement_page.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  // Add dialog controller helpers
  final TextEditingController _epgUrlController = TextEditingController();
  final TextEditingController _logoChannelController = TextEditingController();
  final TextEditingController _logoUrlController = TextEditingController();
  final TextEditingController _featuredChannelController = TextEditingController();
  final TextEditingController _maintenanceMsgController = TextEditingController();
  final TextEditingController _appVersionController = TextEditingController();

  @override
  void dispose() {
    _epgUrlController.dispose();
    _logoChannelController.dispose();
    _logoUrlController.dispose();
    _featuredChannelController.dispose();
    _maintenanceMsgController.dispose();
    _appVersionController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  // --- GENERAL CONFIG UPDATE HELPER ---
  Future<void> _updateFullConfig(RemoteConfigModel updated) async {
    await ref.read(remoteConfigNotifierProvider.notifier).updateConfig(updated);
  }

  // --- PLAYLIST OPERATIONS ---
  Future<void> _deletePlaylist(RemoteConfigModel config, String id) async {
    final updatedList = config.playlists.where((p) => p.id != id).toList();
    final updated = _copyConfigWith(config, playlists: updatedList);
    await _updateFullConfig(updated);
    _showSnackBar('Playlist removed.');
  }

  Future<void> _togglePlaylistActive(RemoteConfigModel config, String id, bool active) async {
    final updatedList = config.playlists.map((p) {
      if (p.id == id) {
        return RemotePlaylistConfig(id: p.id, name: p.name, url: p.url, type: p.type, isActive: active);
      }
      return p;
    }).toList();
    final updated = _copyConfigWith(config, playlists: updatedList);
    await _updateFullConfig(updated);
    _showSnackBar('Playlist active status adjusted.');
  }

  Future<void> _movePlaylistOrder(RemoteConfigModel config, int oldIndex, int newIndex) async {
    if (newIndex < 0 || newIndex >= config.playlists.length) return;
    final updatedList = List<RemotePlaylistConfig>.from(config.playlists);
    final playlist = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, playlist);
    final updated = _copyConfigWith(config, playlists: updatedList);
    await _updateFullConfig(updated);
    _showSnackBar('Playlist order re-sequenced.');
  }

  // --- CATEGORY OPERATIONS ---
  Future<void> _deleteCategory(RemoteConfigModel config, String id) async {
    final updatedList = config.categories.where((c) => c.id != id).toList();
    final updated = _copyConfigWith(config, categories: updatedList);
    await _updateFullConfig(updated);
    _showSnackBar('Category deleted.');
  }

  Future<void> _reorderCategories(RemoteConfigModel config, int oldIndex, int newIndex) async {
    if (newIndex < 0 || newIndex >= config.categories.length) return;
    final updatedList = List<RemoteCategoryConfig>.from(config.categories);
    final category = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, category);
    
    // Auto-update sort order parameters based on new index
    for (int i = 0; i < updatedList.length; i++) {
      final c = updatedList[i];
      updatedList[i] = RemoteCategoryConfig(id: c.id, name: c.name, image: c.image, sortOrder: i + 1);
    }

    final updated = _copyConfigWith(config, categories: updatedList);
    await _updateFullConfig(updated);
    _showSnackBar('Categories reordered and sorted.');
  }

  // --- EPG OPERATIONS ---
  Future<void> _addEpgSource(RemoteConfigModel config) async {
    final url = _epgUrlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar('EPG URL cannot be empty', isError: true);
      return;
    }
    final updatedList = List<RemoteEpgConfig>.from(config.epgUrls);
    updatedList.add(RemoteEpgConfig(url: url, isEnabled: true, isDefault: updatedList.isEmpty));
    final updated = _copyConfigWith(config, epgUrls: updatedList);
    await _updateFullConfig(updated);
    _epgUrlController.clear();
    _showSnackBar('EPG Source added.');
  }

  Future<void> _deleteEpgSource(RemoteConfigModel config, String url) async {
    final updatedList = config.epgUrls.where((e) => e.url != url).toList();
    final updated = _copyConfigWith(config, epgUrls: updatedList);
    await _updateFullConfig(updated);
    _showSnackBar('EPG Source removed.');
  }

  Future<void> _toggleEpgEnabled(RemoteConfigModel config, String url, bool enabled) async {
    final updatedList = config.epgUrls.map((e) {
      if (e.url == url) {
        return RemoteEpgConfig(url: e.url, isEnabled: enabled, isDefault: e.isDefault);
      }
      return e;
    }).toList();
    final updated = _copyConfigWith(config, epgUrls: updatedList);
    await _updateFullConfig(updated);
    _showSnackBar('EPG source status modified.');
  }

  Future<void> _setDefaultEpg(RemoteConfigModel config, String url) async {
    final updatedList = config.epgUrls.map((e) {
      return RemoteEpgConfig(url: e.url, isEnabled: e.isEnabled, isDefault: e.url == url);
    }).toList();
    final updated = _copyConfigWith(config, epgUrls: updatedList);
    await _updateFullConfig(updated);
    _showSnackBar('Default EPG source mapped.');
  }

  // --- CHANNEL LOGO OPERATIONS ---
  Future<void> _addOrUpdateLogo(RemoteConfigModel config) async {
    final channel = _logoChannelController.text.trim();
    final url = _logoUrlController.text.trim();
    if (channel.isEmpty || url.isEmpty) {
      _showSnackBar('Please enter both Channel ID and Logo URL', isError: true);
      return;
    }
    final updatedLogos = Map<String, String>.from(config.channelLogos);
    updatedLogos[channel] = url;
    final updated = _copyConfigWith(config, channelLogos: updatedLogos);
    await _updateFullConfig(updated);
    _logoChannelController.clear();
    _logoUrlController.clear();
    _showSnackBar('Channel logo mapped.');
  }

  Future<void> _deleteLogo(RemoteConfigModel config, String channel) async {
    final updatedLogos = Map<String, String>.from(config.channelLogos);
    updatedLogos.remove(channel);
    final updated = _copyConfigWith(config, channelLogos: updatedLogos);
    await _updateFullConfig(updated);
    _showSnackBar('Logo override removed.');
  }

  // --- FEATURED CHANNELS ---
  Future<void> _toggleFeaturedChannel(RemoteConfigModel config, String channelId) async {
    final updatedFeatured = List<String>.from(config.featuredChannels);
    if (updatedFeatured.contains(channelId)) {
      updatedFeatured.remove(channelId);
      _showSnackBar('Channel removed from Featured Feed.');
    } else {
      updatedFeatured.add(channelId);
      _showSnackBar('Channel pinned to Featured Feed.');
    }
    final updated = _copyConfigWith(config, featuredChannels: updatedFeatured);
    await _updateFullConfig(updated);
  }

  Future<void> _addFeaturedChannel(RemoteConfigModel config) async {
    final chId = _featuredChannelController.text.trim();
    if (chId.isEmpty) return;
    if (config.featuredChannels.contains(chId)) {
      _showSnackBar('Channel is already featured', isError: true);
      return;
    }
    final updatedFeatured = List<String>.from(config.featuredChannels)..add(chId);
    final updated = _copyConfigWith(config, featuredChannels: updatedFeatured);
    await _updateFullConfig(updated);
    _featuredChannelController.clear();
    _showSnackBar('Channel added to Featured List.');
  }

  // --- MAINTENANCE OPERATIONS ---
  Future<void> _toggleMaintenance(RemoteConfigModel config, bool val) async {
    final updatedAppConfig = AppConfig(
      version: config.appConfig.version,
      maintenanceMode: val,
      maintenanceMessage: _maintenanceMsgController.text.isEmpty ? config.appConfig.maintenanceMessage : _maintenanceMsgController.text.trim(),
    );
    final updated = _copyConfigWith(config, appConfig: updatedAppConfig);
    await _updateFullConfig(updated);
    _showSnackBar(val ? 'Maintenance Mode ACTIVATED!' : 'Maintenance Mode disabled.');
  }

  Future<void> _saveMaintenanceMessage(RemoteConfigModel config) async {
    final updatedAppConfig = AppConfig(
      version: config.appConfig.version,
      maintenanceMode: config.appConfig.maintenanceMode,
      maintenanceMessage: _maintenanceMsgController.text.trim(),
    );
    final updated = _copyConfigWith(config, appConfig: updatedAppConfig);
    await _updateFullConfig(updated);
    _showSnackBar('Maintenance bulletin compiled.');
  }

  // --- APP VERSION CONTROL ---
  Future<void> _saveAppVersion(RemoteConfigModel config) async {
    final v = _appVersionController.text.trim();
    if (v.isEmpty) return;
    final updatedAppConfig = AppConfig(
      version: v,
      maintenanceMode: config.appConfig.maintenanceMode,
      maintenanceMessage: config.appConfig.maintenanceMessage,
    );
    final updated = _copyConfigWith(config, appConfig: updatedAppConfig);
    await _updateFullConfig(updated);
    _showSnackBar('System version bumped to $v.');
  }

  Future<void> _resetToDefaults() async {
    final updated = RemoteConfigModel.fallback();
    await _updateFullConfig(updated);
    _showSnackBar('All configurations reset to static fallbacks.');
  }

  // --- HELPER TO COPY CONFIG MODEL ---
  RemoteConfigModel _copyConfigWith(
    RemoteConfigModel o, {
    AppConfig? appConfig,
    HomeBannerConfig? homeBanner,
    NewsBannerConfig? newsBanner,
    AnnouncementConfig? announcement,
    List<RemoteCategoryConfig>? categories,
    List<RemotePlaylistConfig>? playlists,
    List<RemoteEpgConfig>? epgUrls,
    Map<String, String>? channelLogos,
    Map<String, String>? posterImages,
    List<String>? featuredChannels,
    List<String>? hiddenChannels,
  }) {
    return RemoteConfigModel(
      appConfig: appConfig ?? o.appConfig,
      homeBanner: homeBanner ?? o.homeBanner,
      newsBanner: newsBanner ?? o.newsBanner,
      announcement: announcement ?? o.announcement,
      categories: categories ?? o.categories,
      playlists: playlists ?? o.playlists,
      epgUrls: epgUrls ?? o.epgUrls,
      channelLogos: channelLogos ?? o.channelLogos,
      posterImages: posterImages ?? o.posterImages,
      featuredChannels: featuredChannels ?? o.featuredChannels,
      hiddenChannels: hiddenChannels ?? o.hiddenChannels,
    );
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(remoteConfigNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'NEXORA ADMIN SUITE',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.black, letterSpacing: 1.5, color: AppColors.primary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_rounded, color: AppColors.error),
            tooltip: 'Reset config to defaults',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('RESET SYSTEM STATE?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  content: const Text('This will overwrite all active adjustments with safe, built-in defaults. Proceed?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: AppColors.muted))),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetToDefaults();
                      },
                      child: const Text('RESET ALL', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Initialization Error: $err', style: const TextStyle(color: Colors.white))),
        data: (config) {
          // Sync localized text fields if un-populated
          if (_maintenanceMsgController.text.isEmpty) {
            _maintenanceMsgController.text = config.appConfig.maintenanceMessage;
          }
          if (_appVersionController.text.isEmpty) {
            _appVersionController.text = config.appConfig.version;
          }

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            children: [
              _buildSectionHeader('CORE REPOSITORIES & NETWORKS', Icons.cloud_queue_rounded),
              _buildPlaylistsSection(config),
              const SizedBox(height: 16.0),
              _buildCategoriesSection(config),
              const SizedBox(height: 16.0),
              _buildEpgSection(config),

              const SizedBox(height: 24.0),
              _buildSectionHeader('MATCHDAY & NEWSCASTS', Icons.campaign_rounded),
              _buildHomeBannerSection(config),
              const SizedBox(height: 16.0),
              _buildNewsTickerSection(config),
              const SizedBox(height: 16.0),
              _buildAnnouncementSection(config),

              const SizedBox(height: 24.0),
              _buildSectionHeader('CHANNELS & DESIGN OVERRIDES', Icons.color_lens_outlined),
              _buildChannelLogosSection(config),
              const SizedBox(height: 16.0),
              _buildFeaturedChannelsSection(config),
              const SizedBox(height: 16.0),
              _buildPostersSection(config),

              const SizedBox(height: 24.0),
              _buildSectionHeader('INFRASTRUCTURE CONTROL', Icons.developer_mode_rounded),
              _buildMaintenanceSection(config),
              const SizedBox(height: 16.0),
              _buildAppInfoSection(config),
              const SizedBox(height: 32.0),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18.0, color: AppColors.primary),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  // --- SECTION WIDGETS ---

  Widget _buildPlaylistsSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'M3U PLAYLISTS & XTREAM FEEDS',
      subtitle: '${config.playlists.length} feeds configured',
      icon: Icons.list_alt_rounded,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: config.playlists.length,
            separatorBuilder: (context, idx) => const Divider(color: AppColors.borderTranslucent, height: 1.0),
            itemBuilder: (context, index) {
              final playlist = config.playlists[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                playlist.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  playlist.type.toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary, fontSize: 9.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            playlist.url,
                            style: TextStyle(color: AppColors.muted, fontSize: 11.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white60, size: 18.0),
                          onPressed: index > 0 ? () => _movePlaylistOrder(config, index, index - 1) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward_rounded, color: Colors.white60, size: 18.0),
                          onPressed: index < config.playlists.length - 1 ? () => _movePlaylistOrder(config, index, index + 1) : null,
                        ),
                        Switch(
                          value: playlist.isActive,
                          activeColor: AppColors.primary,
                          onChanged: (v) => _togglePlaylistActive(config, playlist.id, v),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.0),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditPlaylistPage(playlist: playlist))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20.0),
                          onPressed: () => _deletePlaylist(config, playlist.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            height: 38.0,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditPlaylistPage())),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 18.0),
              label: const Text('ADD NEW PLAYLIST', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'IPTV VIEW CATEGORIES',
      subtitle: '${config.categories.length} segments managed',
      icon: Icons.category_outlined,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: config.categories.length,
            separatorBuilder: (context, idx) => const Divider(color: AppColors.borderTranslucent, height: 1.0),
            itemBuilder: (context, index) {
              final cat = config.categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: cat.image.isNotEmpty
                          ? Image.network(cat.image, width: 32.0, height: 32.0, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 32.0, height: 32.0, color: Colors.white10))
                          : Container(width: 32.0, height: 32.0, color: Colors.white10),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0)),
                          const SizedBox(height: 2.0),
                          Text('ID: ${cat.id} • Order: ${cat.sortOrder}', style: TextStyle(color: AppColors.muted, fontSize: 11.0)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white60, size: 18.0),
                          onPressed: index > 0 ? () => _reorderCategories(config, index, index - 1) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward_rounded, color: Colors.white60, size: 18.0),
                          onPressed: index < config.categories.length - 1 ? () => _reorderCategories(config, index, index + 1) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.0),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditCategoryPage(category: cat))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20.0),
                          onPressed: () => _deleteCategory(config, cat.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            height: 38.0,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditCategoryPage())),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 18.0),
              label: const Text('ADD NEW CATEGORY', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpgSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'ELECTRONIC PROGRAM GUIDE (EPG)',
      subtitle: '${config.epgUrls.length} active XMLTV directories',
      icon: Icons.grid_on_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: config.epgUrls.length,
            separatorBuilder: (context, idx) => const Divider(color: AppColors.borderTranslucent, height: 1.0),
            itemBuilder: (context, index) {
              final epg = config.epgUrls[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  epg.url,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.0),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (epg.isDefault) ...[
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                  decoration: BoxDecoration(color: AppColors.tertiary.withOpacity(0.15), borderRadius: BorderRadius.circular(4.0)),
                                  child: const Text('DEFAULT', style: TextStyle(color: AppColors.tertiary, fontSize: 8.0, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Row(
                      children: [
                        if (!epg.isDefault)
                          TextButton(
                            onPressed: () => _setDefaultEpg(config, epg.url),
                            child: const Text('SET DEFAULT', style: TextStyle(color: AppColors.primary, fontSize: 11.0, fontWeight: FontWeight.bold)),
                          ),
                        Switch(
                          value: epg.isEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (v) => _toggleEpgEnabled(config, epg.url, v),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20.0),
                          onPressed: () => _deleteEpgSource(config, epg.url),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _epgUrlController,
                  style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  decoration: InputDecoration(
                    hintText: 'https://site.com/epg.xml',
                    hintStyle: const TextStyle(color: Colors.white24),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.borderTranslucent), borderRadius: BorderRadius.circular(8.0)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primary), borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              SizedBox(
                height: 40.0,
                child: ElevatedButton(
                  onPressed: () => _addEpgSource(config),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                  child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBannerSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'LIVE SPORTS MATCH BANNER',
      subtitle: '${config.homeBanner.homeTeam} vs ${config.homeBanner.awayTeam} (${config.homeBanner.scoreText})',
      icon: Icons.sports_soccer_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4.0)),
                child: Text(config.homeBanner.statusTag.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9.0, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10.0),
              Text(config.homeBanner.tournament, style: const TextStyle(color: Colors.white70, fontSize: 12.0)),
            ],
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            height: 38.0,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditBannerPage())),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
              icon: const Icon(Icons.edit_rounded, size: 16.0),
              label: const Text('EDIT MATCH BANNER & DESIGN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTickerSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'GLOBAL NEWS TICKER ALERTS',
      subtitle: '${config.newsBanner.newsAlerts.length} ticker events broadcasting',
      icon: Icons.rss_feed_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Headline: "${config.newsBanner.text}"',
            style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            height: 38.0,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditBannerPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
              icon: const Icon(Icons.edit_rounded, size: 16.0),
              label: const Text('MANAGE TICKER BROADCASTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'SYSTEM BULLETIN ANNOUNCEMENT',
      subtitle: config.announcement.showAnnouncement ? 'Active Announcement Visible' : 'Bulletin System Dormant',
      icon: Icons.campaign_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Header: "${config.announcement.title}"',
            style: const TextStyle(color: Colors.white70, fontSize: 13.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            config.announcement.message,
            style: TextStyle(color: AppColors.muted, fontSize: 11.0),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            height: 38.0,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditAnnouncementPage())),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
              icon: const Icon(Icons.edit_rounded, size: 16.0),
              label: const Text('MANAGE SYSTEM BULLETIN & SCHEDULER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelLogosSection(RemoteConfigModel config) {
    final logoList = config.channelLogos.entries.toList();

    return _buildDashboardCard(
      title: 'CHANNEL LOGO DICTIONARY',
      subtitle: '${logoList.length} override markers defined',
      icon: Icons.image_search_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logoList.isNotEmpty)
            Container(
              maxHeight: 180.0,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8.0), border: Border.all(color: AppColors.borderTranslucent)),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: logoList.length,
                separatorBuilder: (context, idx) => const Divider(color: AppColors.borderTranslucent, height: 1.0),
                itemBuilder: (context, index) {
                  final override = logoList[index];
                  return ListTile(
                    dense: true,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(override.value, width: 24.0, height: 24.0, errorBuilder: (c, e, s) => const Icon(Icons.broken_image_rounded, size: 16.0)),
                    ),
                    title: Text(override.key.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(override.value, style: const TextStyle(color: AppColors.muted, fontSize: 10.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18.0),
                      onPressed: () => _deleteLogo(config, override.key),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _logoChannelController,
                  style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  decoration: _buildMiniInputDecoration('Channel ID (matches M3U name)'),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextFormField(
                  controller: _logoUrlController,
                  style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  decoration: _buildMiniInputDecoration('Direct Logo PNG/SVG URL'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            height: 38.0,
            child: ElevatedButton.icon(
              onPressed: () => _addOrUpdateLogo(config),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 16.0),
              label: const Text('MAP OVERRIDE LOGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedChannelsSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'FEATURED CHANNELS MATRIX',
      subtitle: '${config.featuredChannels.length} streams pinned to carousel',
      icon: Icons.star_border_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: config.featuredChannels.map((channelId) {
              return Chip(
                backgroundColor: AppColors.primary.withOpacity(0.12),
                label: Text(channelId.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 11.0, fontWeight: FontWeight.bold)),
                deleteIcon: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16.0),
                onDeleted: () => _toggleFeaturedChannel(config, channelId),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: const BorderSide(color: AppColors.primary, width: 0.5)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _featuredChannelController,
                  style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  decoration: InputDecoration(
                    hintText: 'Enter Channel ID (e.g. sky_sports)...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.borderTranslucent), borderRadius: BorderRadius.circular(8.0)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primary), borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              SizedBox(
                height: 40.0,
                child: ElevatedButton(
                  onPressed: () => _addFeaturedChannel(config),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                  child: const Text('PIN STREAM', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostersSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'CHANNEL POSTER ARTWORK MAPPING',
      subtitle: '${config.posterImages.length} HD custom posters configured',
      icon: Icons.add_photo_alternate_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Displays custom visual posters for IPTV streams rather than simple logos.',
            style: TextStyle(color: AppColors.muted, fontSize: 11.0),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            height: 38.0,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditBannerPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
              icon: const Icon(Icons.style_outlined, size: 16.0),
              label: const Text('MANAGE POSTERS SUITE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection(RemoteConfigModel config) {
    final isActive = config.appConfig.maintenanceMode;

    return _buildDashboardCard(
      title: 'MAINTENANCE SHUTDOWN CONTROL',
      subtitle: isActive ? 'MAINTENANCE SYSTEM LIVE!' : 'Production servers fully responsive',
      icon: Icons.gavel_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lock Production Servers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4.0),
                  Text('Toggles system-wide roadblock screen', style: TextStyle(color: AppColors.muted, fontSize: 11.0)),
                ],
              ),
              Switch(
                value: isActive,
                activeColor: AppColors.error,
                onChanged: (v) => _toggleMaintenance(config, v),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _maintenanceMsgController,
            style: const TextStyle(color: Colors.white, fontSize: 13.0),
            maxLines: 2,
            decoration: _buildMiniInputDecoration('Undergoing Scheduled Maintenance Message...'),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            height: 38.0,
            child: ElevatedButton.icon(
              onPressed: () => _saveMaintenanceMessage(config),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error.withOpacity(0.15), foregroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), side: const BorderSide(color: AppColors.error, width: 0.5)),
              icon: const Icon(Icons.save_rounded, size: 16.0),
              label: const Text('COMPILE LOCK BULLETIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(RemoteConfigModel config) {
    return _buildDashboardCard(
      title: 'SYSTEM METADATA & VERSION CONTROL',
      subtitle: 'Version active: ${config.appConfig.version}',
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _appVersionController,
                  style: const TextStyle(color: Colors.white, fontSize: 13.0),
                  decoration: _buildMiniInputDecoration('Target Version (e.g. 1.4.0-RC1)'),
                ),
              ),
              const SizedBox(width: 10.0),
              SizedBox(
                height: 40.0,
                child: ElevatedButton(
                  onPressed: () => _saveAppVersion(config),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                  child: const Text('BUMP VERSION', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- CARD CONTAINER DESIGN PATTERN ---
  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.borderTranslucent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.0, color: AppColors.primary),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.black, fontSize: 13.0, letterSpacing: 0.5)),
                    const SizedBox(height: 2.0),
                    Text(subtitle, style: TextStyle(color: AppColors.muted, fontSize: 11.0)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderTranslucent, height: 24.0),
          child,
        ],
      ),
    );
  }

  InputDecoration _buildMiniInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12.0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.borderTranslucent), borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primary), borderRadius: BorderRadius.circular(8.0)),
    );
  }
}
