import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/hazard_provider.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class HazardReportSheet extends ConsumerStatefulWidget {
  final double latitude;
  final double longitude;

  const HazardReportSheet({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  static Future<void> show(
    BuildContext context, {
    required double latitude,
    required double longitude,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HazardReportSheet(
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  @override
  ConsumerState<HazardReportSheet> createState() => _HazardReportSheetState();
}

class _HazardReportSheetState extends ConsumerState<HazardReportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedType = AppConstants.hazardConstruction;
  String _selectedSeverity = 'moderate'; // minor, moderate, critical
  bool _isSubmitting = false;

  final List<String> _quickTitles = [
    'Construction Barrier',
    'Streetlight Out / Dark',
    'Broken Pavement',
    'Water Logging',
    'Heavy Traffic Jam',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = ref.read(currentUserProvider);
    final userProfile = ref.read(currentUserProfileProvider).asData?.value;

    final userId = user?.uid ?? userProfile?.id ?? 'guest_user';
    final userName = userProfile?.name ?? user?.displayName ?? 'Community Runner';

    try {
      await ref.read(hazardRepositoryProvider).reportHazard(
            userId: userId,
            userName: userName,
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            latitude: widget.latitude,
            longitude: widget.longitude,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Hazard successfully broadcast to the Hive! 🐝'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Coordinates Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.hazardConstruction.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_location_alt_outlined,
                        color: AppColors.hazardConstruction,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Hazard to Hive',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            '📍 ${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Hazard Category Grid
                Text(
                  'Select Hazard Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.25,
                  children: [
                    _buildCategoryTile(
                      type: AppConstants.hazardConstruction,
                      label: 'Construction',
                      icon: Icons.construction,
                      color: AppColors.hazardConstruction,
                    ),
                    _buildCategoryTile(
                      type: AppConstants.hazardClosure,
                      label: 'Closure',
                      icon: Icons.block,
                      color: AppColors.hazardClosure,
                    ),
                    _buildCategoryTile(
                      type: AppConstants.hazardLighting,
                      label: 'Dark / Light',
                      icon: Icons.highlight,
                      color: AppColors.hazardLighting,
                    ),
                    _buildCategoryTile(
                      type: AppConstants.hazardPoorRoad,
                      label: 'Poor Surface',
                      icon: Icons.broken_image_outlined,
                      color: AppColors.hazardPoorRoad,
                    ),
                    _buildCategoryTile(
                      type: AppConstants.hazardTraffic,
                      label: 'Heavy Traffic',
                      icon: Icons.traffic,
                      color: AppColors.hazardTraffic,
                    ),
                    _buildCategoryTile(
                      type: AppConstants.hazardOther,
                      label: 'Other',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.hazardOther,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Severity Selector
                Text(
                  'Hazard Severity Level',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildSeverityChip('minor', 'Minor Slowdown', AppColors.warning),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSeverityChip('moderate', 'Moderate Risk', AppColors.hazardConstruction),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSeverityChip('critical', 'Critical Danger', AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick Title Suggestions
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickTitles.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 6),
                    itemBuilder: (context, i) {
                      final title = _quickTitles[i];
                      return ActionChip(
                        label: Text(title, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _titleController.text = title;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Title Input
                CustomTextField(
                  label: 'Hazard Title',
                  hintText: 'e.g. Open trench on sidewalk',
                  controller: _titleController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Description Input
                CustomTextField(
                  label: 'Additional Details (Optional)',
                  hintText: 'e.g. Workers occupying cycling lane, detour on right side',
                  controller: _descController,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Submit Button
                CustomButton(
                  text: 'Broadcast Hazard Alert',
                  icon: Icons.send_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _submitReport,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: isSelected ? color : AppColors.textMutedLight),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityChip(String value, String label, Color color) {
    final isSelected = _selectedSeverity == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedSeverity = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? color : null,
            ),
          ),
        ),
      ),
    );
  }
}
