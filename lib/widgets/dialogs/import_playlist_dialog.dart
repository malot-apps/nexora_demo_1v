import 'package:flutter/material.dart';
import '../../models/playlist_source.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A premium, highly polished dialog for importing IPTV playlists.
/// Supports M3U, M3U8, TS, PHP, MP4 URLs, and Xtream Codes API integrations.
class ImportPlaylistDialog extends StatefulWidget {
  const ImportPlaylistDialog({super.key});

  @override
  State<ImportPlaylistDialog> createState() => _ImportPlaylistDialogState();
}

class _ImportPlaylistDialogState extends State<ImportPlaylistDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  
  // Xtream Codes controllers
  final _xtreamHostController = TextEditingController();
  final _xtreamUsernameController = TextEditingController();
  final _xtreamPasswordController = TextEditingController();

  // Selected URL type for URL Import
  PlaylistType _selectedUrlType = PlaylistType.m3uUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _urlController.dispose();
    _xtreamHostController.dispose();
    _xtreamUsernameController.dispose();
    _xtreamPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final isUrlTab = _tabController.index == 0;

    PlaylistSource result;

    if (isUrlTab) {
      result = PlaylistSource(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: _selectedUrlType,
        url: _urlController.text.trim(),
        addedAt: DateTime.now(),
        channelCount: _getMockChannelCount(_selectedUrlType),
        isActive: true,
      );
    } else {
      result = PlaylistSource(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.isEmpty ? 'Xtream Source' : name,
        type: PlaylistType.xtreamCodes,
        url: _xtreamHostController.text.trim(),
        xtreamHost: _xtreamHostController.text.trim(),
        xtreamUsername: _xtreamUsernameController.text.trim(),
        xtreamPassword: _xtreamPasswordController.text.trim(),
        addedAt: DateTime.now(),
        channelCount: 3820, // Premium default mock channels for premium UI demonstration
        isActive: true,
      );
    }

    Navigator.of(context).pop(result);
  }

  int _getMockChannelCount(PlaylistType type) {
    switch (type) {
      case PlaylistType.m3uUrl:
        return 1250;
      case PlaylistType.m3u8Url:
        return 240;
      case PlaylistType.tsUrl:
        return 85;
      case PlaylistType.phpUrl:
        return 45;
      case PlaylistType.mp4Url:
        return 12;
      default:
        return 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD, vertical: 24.0),
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimensions.borderLarge,
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 480.0),
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.playlist_add_rounded,
                          color: AppColors.primary,
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Text(
                        'Import Playlist',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Custom TabBar inside Dialog
              Container(
                height: 46.0,
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  labelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 12.0),
                  unselectedLabelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 12.0, fontWeight: FontWeight.normal),
                  tabs: const [
                    Tab(text: 'URL Stream Link'),
                    Tab(text: 'Xtream Codes API'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Playlist Name Input (Always shown)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Playlist Name',
                  hintText: 'e.g., World Cup Premium Streams',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name for this playlist';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.space16),

              // Switchable Tab Contents
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, child) {
                  final isUrlTab = _tabController.index == 0;
                  return isUrlTab ? _buildUrlImportFields() : _buildXtreamImportFields();
                },
              ),

              const SizedBox(height: AppDimensions.space24),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'CANCEL',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  SizedBox(
                    height: 44.0,
                    width: 140.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.buttonGradient,
                        borderRadius: AppDimensions.borderSmall,
                      ),
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          shadowColor: Colors.transparent,
                          elevation: 0.0,
                        ),
                        child: Text(
                          'IMPORT SOURCE',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.black,
                            fontSize: 11.5,
                            fontWeight: FontWeight.extrabold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fields specific to Standard Stream Links (M3U, M3U8, TS, etc.)
  Widget _buildUrlImportFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown type selector
        DropdownButtonFormField<PlaylistType>(
          value: _selectedUrlType,
          dropdownColor: AppColors.surface,
          decoration: const InputDecoration(
            labelText: 'Stream Format / Type',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: const [
            DropdownMenuItem(
              value: PlaylistType.m3uUrl,
              child: Text('M3U Playlists (.m3u)'),
            ),
            DropdownMenuItem(
              value: PlaylistType.m3u8Url,
              child: Text('M3U8 HLS Live Stream (.m3u8)'),
            ),
            DropdownMenuItem(
              value: PlaylistType.tsUrl,
              child: Text('MPEG-TS Live Video (.ts)'),
            ),
            DropdownMenuItem(
              value: PlaylistType.phpUrl,
              child: Text('PHP Streaming Script (.php)'),
            ),
            DropdownMenuItem(
              value: PlaylistType.mp4Url,
              child: Text('Direct MP4 Broadcast (.mp4)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedUrlType = value;
              });
            }
          },
        ),
        const SizedBox(height: AppDimensions.space16),

        // URL Field
        TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'M3U / Stream URL',
            hintText: 'https://example.com/stream.m3u',
            prefixIcon: Icon(Icons.link_rounded),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a valid Stream URL';
            }
            if (!value.trim().startsWith('http://') && !value.trim().startsWith('https://')) {
              return 'URL must start with http:// or https://';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Fields specific to Xtream Codes Login APIs
  Widget _buildXtreamImportFields() {
    return Column(
      children: [
        // Server URL
        TextFormField(
          controller: _xtreamHostController,
          decoration: const InputDecoration(
            labelText: 'Server Host URL',
            hintText: 'http://xtream-provider.com:8080',
            prefixIcon: Icon(Icons.dns_outlined),
          ),
          validator: (value) {
            if (_tabController.index == 1) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter Server Host';
              }
              if (!value.trim().startsWith('http://') && !value.trim().startsWith('https://')) {
                return 'Host must start with http:// or https://';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.space16),

        // Username
        TextFormField(
          controller: _xtreamUsernameController,
          decoration: const InputDecoration(
            labelText: 'API Username',
            hintText: 'Enter account username',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (value) {
            if (_tabController.index == 1 && (value == null || value.trim().isEmpty)) {
              return 'Username is required';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.space16),

        // Password
        TextFormField(
          controller: _xtreamPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'API Password',
            hintText: 'Enter account password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
          validator: (value) {
            if (_tabController.index == 1 && (value == null || value.trim().isEmpty)) {
              return 'Password is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
