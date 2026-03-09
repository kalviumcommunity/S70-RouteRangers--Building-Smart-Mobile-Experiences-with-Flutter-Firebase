import 'package:cloud_firestore/cloud_firestore.dart';

class HazardPin {
  final String id;
  final String type;
  final int safetyRating;
  final String? description;
  final GeoPoint location;
  final DateTime timestamp;
  final String userId;

  HazardPin({
    required this.id,
    required this.type,
    required this.safetyRating,
    this.description,
    required this.location,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'safetyRating': safetyRating,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'userId': userId,
    };
  }

  factory HazardPin.fromMap(String id, Map<String, dynamic> map) {
    return HazardPin(
      id: id,
      type: map['type'] ?? 'Unknown',
      safetyRating: map['safetyRating'] ?? 0,
      description: map['description'],
      location: map['location'] as GeoPoint,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }
}
