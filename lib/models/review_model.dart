import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String routeId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double safetyRating;
  final double lightingRating;
  final double surfaceRating;
  final List<String> tags;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.routeId,
    required this.userId,
    this.userName = 'Community Member',
    this.userPhotoUrl,
    required this.safetyRating,
    required this.lightingRating,
    required this.surfaceRating,
    this.tags = const [],
    this.comment = '',
    required this.createdAt,
  });

  /// Average overall rating for this review
  double get overallRating =>
      (safetyRating + lightingRating + surfaceRating) / 3.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeId': routeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'safetyRating': safetyRating,
      'lightingRating': lightingRating,
      'surfaceRating': surfaceRating,
      'tags': tags,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    final rawTags = map['tags'] as List<dynamic>? ?? [];
    final tags = rawTags.map((e) => e.toString()).toList();

    return ReviewModel(
      id: docId,
      routeId: map['routeId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Community Runner',
      userPhotoUrl: map['userPhotoUrl'] as String?,
      safetyRating: (map['safetyRating'] as num?)?.toDouble() ?? 5.0,
      lightingRating: (map['lightingRating'] as num?)?.toDouble() ?? 5.0,
      surfaceRating: (map['surfaceRating'] as num?)?.toDouble() ?? 5.0,
      tags: tags,
      comment: map['comment'] as String? ?? '',
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel.fromMap(data, doc.id);
  }

  ReviewModel copyWith({
    String? id,
    String? routeId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    double? safetyRating,
    double? lightingRating,
    double? surfaceRating,
    List<String>? tags,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      safetyRating: safetyRating ?? this.safetyRating,
      lightingRating: lightingRating ?? this.lightingRating,
      surfaceRating: surfaceRating ?? this.surfaceRating,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
