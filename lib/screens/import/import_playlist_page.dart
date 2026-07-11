import 'package:flutter/material.dart';
import '../../models/playlist_source.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/cards/playlist_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/dialogs/import_playlist_dialog.dart';

/// A premium, immersive dashboard page for managing loaded IPTV & Sports stream sources.
/// Integrates pre-loaded high-end mock broadcasts, interactive state updates, and standard 
/// glassmorphism design styles.
class ImportPlaylistPage extends StatefulWidget {
  const ImportPlaylistPage({super.key});

  @override
  State<ImportPlaylistPage> createState() => _ImportPlaylistPageState();
}

class _ImportPlaylistPageState extends State<ImportPlaylistPage> {
  // Mock imported playlists list state to demonstrate the beautiful UI interactions
  final List<PlaylistSource> _playlists = [
    PlaylistSource(
      id: '1',
      name: 'FIFA World Cup 2026 Broadcasts (UHD)',
      type: PlaylistType.m3u8Url,
      url: 'https://cdn.nexora.sports/fifa2026/live_feeds.m3u8',
      addedAt: DateTime.now().subtract(const Duration(days: 2)),
      channelCount: 148,
      isActive: true,
    ),
    PlaylistSource(
      id: '2',
      name: 'Nexora Stadium Sports VIP Access',
      type: PlaylistType.xtreamCodes,
      url: 'http://vip.nexora-iptv.club:8080',
      xtreamHost: 'http://vip.nexora-iptv.club:8080',
      xtreamUsername: 'worldcup_guest',
      xtreamPassword: '••••••••••••',
      addedAt: DateTime.now().subtract(const Duration(days: 5)),
      channelCount: 3840,
      isActive: true,
    ),
    PlaylistSource(
      id: '3',
      name: 'Europe Football Leagues HD Feed',
      type: PlaylistType.m3uUrl,
      url: 'https://streams.eurofooty.net/premium_channels.m3u',
      addedAt: DateTime.now().subtract(const Duration(days: 12)),
      channelCount: 65,
      isActive: false,
    ),
  ];

  /// Invokes the custom import dialog and appends any successfully parsed playlist source
  void _openImportDialog() async {
    final result = await showDialog<PlaylistSource>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ImportPlaylistDialog(),
    );

    if (result != null && mounted) {
      final isDuplicate = _playlists.any((p) => p.url.trim().toLowerCase() == result.url.trim().toLowerCase());
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Warning: This playlist/source URL is already imported.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _playlists.insert(0, result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully loaded source: ${result.name}'),
          backgroundColor: AppColors.surface,
          action: SnackBarAction(
            label: 'OK',
            textColor: AppColors.primary,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('STREAM PLAYLISTS'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Import Playlist',
            icon: const Icon(Icons.playlist_add_rounded, size: 28.0, color: AppColors.primary),
            onPressed: _openImportDialog,
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informative Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppDimensions.paddingMD),
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.borderMedium,
                border: Border.all(
                  color: AppColors.borderTranslucent,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 24.0,
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Text(
                      'Load stream URLs or configure your Xtream Codes service credentials. Nexora optimizes media buffering dynamically for football matches.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                        fontSize: 12.0,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACTIVE PLAYLISTS',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    '${_playlists.length} SOURCES',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space8),

            // List of Playlists or Empty State
            Expanded(
              child: _playlists.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingMD),
                        child: EmptyState(
                          icon: Icons.video_collection_outlined,
                          title: 'No Playlists Configured',
                          message: 'To stream live television or games, import an M3U, M3U8 link or configure your Xtream Server.',
                          actionLabel: 'ADD FIRST PLAYLIST',
                          onActionPressed: _openImportDialog,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                      itemCount: _playlists.length,
                      itemBuilder: (context, index) {
                        final item = _playlists[index];
                        return PlaylistCard(
                          playlist: item,
                          onToggleActive: (value) {
                            setState(() {
                              _playlists[index] = item.copyWith(isActive: value);
                            });
                          },
                          onDelete: () {
                            setState(() {
                              _playlists.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Playlist source successfully removed.'),
                                backgroundColor: AppColors.surface,
                              ),
                            );
                          },
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Entering channel grid for ${item.name}...'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
