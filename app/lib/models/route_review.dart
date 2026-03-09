import 'package:cloud_firestore/cloud_firestore.dart';

class RouteReview {
  final String id;
  final String routeName;
  final double rating;
  final String comment;
  final List<String> tags;
  final DateTime timestamp;
  final String userId;
  final String userName;

  RouteReview({
    required this.id,
    required this.routeName,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.timestamp,
    required this.userId,
    required this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'routeName': routeName,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'timestamp': timestamp,
      'userId': userId,
      'userName': userName,
    };
  }

  factory RouteReview.fromMap(String id, Map<String, dynamic> map) {
    return RouteReview(
      id: id,
      routeName: map['routeName'] ?? 'Unknown Route',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
    );
  }
}
