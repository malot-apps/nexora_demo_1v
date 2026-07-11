import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/remote_config_model.dart';
import '../../providers/remote_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class EditPlaylistPage extends ConsumerStatefulWidget {
  final RemotePlaylistConfig? playlist;

  const EditPlaylistPage({
    super.key,
    this.playlist,
  });

  @override
  ConsumerState<EditPlaylistPage> createState() => _EditPlaylistPageState();
}

class _EditPlaylistPageState extends ConsumerState<EditPlaylistPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late String _type;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist?.name ?? '');
    _urlController = TextEditingController(text: widget.playlist?.url ?? '');
    _type = widget.playlist?.type ?? 'm3u';
    _isActive = widget.playlist?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _savePlaylist() async {
    if (!_formKey.currentState!.validate()) return;

    final configAsync = ref.read(remoteConfigNotifierProvider);
    configAsync.whenData((config) async {
      final currentPlaylists = List<RemotePlaylistConfig>.from(config.playlists);
      
      if (widget.playlist == null) {
        // Adding new playlist
        final newPlaylist = RemotePlaylistConfig(
          id: 'playlist_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          url: _urlController.text.trim(),
          type: _type,
          isActive: _isActive,
        );
        currentPlaylists.add(newPlaylist);
      } else {
        // Editing existing playlist
        final index = currentPlaylists.indexWhere((p) => p.id == widget.playlist!.id);
        if (index != -1) {
          currentPlaylists[index] = RemotePlaylistConfig(
            id: widget.playlist!.id,
            name: _nameController.text.trim(),
            url: _urlController.text.trim(),
            type: _type,
            isActive: _isActive,
          );
        }
      }

      // Reassemble config model
      final updatedConfig = RemoteConfigModel(
        appConfig: config.appConfig,
        homeBanner: config.homeBanner,
        newsBanner: config.newsBanner,
        announcement: config.announcement,
        categories: config.categories,
        playlists: currentPlaylists,
        epgUrls: config.epgUrls,
        channelLogos: config.channelLogos,
        posterImages: config.posterImages,
        featuredChannels: config.featuredChannels,
        hiddenChannels: config.hiddenChannels,
      );

      // Instantly update local preview & scaffold remote write
      await ref.read(remoteConfigNotifierProvider.notifier).updateConfig(updatedConfig);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.playlist == null ? 'Playlist added successfully!' : 'Playlist updated successfully!',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.playlist != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'EDIT PLAYLIST' : 'ADD PLAYLIST',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.black, letterSpacing: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Form(
            key: _formKey,
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
                        'PLAYLIST INFORMATION',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Playlist Name',
                          labelStyle: const TextStyle(color: AppColors.muted),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.borderTranslucent),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.error),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.error),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a playlist name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _urlController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Playlist URL or File Path',
                          labelStyle: const TextStyle(color: AppColors.muted),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.borderTranslucent),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.error),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.error),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a playlist URL or path';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Playlist Type',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: _type,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(color: Colors.white),
                            underline: Container(),
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                            items: const [
                              DropdownMenuItem(value: 'm3u', child: Text('M3U / M3U8 Playlist')),
                              DropdownMenuItem(value: 'xtream', child: Text('Xtream Codes Broadcast')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _type = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderTranslucent, height: 32.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active Status',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Enable or disable streaming access',
                                style: TextStyle(color: AppColors.muted, fontSize: 11.0),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isActive,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: _savePlaylist,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4.0,
                    ),
                    child: Text(
                      isEditing ? 'COMMIT UPDATES' : 'CREATE PLAYLIST',
                      style: const TextStyle(fontWeight: FontWeight.black, fontSize: 15.0, letterSpacing: 0.5),
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
}
