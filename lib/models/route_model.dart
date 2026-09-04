import 'package:cloud_firestore/cloud_firestore.dart';

class RoutePoint {
  final double latitude;
  final double longitude;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory RoutePoint.fromMap(Map<String, dynamic> map) => RoutePoint(
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      );
}

class RouteModel {
  final String id;
  final String creatorId;
  final String creatorName;
  final String name;
  final String description;
  final double distanceKm;
  final int durationMinutes;
  final double safetyRating;
  final double lightingRating;
  final double surfaceRating;
  final int reviewCount;
  final bool isVerifiedHive;
  final List<String> tags;
  final List<RoutePoint> coordinates;
  final DateTime createdAt;

  const RouteModel({
    required this.id,
    required this.creatorId,
    this.creatorName = 'RouteHive Creator',
    required this.name,
    required this.description,
    required this.distanceKm,
    required this.durationMinutes,
    this.safetyRating = 4.5,
    this.lightingRating = 4.2,
    this.surfaceRating = 4.4,
    this.reviewCount = 0,
    this.isVerifiedHive = false,
    this.tags = const [],
    this.coordinates = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'name': name,
      'description': description,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'safetyRating': safetyRating,
      'lightingRating': lightingRating,
      'surfaceRating': surfaceRating,
      'reviewCount': reviewCount,
      'isVerifiedHive': isVerifiedHive,
      'tags': tags,
      'coordinates': coordinates.map((p) => p.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RouteModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    final rawCoordinates = map['coordinates'] as List<dynamic>? ?? [];
    final coordinates = rawCoordinates.map((c) {
      if (c is Map<String, dynamic>) {
        return RoutePoint.fromMap(c);
      } else if (c is Map) {
        return RoutePoint.fromMap(Map<String, dynamic>.from(c));
      }
      return const RoutePoint(latitude: 0, longitude: 0);
    }).toList();

    final rawTags = map['tags'] as List<dynamic>? ?? [];
    final tags = rawTags.map((e) => e.toString()).toList();

    return RouteModel(
      id: docId,
      creatorId: map['creatorId'] as String? ?? '',
      creatorName: map['creatorName'] as String? ?? 'Community Runner',
      name: map['name'] as String? ?? 'Scenic Loop',
      description: map['description'] as String? ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      safetyRating: (map['safetyRating'] as num?)?.toDouble() ?? 4.0,
      lightingRating: (map['lightingRating'] as num?)?.toDouble() ?? 4.0,
      surfaceRating: (map['surfaceRating'] as num?)?.toDouble() ?? 4.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isVerifiedHive: (map['isVerifiedHive'] as bool?) ?? false,
      tags: tags,
      coordinates: coordinates,
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RouteModel.fromMap(data, doc.id);
  }

  RouteModel copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? name,
    String? description,
    double? distanceKm,
    int? durationMinutes,
    double? safetyRating,
    double? lightingRating,
    double? surfaceRating,
    int? reviewCount,
    bool? isVerifiedHive,
    List<String>? tags,
    List<RoutePoint>? coordinates,
    DateTime? createdAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      name: name ?? this.name,
      description: description ?? this.description,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      safetyRating: safetyRating ?? this.safetyRating,
      lightingRating: lightingRating ?? this.lightingRating,
      surfaceRating: surfaceRating ?? this.surfaceRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerifiedHive: isVerifiedHive ?? this.isVerifiedHive,
      tags: tags ?? this.tags,
      coordinates: coordinates ?? this.coordinates,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
