import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_data_seeder.dart';
import '../models/review_model.dart';
import '../models/route_model.dart';

class ReviewRepository {
  FirebaseFirestore? _firestoreInstance;

  ReviewRepository({
    FirebaseFirestore? firestore,
  }) : _firestoreInstance = firestore;

  FirebaseFirestore? get _firestore {
    if (_firestoreInstance != null) return _firestoreInstance;
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestoreInstance = FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('Firestore instance note: $e');
    }
    return _firestoreInstance;
  }

  /// Stream of all reviews for a specific route
  Stream<List<ReviewModel>> getRouteReviewsStream(String routeId) {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        return firestore
            .collection(AppConstants.reviewsCollection)
            .where('routeId', isEqualTo: routeId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return MockDataSeeder.initialReviews
                .where((r) => r.routeId == routeId)
                .toList();
          }
          return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
        }).handleError((error) {
          debugPrint('Review stream note: $error');
          return MockDataSeeder.initialReviews
              .where((r) => r.routeId == routeId)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error accessing reviews stream: $e');
    }
    return Stream.value(
      MockDataSeeder.initialReviews.where((r) => r.routeId == routeId).toList(),
    );
  }

  /// Get reviews written by a specific user
  Stream<List<ReviewModel>> getUserReviewsStream(String userId) {
    try {
      final firestore = _firestore;
      if (firestore != null && userId.isNotEmpty) {
        return firestore
            .collection(AppConstants.reviewsCollection)
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList())
            .handleError((error) {
          debugPrint('User reviews note: $error');
          return <ReviewModel>[];
        });
      }
    } catch (e) {
      debugPrint('Error accessing user reviews stream: $e');
    }
    return Stream.value(<ReviewModel>[]);
  }

  /// Submit a new review and atomically recalculate route's aggregate scores
  Future<void> submitReview({
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
    try {
      final reviewId = const Uuid().v4();
      final review = ReviewModel(
        id: reviewId,
        routeId: routeId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        safetyRating: safetyRating,
        lightingRating: lightingRating,
        surfaceRating: surfaceRating,
        tags: tags,
        comment: comment,
        createdAt: DateTime.now(),
      );

      final firestore = _firestore;
      if (firestore != null) {
        final routeDocRef = firestore
            .collection(AppConstants.routesCollection)
            .doc(routeId);

        final reviewDocRef = firestore
            .collection(AppConstants.reviewsCollection)
            .doc(reviewId);

        await firestore.runTransaction((transaction) async {
          transaction.set(reviewDocRef, review.toMap());

          final routeSnapshot = await transaction.get(routeDocRef);
          if (routeSnapshot.exists) {
            final currentRoute = RouteModel.fromFirestore(routeSnapshot);
            final currentCount = currentRoute.reviewCount;
            final newCount = currentCount + 1;

            final newSafety = ((currentRoute.safetyRating * currentCount) +
                    safetyRating) /
                newCount;
            final newLighting = ((currentRoute.lightingRating * currentCount) +
                    lightingRating) /
                newCount;
            final newSurface = ((currentRoute.surfaceRating * currentCount) +
                    surfaceRating) /
                newCount;

            final isVerified = (newCount >= 3 && newSafety >= 4.3);

            transaction.update(routeDocRef, {
              'reviewCount': newCount,
              'safetyRating': double.parse(newSafety.toStringAsFixed(2)),
              'lightingRating': double.parse(newLighting.toStringAsFixed(2)),
              'surfaceRating': double.parse(newSurface.toStringAsFixed(2)),
              'isVerifiedHive': isVerified,
            });
          }
        });

        if (userId.isNotEmpty) {
          await firestore
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .update({
            'routesReviewed': FieldValue.increment(1),
            'reputationScore': FieldValue.increment(20),
          }).catchError((_) {});
        }
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
      throw 'Failed to post review. Please try again.';
    }
  }
}
