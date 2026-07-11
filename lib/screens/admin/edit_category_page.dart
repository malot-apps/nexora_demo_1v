import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/remote_config_model.dart';
import '../../providers/remote_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class EditCategoryPage extends ConsumerStatefulWidget {
  final RemoteCategoryConfig? category;

  const EditCategoryPage({
    super.key,
    this.category,
  });

  @override
  ConsumerState<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends ConsumerState<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _imageController;
  late TextEditingController _sortOrderController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.category?.id ?? '');
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _imageController = TextEditingController(text: widget.category?.image ?? '');
    _sortOrderController = TextEditingController(text: widget.category?.sortOrder.toString() ?? '1');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _imageController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final configAsync = ref.read(remoteConfigNotifierProvider);
    configAsync.whenData((config) async {
      final currentCategories = List<RemoteCategoryConfig>.from(config.categories);
      final sortOrder = int.tryParse(_sortOrderController.text) ?? 1;

      if (widget.category == null) {
        // Adding new category
        final newCategory = RemoteCategoryConfig(
          id: _idController.text.trim().toLowerCase(),
          name: _nameController.text.trim(),
          image: _imageController.text.trim(),
          sortOrder: sortOrder,
        );
        currentCategories.add(newCategory);
      } else {
        // Editing existing category
        final index = currentCategories.indexWhere((c) => c.id == widget.category!.id);
        if (index != -1) {
          currentCategories[index] = RemoteCategoryConfig(
            id: widget.category!.id,
            name: _nameController.text.trim(),
            image: _imageController.text.trim(),
            sortOrder: sortOrder,
          );
        }
      }

      // Reassemble config model
      final updatedConfig = RemoteConfigModel(
        appConfig: config.appConfig,
        homeBanner: config.homeBanner,
        newsBanner: config.newsBanner,
        announcement: config.announcement,
        categories: currentCategories,
        playlists: config.playlists,
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
              widget.category == null ? 'Category added successfully!' : 'Category updated successfully!',
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
    final isEditing = widget.category != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'EDIT CATEGORY' : 'ADD CATEGORY',
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
                        'CATEGORY DETAILS',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _idController,
                        style: const TextStyle(color: Colors.white),
                        enabled: !isEditing, // ID is immutable once created
                        decoration: InputDecoration(
                          labelText: 'Category ID (unique, lowercase)',
                          labelStyle: const TextStyle(color: AppColors.muted),
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.borderTranslucent, width: 0.5),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
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
                            return 'Please enter a category ID';
                          }
                          if (RegExp(r'[^a-z0-9_]').hasMatch(value)) {
                            return 'IDs must be alphanumeric/lowercase with underscores';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Display Name',
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
                            return 'Please enter a category display name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _imageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Hero Image URL',
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
                            return 'Please enter a hero image URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _sortOrderController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Sort Order (numeric)',
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
                            return 'Please enter a sort order';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid integer';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                
                // Visual Image Preview
                if (_imageController.text.trim().isNotEmpty) ...[
                  const Text(
                    'VISUAL COVER PREVIEW',
                    style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      _imageController.text.trim(),
                      height: 160.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 160.0,
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_rounded, color: AppColors.muted, size: 40.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4.0,
                    ),
                    child: Text(
                      isEditing ? 'COMMIT UPDATES' : 'CREATE CATEGORY',
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
