import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/remote_config_model.dart';
import '../../providers/remote_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class EditBannerPage extends ConsumerStatefulWidget {
  const EditBannerPage({super.key});

  @override
  ConsumerState<EditBannerPage> createState() => _EditBannerPageState();
}

class _EditBannerPageState extends ConsumerState<EditBannerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _homeFormKey = GlobalKey<FormState>();
  final _newsFormKey = GlobalKey<FormState>();

  // Home Banner controllers
  late TextEditingController _statusTagController;
  late TextEditingController _homeTeamController;
  late TextEditingController _awayTeamController;
  late TextEditingController _scoreController;
  late TextEditingController _matchTimeController;
  late TextEditingController _tournamentController;
  late TextEditingController _bannerImageController;

  // News Banner controllers
  late TextEditingController _newsTextController;
  final List<TextEditingController> _alertControllers = [];

  // Posters state helpers
  final TextEditingController _posterChannelIdController = TextEditingController();
  final TextEditingController _posterUrlController = TextEditingController();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _initFieldsOnce(RemoteConfigModel config) {
    if (_initialized) return;
    _initialized = true;

    // Home Banner fields
    _statusTagController = TextEditingController(text: config.homeBanner.statusTag);
    _homeTeamController = TextEditingController(text: config.homeBanner.homeTeam);
    _awayTeamController = TextEditingController(text: config.homeBanner.awayTeam);
    _scoreController = TextEditingController(text: config.homeBanner.scoreText);
    _matchTimeController = TextEditingController(text: config.homeBanner.matchTime);
    _tournamentController = TextEditingController(text: config.homeBanner.tournament);
    _bannerImageController = TextEditingController(text: config.homeBanner.bannerImage);

    // News Banner fields
    _newsTextController = TextEditingController(text: config.newsBanner.text);
    for (final alert in config.newsBanner.newsAlerts) {
      _alertControllers.add(TextEditingController(text: alert));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_initialized) {
      _statusTagController.dispose();
      _homeTeamController.dispose();
      _awayTeamController.dispose();
      _scoreController.dispose();
      _matchTimeController.dispose();
      _tournamentController.dispose();
      _bannerImageController.dispose();
      _newsTextController.dispose();
      for (final controller in _alertControllers) {
        controller.dispose();
      }
    }
    _posterChannelIdController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveHomeBanner(RemoteConfigModel config) async {
    if (!_homeFormKey.currentState!.validate()) return;

    final updatedHomeBanner = HomeBannerConfig(
      statusTag: _statusTagController.text.trim(),
      homeTeam: _homeTeamController.text.trim(),
      awayTeam: _awayTeamController.text.trim(),
      scoreText: _scoreController.text.trim(),
      matchTime: _matchTimeController.text.trim(),
      tournament: _tournamentController.text.trim(),
      bannerImage: _bannerImageController.text.trim(),
    );

    final updatedConfig = RemoteConfigModel(
      appConfig: config.appConfig,
      homeBanner: updatedHomeBanner,
      newsBanner: config.newsBanner,
      announcement: config.announcement,
      categories: config.categories,
      playlists: config.playlists,
      epgUrls: config.epgUrls,
      channelLogos: config.channelLogos,
      posterImages: config.posterImages,
      featuredChannels: config.featuredChannels,
      hiddenChannels: config.hiddenChannels,
    );

    await ref.read(remoteConfigNotifierProvider.notifier).updateConfig(updatedConfig);
    _showSuccessSnackBar('Home Match Banner updated successfully!');
  }

  Future<void> _saveNewsBanner(RemoteConfigModel config) async {
    if (!_newsFormKey.currentState!.validate()) return;

    final List<String> alerts = _alertControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final updatedNewsBanner = NewsBannerConfig(
      text: _newsTextController.text.trim(),
      newsAlerts: alerts,
    );

    final updatedConfig = RemoteConfigModel(
      appConfig: config.appConfig,
      homeBanner: config.homeBanner,
      newsBanner: updatedNewsBanner,
      announcement: config.announcement,
      categories: config.categories,
      playlists: config.playlists,
      epgUrls: config.epgUrls,
      channelLogos: config.channelLogos,
      posterImages: config.posterImages,
      featuredChannels: config.featuredChannels,
      hiddenChannels: config.hiddenChannels,
    );

    await ref.read(remoteConfigNotifierProvider.notifier).updateConfig(updatedConfig);
    _showSuccessSnackBar('News ticker configuration saved!');
  }

  Future<void> _addOrUpdatePoster(RemoteConfigModel config) async {
    final chId = _posterChannelIdController.text.trim();
    final url = _posterUrlController.text.trim();

    if (chId.isEmpty || url.isEmpty) {
      _showErrorSnackBar('Please enter both Channel ID and Poster Image URL');
      return;
    }

    final newPosters = Map<String, String>.from(config.posterImages);
    newPosters[chId] = url;

    final updatedConfig = RemoteConfigModel(
      appConfig: config.appConfig,
      homeBanner: config.homeBanner,
      newsBanner: config.newsBanner,
      announcement: config.announcement,
      categories: config.categories,
      playlists: config.playlists,
      epgUrls: config.epgUrls,
      channelLogos: config.channelLogos,
      posterImages: newPosters,
      featuredChannels: config.featuredChannels,
      hiddenChannels: config.hiddenChannels,
    );

    await ref.read(remoteConfigNotifierProvider.notifier).updateConfig(updatedConfig);
    _posterChannelIdController.clear();
    _posterUrlController.clear();
    _showSuccessSnackBar('Poster successfully registered!');
  }

  Future<void> _deletePoster(RemoteConfigModel config, String key) async {
    final newPosters = Map<String, String>.from(config.posterImages);
    newPosters.remove(key);

    final updatedConfig = RemoteConfigModel(
      appConfig: config.appConfig,
      homeBanner: config.homeBanner,
      newsBanner: config.newsBanner,
      announcement: config.announcement,
      categories: config.categories,
      playlists: config.playlists,
      epgUrls: config.epgUrls,
      channelLogos: config.channelLogos,
      posterImages: newPosters,
      featuredChannels: config.featuredChannels,
      hiddenChannels: config.hiddenChannels,
    );

    await ref.read(remoteConfigNotifierProvider.notifier).updateConfig(updatedConfig);
    _showSuccessSnackBar('Poster removed successfully.');
  }

  void _showSuccessSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.error,
      ),
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
          'PROMOTIONS & BANNERS',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.black, letterSpacing: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.muted,
          tabs: const [
            Tab(icon: Icon(Icons.sports_soccer_rounded), text: 'Home Match'),
            Tab(icon: Icon(Icons.newspaper_rounded), text: 'News Ticker'),
            Tab(icon: Icon(Icons.style_rounded), text: 'Channel Posters'),
          ],
        ),
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        data: (config) {
          _initFieldsOnce(config);

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Home Match Banner
              _buildHomeMatchTab(config),

              // Tab 2: News Ticker
              _buildNewsTickerTab(config),

              // Tab 3: Channel Posters
              _buildPostersTab(config),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHomeMatchTab(RemoteConfigModel config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Form(
        key: _homeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Card
            const Text(
              'LIVE PREVIEW',
              style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: AppColors.surface,
                image: _bannerImageController.text.trim().isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(_bannerImageController.text.trim()),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.65), BlendMode.dstATop),
                      )
                    : null,
                border: Border.all(color: AppColors.borderTranslucent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          _statusTagController.text.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        _matchTimeController.text,
                        style: AppTextStyles.matchTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    _tournamentController.text.toUpperCase(),
                    style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: 11.0, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _homeTeamController.text,
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _scoreController.text,
                          style: AppTextStyles.scoreText,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _awayTeamController.text,
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Form inputs
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.borderTranslucent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MATCH METADATA',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _tournamentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Tournament Title'),
                    onChanged: (v) => setState(() {}),
                    validator: (v) => v == null || v.isEmpty ? 'Tournament name is required' : null,
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _statusTagController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration('Status Tag (e.g. LIVE)'),
                          onChanged: (v) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: TextFormField(
                          controller: _matchTimeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration('Match Timer (e.g. 74\')'),
                          onChanged: (v) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 32.0),
                  Text(
                    'TEAMS & LIVE STATE',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _homeTeamController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration('Home Team'),
                          onChanged: (v) => setState(() {}),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: TextFormField(
                          controller: _awayTeamController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration('Away Team'),
                          onChanged: (v) => setState(() {}),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _scoreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Current Score (e.g. 2 - 1)'),
                    onChanged: (v) => setState(() {}),
                  ),
                  const Divider(color: AppColors.borderTranslucent, height: 32.0),
                  Text(
                    'DESIGN & COVER',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _bannerImageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Banner Background Image URL'),
                    onChanged: (v) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () => _saveHomeBanner(config),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                child: const Text('COMMIT MATCH BANNER', style: TextStyle(fontWeight: FontWeight.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsTickerTab(RemoteConfigModel config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Form(
        key: _newsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.borderTranslucent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRIMARY NEWS FLASH',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'This is the prominent single news message displayed at the top of the Home layout.',
                    style: TextStyle(color: AppColors.muted, fontSize: 11.0),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _newsTextController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Headline Text'),
                    validator: (v) => v == null || v.isEmpty ? 'Headline is required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            
            // Scrolling Ticker alerts list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SCROLLING TICKER ALERTS',
                  style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _alertControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18.0, color: AppColors.primary),
                  label: const Text('ADD ALERT', style: TextStyle(color: AppColors.primary, fontSize: 12.0, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            if (_alertControllers.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppColors.borderTranslucent, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Text('No scrolling alerts. Click ADD ALERT to populate.', style: TextStyle(color: AppColors.muted, fontSize: 12.0)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _alertControllers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.borderTranslucent),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          radius: 14.0,
                          child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary, fontSize: 11.0, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: TextFormField(
                            controller: _alertControllers[index],
                            style: const TextStyle(color: Colors.white, fontSize: 13.0),
                            decoration: const InputDecoration(
                              hintText: 'Enter scrolling announcement details...',
                              hintStyle: TextStyle(color: Colors.white24),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20.0),
                          onPressed: () {
                            setState(() {
                              _alertControllers[index].dispose();
                              _alertControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () => _saveNewsBanner(config),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                child: const Text('SAVE NEWS TICKER', style: TextStyle(fontWeight: FontWeight.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostersTab(RemoteConfigModel config) {
    final posterList = config.posterImages.entries.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Registration Form
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.borderTranslucent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REGISTER OR EDIT CHANNEL POSTER',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _posterChannelIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('Channel ID (matches channel name or id in M3U)'),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _posterUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('Poster HD Graphic Image URL'),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  height: 44.0,
                  child: ElevatedButton.icon(
                    onPressed: () => _addOrUpdatePoster(config),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 18.0),
                    label: const Text('REGISTER POSTER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          const Text(
            'ACTIVE CHANNEL POSTERS',
            style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10.0),

          if (posterList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppColors.borderTranslucent, width: 0.5),
              ),
              alignment: Alignment.center,
              child: Text('No custom poster mappings found.', style: TextStyle(color: AppColors.muted, fontSize: 13.0)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posterList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final entry = posterList[index];
                return Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: AppColors.borderTranslucent),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: Image.network(
                          entry.value,
                          width: 50.0,
                          height: 70.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            width: 50.0,
                            height: 70.0,
                            color: Colors.white10,
                            child: const Icon(Icons.image_not_supported_rounded, color: AppColors.muted, size: 22.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              entry.value,
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
                            icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20.0),
                            onPressed: () {
                              setState(() {
                                _posterChannelIdController.text = entry.key;
                                _posterUrlController.text = entry.value;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20.0),
                            onPressed: () => _deletePoster(config, entry.key),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13.0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderTranslucent),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(10.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
