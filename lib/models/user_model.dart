import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String bio;
  final int routesReviewed;
  final int hazardsReported;
  final int reputationScore;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.bio = 'Urban Runner & Hive Explorer',
    this.routesReviewed = 0,
    this.hazardsReported = 0,
    this.reputationScore = 100,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'routesReviewed': routesReviewed,
      'hazardsReported': hazardsReported,
      'reputationScore': reputationScore,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      id: docId,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? 'Runner',
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String? ?? 'Urban Runner & Hive Explorer',
      routesReviewed: (map['routesReviewed'] as num?)?.toInt() ?? 0,
      hazardsReported: (map['hazardsReported'] as num?)?.toInt() ?? 0,
      reputationScore: (map['reputationScore'] as num?)?.toInt() ?? 100,
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? bio,
    int? routesReviewed,
    int? hazardsReported,
    int? reputationScore,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      routesReviewed: routesReviewed ?? this.routesReviewed,
      hazardsReported: hazardsReported ?? this.hazardsReported,
      reputationScore: reputationScore ?? this.reputationScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
