import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/remote_config_model.dart';
import '../../providers/remote_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class EditAnnouncementPage extends ConsumerStatefulWidget {
  const EditAnnouncementPage({super.key});

  @override
  ConsumerState<EditAnnouncementPage> createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends ConsumerState<EditAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late bool _showAnnouncement;

  // Scheduling Architecture variables
  bool _scheduleEnabled = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String _recurrenceRule = 'once'; // 'once', 'daily', 'weekly', 'app_start'

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadScheduleState();
  }

  void _initFieldsOnce(RemoteConfigModel config) {
    if (_initialized) return;
    _initialized = true;

    _titleController = TextEditingController(text: config.announcement.title);
    _messageController = TextEditingController(text: config.announcement.message);
    _showAnnouncement = config.announcement.showAnnouncement;
  }

  Future<void> _loadScheduleState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduleStr = prefs.getString('announcement_schedule_config');
      if (scheduleStr != null) {
        final Map<String, dynamic> data = json.decode(scheduleStr);
        setState(() {
          _scheduleEnabled = data['schedule_enabled'] ?? false;
          if (data['start_date'] != null) {
            _startDate = DateTime.tryParse(data['start_date']);
          }
          if (data['end_date'] != null) {
            _endDate = DateTime.tryParse(data['end_date']);
          }
          _recurrenceRule = data['recurrence_rule'] ?? 'once';
        });
      }
    } catch (e) {
      print('Failed to load schedule state: $e');
    }
  }

  Future<void> _saveScheduleState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'schedule_enabled': _scheduleEnabled,
        'start_date': _startDate?.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
        'recurrence_rule': _recurrenceRule,
      };
      await prefs.setString('announcement_schedule_config', json.encode(data));
    } catch (e) {
      print('Failed to save schedule state: $e');
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _titleController.dispose();
      _messageController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.black,
                surface: AppColors.surface,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          final fullDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startDate = fullDateTime;
          } else {
            _endDate = fullDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveAnnouncement(RemoteConfigModel config) async {
    if (!_formKey.currentState!.validate()) return;

    final updatedAnnouncement = AnnouncementConfig(
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      showAnnouncement: _showAnnouncement,
    );

    final updatedConfig = RemoteConfigModel(
      appConfig: config.appConfig,
      homeBanner: config.homeBanner,
      newsBanner: config.newsBanner,
      announcement: updatedAnnouncement,
      categories: config.categories,
      playlists: config.playlists,
      epgUrls: config.epgUrls,
      channelLogos: config.channelLogos,
      posterImages: config.posterImages,
      featuredChannels: config.featuredChannels,
      hiddenChannels: config.hiddenChannels,
    );

    // Save announcement in central remote config
    await ref.read(remoteConfigNotifierProvider.notifier).updateConfig(updatedConfig);
    
    // Save scheduling data separately to SharedPreferences (scaffold prepare architecture)
    await _saveScheduleState();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement configuration saved successfully!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.of(context).pop();
    }
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
          'MANAGE ANNOUNCEMENTS',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.black, letterSpacing: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: configAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
          data: (config) {
            _initFieldsOnce(config);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Announcement text details
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ANNOUNCEMENT SETTINGS',
                                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: _showAnnouncement,
                                activeColor: AppColors.primary,
                                onChanged: (v) {
                                  setState(() {
                                    _showAnnouncement = v;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration('Announcement Title'),
                            validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 4,
                            decoration: _buildInputDecoration('Announcement Message'),
                            validator: (v) => v == null || v.isEmpty ? 'Message body is required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Scheduling prepare architecture Section
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SCHEDULER ENGINE',
                                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Automate when this bulletin goes live',
                                    style: TextStyle(color: AppColors.muted, fontSize: 11.0),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _scheduleEnabled,
                                activeColor: AppColors.primary,
                                onChanged: (v) {
                                  setState(() {
                                    _scheduleEnabled = v;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_scheduleEnabled) ...[
                            const Divider(color: AppColors.borderTranslucent, height: 32.0),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _pickDate(true),
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border.all(color: AppColors.borderTranslucent),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('START DATE/TIME', style: TextStyle(color: AppColors.muted, fontSize: 10.0, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 6.0),
                                          Text(
                                            _startDate != null ? _startDate!.toString().substring(0, 16) : 'Not Scheduled',
                                            style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _pickDate(false),
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border.all(color: AppColors.borderTranslucent),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('END DATE/TIME', style: TextStyle(color: AppColors.muted, fontSize: 10.0, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 6.0),
                                          Text(
                                            _endDate != null ? _endDate!.toString().substring(0, 16) : 'Not Scheduled',
                                            style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Recurrence Interval', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.0)),
                                DropdownButton<String>(
                                  value: _recurrenceRule,
                                  dropdownColor: AppColors.surface,
                                  style: const TextStyle(color: Colors.white),
                                  underline: Container(),
                                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                  items: const [
                                    DropdownMenuItem(value: 'once', child: Text('Display Once')),
                                    DropdownMenuItem(value: 'daily', child: Text('Daily Recurrence')),
                                    DropdownMenuItem(value: 'weekly', child: Text('Weekly Recurrence')),
                                    DropdownMenuItem(value: 'app_start', child: Text('Every App Launch')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _recurrenceRule = val;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16.0),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      'Scheduler architecture will invoke alarm dispatchers and sync local notifications in the background.',
                                      style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: 11.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32.0),
                    SizedBox(
                      width: double.infinity,
                      height: 52.0,
                      child: ElevatedButton(
                        onPressed: () => _saveAnnouncement(config),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          elevation: 4.0,
                        ),
                        child: const Text('SAVE CONFIGURATION', style: TextStyle(fontWeight: FontWeight.black, fontSize: 15.0, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13.0),
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
    );
  }
}
