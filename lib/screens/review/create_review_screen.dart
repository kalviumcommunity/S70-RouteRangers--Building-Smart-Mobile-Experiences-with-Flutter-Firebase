import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/route_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/star_rating_selector.dart';

class CreateReviewScreen extends ConsumerStatefulWidget {
  final RouteModel route;

  const CreateReviewScreen({
    super.key,
    required this.route,
  });

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  double _safetyRating = 5.0;
  double _lightingRating = 5.0;
  double _surfaceRating = 5.0;
  final List<String> _selectedTags = [];
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = ref.read(currentUserProvider);
    final userProfile = ref.read(currentUserProfileProvider).asData?.value;

    final userId = user?.uid ?? 'guest_user';
    final userName = userProfile?.name ?? user?.displayName ?? 'Community Runner';

    final success = await ref
        .read(reviewSubmissionNotifierProvider.notifier)
        .submitReview(
          routeId: widget.route.id,
          userId: userId,
          userName: userName,
          userPhotoUrl: user?.photoURL,
          safetyRating: _safetyRating,
          lightingRating: _lightingRating,
          surfaceRating: _surfaceRating,
          tags: _selectedTags,
          comment: _commentController.text.trim(),
        );

    if (mounted && success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Review submitted! Thank you for helping the Hive stay safe.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(reviewSubmissionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Route'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Route Header Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.route_outlined, color: AppColors.primaryDark, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.route.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            '${widget.route.distanceKm.toStringAsFixed(1)} km · ${widget.route.durationMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Rating 1: Safety & Traffic Comfort
              StarRatingSelector(
                label: 'Safety & Traffic Comfort',
                rating: _safetyRating,
                isInteractive: true,
                starSize: 32,
                activeColor: AppColors.success,
                onRatingChanged: (val) => setState(() => _safetyRating = val),
              ),
              const SizedBox(height: 20),

              // Rating 2: Night Lighting Visibility
              StarRatingSelector(
                label: 'Night Lighting Visibility',
                rating: _lightingRating,
                isInteractive: true,
                starSize: 32,
                activeColor: AppColors.primary,
                onRatingChanged: (val) => setState(() => _lightingRating = val),
              ),
              const SizedBox(height: 20),

              // Rating 3: Road & Footpath Surface Quality
              StarRatingSelector(
                label: 'Road & Footpath Surface Quality',
                rating: _surfaceRating,
                isInteractive: true,
                starSize: 32,
                activeColor: AppColors.info,
                onRatingChanged: (val) => setState(() => _surfaceRating = val),
              ),
              const SizedBox(height: 28),

              // Experience Tags Selector
              Text(
                'Add Route Tags',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select tags that best describe current conditions',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.reviewTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.onPrimary,
                    backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.onPrimary
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Written Comment Field
              CustomTextField(
                label: 'Written Feedback (Optional)',
                hintText: 'Share tips on timing, hazards to watch for, or surface quality...',
                controller: _commentController,
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),

              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 28),

              // Submit Review Button
              CustomButton(
                text: 'Post Community Review',
                isLoading: state.isSubmitting,
                onPressed: _submitReview,
                icon: Icons.rate_review,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
