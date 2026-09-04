import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class HazardModel {
  final String id;
  final String userId;
  final String userName;
  final String type;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final DateTime createdAt;
  final String status;
  final int upvotes;

  const HazardModel({
    required this.id,
    required this.userId,
    this.userName = 'Community Member',
    required this.type,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.createdAt,
    this.status = 'active',
    this.upvotes = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'location': GeoPoint(latitude, longitude),
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'upvotes': upvotes,
    };
  }

  factory HazardModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    double lat = 0.0;
    double lng = 0.0;

    if (map['location'] is GeoPoint) {
      final geo = map['location'] as GeoPoint;
      lat = geo.latitude;
      lng = geo.longitude;
    } else {
      lat = (map['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (map['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    return HazardModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Community Runner',
      type: map['type'] as String? ?? 'other',
      title: map['title'] as String? ?? 'Reported Hazard',
      description: map['description'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      imageUrl: map['imageUrl'] as String?,
      createdAt: parseDateTime(map['createdAt']),
      status: map['status'] as String? ?? 'active',
      upvotes: (map['upvotes'] as num?)?.toInt() ?? 1,
    );
  }

  factory HazardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HazardModel.fromMap(data, doc.id);
  }

  HazardModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? type,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
    DateTime? createdAt,
    String? status,
    int? upvotes,
  }) {
    return HazardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      upvotes: upvotes ?? this.upvotes,
    );
  }

  /// Get color corresponding to hazard category
  Color get color {
    switch (type) {
      case 'construction':
        return AppColors.hazardConstruction;
      case 'road_closure':
        return AppColors.hazardClosure;
      case 'poor_road':
        return AppColors.hazardPoorRoad;
      case 'heavy_traffic':
        return AppColors.hazardTraffic;
      case 'poor_lighting':
        return AppColors.hazardLighting;
      default:
        return AppColors.hazardOther;
    }
  }

  /// Get icon corresponding to hazard category
  IconData get icon {
    switch (type) {
      case 'construction':
        return Icons.construction;
      case 'road_closure':
        return Icons.block;
      case 'poor_road':
        return Icons.broken_image_outlined;
      case 'heavy_traffic':
        return Icons.directions_car;
      case 'poor_lighting':
        return Icons.lightbulb_outline;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  /// Get readable label
  String get typeLabel {
    final found = AppConstants.hazardTypes.where((element) => element.type == type);
    if (found.isNotEmpty) {
      return found.first.label;
    }
    return 'Hazard';
  }
}
