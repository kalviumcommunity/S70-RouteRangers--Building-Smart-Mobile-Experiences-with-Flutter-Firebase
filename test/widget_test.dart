import 'package:flutter_test/flutter_test.dart';
import 'package:routehive/core/utils/geo_utils.dart';
import 'package:routehive/core/utils/date_formatter.dart';
import 'package:routehive/models/hazard_model.dart';
import 'package:routehive/models/route_model.dart';
import 'package:routehive/models/review_model.dart';
import 'package:routehive/models/user_model.dart';

void main() {
  group('GeoUtils Tests', () {
    test('calculateDistanceKm calculates distance accurately', () {
      // Distance between two points in Bangalore (~4 km)
      final distance = GeoUtils.calculateDistanceKm(12.9716, 77.5946, 12.9785, 77.6250);
      expect(distance, greaterThan(3.0));
      expect(distance, lessThan(4.5));
    });

    test('formatDistance formats meters and kilometers properly', () {
      expect(GeoUtils.formatDistance(0.45), '450 m');
      expect(GeoUtils.formatDistance(5.23), '5.2 km');
    });

    test('formatDuration formats minutes and hours properly', () {
      expect(GeoUtils.formatDuration(34), '34 min');
      expect(GeoUtils.formatDuration(75), '1h 15m');
      expect(GeoUtils.formatDuration(120), '2h');
    });
  });

  group('DateFormatter Tests', () {
    test('timeAgo formats recent relative timestamps', () {
      final now = DateTime.now();
      expect(DateFormatter.timeAgo(now.subtract(const Duration(seconds: 15))), 'Just now');
      expect(DateFormatter.timeAgo(now.subtract(const Duration(minutes: 5))), '5m ago');
      expect(DateFormatter.timeAgo(now.subtract(const Duration(hours: 3))), '3h ago');
      expect(DateFormatter.timeAgo(now.subtract(const Duration(days: 2))), '2d ago');
    });
  });

  group('Data Model Tests', () {
    test('UserModel serialization and copyWith', () {
      final user = UserModel(
        id: 'user_123',
        email: 'runner@routehive.app',
        name: 'Alex Rivera',
        bio: 'Runner',
        routesReviewed: 5,
        hazardsReported: 2,
        reputationScore: 150,
        createdAt: DateTime(2026, 1, 1),
      );

      final map = user.toMap();
      expect(map['email'], 'runner@routehive.app');
      expect(map['name'], 'Alex Rivera');
      expect(map['reputationScore'], 150);

      final updated = user.copyWith(reputationScore: 170);
      expect(updated.reputationScore, 170);
      expect(updated.name, 'Alex Rivera');
    });

    test('HazardModel serialization and type attributes', () {
      final hazard = HazardModel(
        id: 'h_1',
        userId: 'u_1',
        type: 'construction',
        title: 'Roadwork',
        description: 'Digging on sidewalk',
        latitude: 12.9716,
        longitude: 77.5946,
        createdAt: DateTime.now(),
      );

      expect(hazard.typeLabel, 'Construction');
      expect(hazard.color.toARGB32(), isNotNull);
      expect(hazard.icon, isNotNull);

      final map = hazard.toMap();
      expect(map['type'], 'construction');
      expect(map['latitude'], 12.9716);
    });

    test('RouteModel and ReviewModel verified hive metrics', () {
      final route = RouteModel(
        id: 'r_1',
        creatorId: 'c_1',
        name: 'Cubbon Park Loop',
        description: 'Scenic safe loop',
        distanceKm: 5.2,
        durationMinutes: 34,
        safetyRating: 4.8,
        lightingRating: 4.6,
        surfaceRating: 4.7,
        reviewCount: 10,
        isVerifiedHive: true,
        tags: ['Well Lit', 'Smooth Surface'],
        createdAt: DateTime.now(),
      );

      expect(route.isVerifiedHive, isTrue);
      expect(route.tags.length, 2);

      final review = ReviewModel(
        id: 'rev_1',
        routeId: 'r_1',
        userId: 'u_2',
        safetyRating: 5.0,
        lightingRating: 4.0,
        surfaceRating: 4.5,
        tags: ['Well Lit'],
        comment: 'Great trail!',
        createdAt: DateTime.now(),
      );

      expect(review.overallRating, closeTo(4.5, 0.01));
    });
  });
}
