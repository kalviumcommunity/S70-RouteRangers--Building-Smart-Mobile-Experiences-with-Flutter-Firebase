import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_data_seeder.dart';
import '../models/route_model.dart';

class RouteRepository {
  FirebaseFirestore? _firestoreInstance;

  RouteRepository({
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

  /// Stream of all community routes in real-time
  Stream<List<RouteModel>> getRoutesStream() {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        return firestore
            .collection(AppConstants.routesCollection)
            .orderBy('safetyRating', descending: true)
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return MockDataSeeder.initialRoutes;
          }
          return snapshot.docs.map((doc) => RouteModel.fromFirestore(doc)).toList();
        }).handleError((error) {
          debugPrint('Routes stream note: $error');
          return MockDataSeeder.initialRoutes;
        });
      }
    } catch (e) {
      debugPrint('Error accessing routes stream: $e');
    }
    return Stream.value(MockDataSeeder.initialRoutes);
  }

  /// Get single route by ID
  Future<RouteModel?> getRouteById(String routeId) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final doc = await firestore
            .collection(AppConstants.routesCollection)
            .doc(routeId)
            .get();

        if (doc.exists) {
          return RouteModel.fromFirestore(doc);
        }
      }

      // Check fallback mock routes
      final fallback = MockDataSeeder.initialRoutes
          .where((element) => element.id == routeId);
      if (fallback.isNotEmpty) {
        return fallback.first;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting route by ID: $e');
      final fallback = MockDataSeeder.initialRoutes
          .where((element) => element.id == routeId);
      return fallback.isNotEmpty ? fallback.first : null;
    }
  }

  /// Create a new route
  Future<RouteModel> createRoute({
    required String creatorId,
    required String creatorName,
    required String name,
    required String description,
    required double distanceKm,
    required int durationMinutes,
    required List<RoutePoint> coordinates,
    List<String> tags = const [],
  }) async {
    try {
      final routeId = const Uuid().v4();
      final route = RouteModel(
        id: routeId,
        creatorId: creatorId,
        creatorName: creatorName,
        name: name,
        description: description,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        safetyRating: 5.0,
        lightingRating: 5.0,
        surfaceRating: 5.0,
        reviewCount: 0,
        isVerifiedHive: false,
        tags: tags,
        coordinates: coordinates,
        createdAt: DateTime.now(),
      );

      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection(AppConstants.routesCollection)
            .doc(routeId)
            .set(route.toMap());
      }

      return route;
    } catch (e) {
      debugPrint('Error creating route: $e');
      throw 'Failed to create route. Please try again.';
    }
  }
}
