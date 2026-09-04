import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/hazard_model.dart';
import '../../models/route_model.dart';
import '../../models/review_model.dart';
import '../constants/app_constants.dart';

class MockDataSeeder {
  MockDataSeeder._();

  /// Starter Routes for urban runners & cyclists
  static List<RouteModel> get initialRoutes => [
        RouteModel(
          id: 'route_cubbon_loop',
          creatorId: 'user_hive_ambassador',
          creatorName: 'Arjun Verma (Hive Lead)',
          name: 'Cubbon Park Morning Loop',
          description:
              'Well-lit green belt loop with zero motor vehicles allowed between 5 AM to 8 AM. Ideal for dawn running & fast interval cycling.',
          distanceKm: 5.2,
          durationMinutes: 34,
          safetyRating: 4.8,
          lightingRating: 4.6,
          surfaceRating: 4.7,
          reviewCount: 42,
          isVerifiedHive: true,
          tags: ['Well Lit', 'Low Traffic', 'Smooth Surface', 'Paved Trail', 'Night Safe'],
          coordinates: [
            const RoutePoint(latitude: 12.9756, longitude: 77.5928),
            const RoutePoint(latitude: 12.9785, longitude: 77.5950),
            const RoutePoint(latitude: 12.9802, longitude: 77.5915),
            const RoutePoint(latitude: 12.9765, longitude: 77.5880),
            const RoutePoint(latitude: 12.9730, longitude: 77.5905),
            const RoutePoint(latitude: 12.9756, longitude: 77.5928),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        RouteModel(
          id: 'route_ulsoor_lake',
          creatorId: 'user_cyclist_neha',
          creatorName: 'Neha Rao',
          name: 'Ulsoor Lake Perimeter Trail',
          description:
              'Lakeside perimeter with designated jogging track and scenic water views. High pedestrian density in the evening.',
          distanceKm: 3.8,
          durationMinutes: 24,
          safetyRating: 4.5,
          lightingRating: 4.3,
          surfaceRating: 4.4,
          reviewCount: 28,
          isVerifiedHive: true,
          tags: ['Scenic View', 'Paved Trail', 'Wide Shoulders', 'Crowded'],
          coordinates: [
            const RoutePoint(latitude: 12.9820, longitude: 77.6200),
            const RoutePoint(latitude: 12.9850, longitude: 77.6240),
            const RoutePoint(latitude: 12.9810, longitude: 77.6280),
            const RoutePoint(latitude: 12.9780, longitude: 77.6230),
            const RoutePoint(latitude: 12.9820, longitude: 77.6200),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        RouteModel(
          id: 'route_indiranagar_corridor',
          creatorId: 'user_runner_karthik',
          creatorName: 'Karthik S.',
          name: 'Indiranagar 100ft Green Corridor',
          description:
              'Wide sidewalks and dedicated bike lanes along residential cross streets. Caution near 12th Main junction during peak hours.',
          distanceKm: 6.4,
          durationMinutes: 42,
          safetyRating: 4.2,
          lightingRating: 4.5,
          surfaceRating: 4.1,
          reviewCount: 19,
          isVerifiedHive: false,
          tags: ['Well Lit', 'Bike Lane', 'Heavy Traffic'],
          coordinates: [
            const RoutePoint(latitude: 12.9719, longitude: 77.6412),
            const RoutePoint(latitude: 12.9750, longitude: 77.6435),
            const RoutePoint(latitude: 12.9790, longitude: 77.6450),
            const RoutePoint(latitude: 12.9820, longitude: 77.6410),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        RouteModel(
          id: 'route_sankey_tank',
          creatorId: 'user_cyclist_vikram',
          creatorName: 'Vikram Joshi',
          name: 'Sankey Tank Forest Loop',
          description:
              'Quiet, clean, and canopy-covered track around Sankey Tank. Excellent surface condition and full perimeter lighting.',
          distanceKm: 4.1,
          durationMinutes: 28,
          safetyRating: 4.9,
          lightingRating: 4.8,
          surfaceRating: 4.9,
          reviewCount: 35,
          isVerifiedHive: true,
          tags: ['Well Lit', 'Smooth Surface', 'Scenic View', 'Night Safe'],
          coordinates: [
            const RoutePoint(latitude: 13.0068, longitude: 77.5700),
            const RoutePoint(latitude: 13.0100, longitude: 77.5730),
            const RoutePoint(latitude: 13.0080, longitude: 77.5760),
            const RoutePoint(latitude: 13.0050, longitude: 77.5720),
            const RoutePoint(latitude: 13.0068, longitude: 77.5700),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

  /// Starter Hazards for map visualization
  static List<HazardModel> get initialHazards => [
        HazardModel(
          id: 'hazard_1',
          userId: 'user_runner_karthik',
          userName: 'Karthik S.',
          type: 'construction',
          title: 'Footpath Metro Digging',
          description:
              'Sidewalk blocked by metro pipeline work. Runners must divert onto side lane for 100 meters.',
          latitude: 12.9740,
          longitude: 77.5970,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          status: 'active',
          upvotes: 7,
        ),
        HazardModel(
          id: 'hazard_2',
          userId: 'user_cyclist_neha',
          userName: 'Neha Rao',
          type: 'poor_lighting',
          title: 'Broken Streetlamps on North Gate',
          description:
              'Consecutive 4 streetlights are off along the north perimeter curve. Pitch dark after 7:30 PM.',
          latitude: 12.9835,
          longitude: 77.6250,
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          status: 'active',
          upvotes: 12,
        ),
        HazardModel(
          id: 'hazard_3',
          userId: 'user_hive_ambassador',
          userName: 'Arjun Verma',
          type: 'poor_road',
          title: 'Deep Pothole on Bike Shoulder',
          description:
              'Large pothole hidden under tree shadows near junction. Watch out if riding fast on road bikes.',
          latitude: 12.9770,
          longitude: 77.6430,
          createdAt: DateTime.now().subtract(const Duration(hours: 14)),
          status: 'active',
          upvotes: 9,
        ),
        HazardModel(
          id: 'hazard_4',
          userId: 'user_cyclist_vikram',
          userName: 'Vikram Joshi',
          type: 'road_closure',
          title: 'Culvert Repair Barricades',
          description:
              'Narrow cross-road barricaded completely for emergency drainage repair until Friday.',
          latitude: 12.9710,
          longitude: 77.5890,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          status: 'active',
          upvotes: 5,
        ),
      ];

  /// Starter Reviews
  static List<ReviewModel> get initialReviews => [
        ReviewModel(
          id: 'rev_1',
          routeId: 'route_cubbon_loop',
          userId: 'user_runner_priya',
          userName: 'Priya Sundaram',
          safetyRating: 5.0,
          lightingRating: 5.0,
          surfaceRating: 4.8,
          tags: ['Well Lit', 'Smooth Surface', 'Night Safe'],
          comment:
              'One of the safest running loops in the city. Excellent community presence in the morning and very smooth tarmac.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ReviewModel(
          id: 'rev_2',
          routeId: 'route_cubbon_loop',
          userId: 'user_cyclist_anand',
          userName: 'Anand Mehta',
          safetyRating: 4.7,
          lightingRating: 4.2,
          surfaceRating: 4.6,
          tags: ['Low Traffic', 'Scenic View'],
          comment:
              'Perfect for endurance laps before traffic picks up. Fresh air and plenty of shade trees.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

  /// Seeds initial routes and hazards to Cloud Firestore if collections are empty
  static Future<void> seedFirestoreIfEmpty() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final routesSnapshot = await firestore
          .collection(AppConstants.routesCollection)
          .limit(1)
          .get();

      if (routesSnapshot.docs.isEmpty) {
        debugPrint('Seeding initial RouteHive routes to Firestore...');
        final batch = firestore.batch();
        for (final route in initialRoutes) {
          final docRef = firestore
              .collection(AppConstants.routesCollection)
              .doc(route.id);
          batch.set(docRef, route.toMap());
        }
        for (final hazard in initialHazards) {
          final docRef = firestore
              .collection(AppConstants.hazardsCollection)
              .doc(hazard.id);
          batch.set(docRef, hazard.toMap());
        }
        for (final review in initialReviews) {
          final docRef = firestore
              .collection(AppConstants.reviewsCollection)
              .doc(review.id);
          batch.set(docRef, review.toMap());
        }
        await batch.commit();
        debugPrint('Initial RouteHive seed complete.');
      }
    } catch (e) {
      debugPrint('Firestore seed skipped or offline: $e');
    }
  }
}
