import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../repositories/review_repository.dart';
import 'auth_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

/// Stream of reviews for a specific route
final routeReviewsStreamProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, routeId) {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getRouteReviewsStream(routeId);
});

/// Stream of reviews written by current user
final userReviewsStreamProvider = StreamProvider<List<ReviewModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(<ReviewModel>[]);
  }
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getUserReviewsStream(user.uid);
});

/// State for submitting a review
class ReviewSubmissionState {
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const ReviewSubmissionState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ReviewSubmissionState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ReviewSubmissionState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ReviewSubmissionNotifier extends StateNotifier<ReviewSubmissionState> {
  final ReviewRepository _repository;

  ReviewSubmissionNotifier(this._repository)
      : super(const ReviewSubmissionState());

  Future<bool> submitReview({
    required String routeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required double safetyRating,
    required double lightingRating,
    required double surfaceRating,
    required List<String> tags,
    required String comment,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false);
    try {
      await _repository.submitReview(
        routeId: routeId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        safetyRating: safetyRating,
        lightingRating: lightingRating,
        surfaceRating: surfaceRating,
        tags: tags,
        comment: comment,
      );
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = const ReviewSubmissionState();
  }
}

final reviewSubmissionNotifierProvider =
    StateNotifierProvider<ReviewSubmissionNotifier, ReviewSubmissionState>((ref) {
  final repo = ref.watch(reviewRepositoryProvider);
  return ReviewSubmissionNotifier(repo);
});
