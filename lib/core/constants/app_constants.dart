import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'RouteHive';
  static const String appTagline = 'Smart, safe navigation for runners & cyclists';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String hazardsCollection = 'hazards';
  static const String routesCollection = 'routes';
  static const String reviewsCollection = 'reviews';

  // Default Map Center (Default to Bangalore Urban or generic center)
  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 77.5946;
  static const double defaultZoom = 14.0;

  // Hazard Type Keys
  static const String hazardConstruction = 'construction';
  static const String hazardClosure = 'road_closure';
  static const String hazardPoorRoad = 'poor_road';
  static const String hazardTraffic = 'heavy_traffic';
  static const String hazardLighting = 'poor_lighting';
  static const String hazardOther = 'other';

  // Hazard Type Definitions
  static const List<HazardTypeInfo> hazardTypes = [
    HazardTypeInfo(
      type: 'construction',
      label: 'Construction',
      icon: Icons.construction,
      description: 'Roadwork, digging, or pathway blocking equipment',
    ),
    HazardTypeInfo(
      type: 'road_closure',
      label: 'Road Closure',
      icon: Icons.block,
      description: 'Blocked access, barricades, or private closure',
    ),
    HazardTypeInfo(
      type: 'poor_road',
      label: 'Poor Road Condition',
      icon: Icons.broken_image_outlined,
      description: 'Potholes, unpaved gravel, broken sidewalks',
    ),
    HazardTypeInfo(
      type: 'heavy_traffic',
      label: 'Heavy Traffic',
      icon: Icons.directions_car,
      description: 'Aggressive vehicular flow, narrow crossing, no shoulder',
    ),
    HazardTypeInfo(
      type: 'poor_lighting',
      label: 'Poor Lighting',
      icon: Icons.lightbulb_outline,
      description: 'Dark alleys, broken street lamps, low visibility at night',
    ),
    HazardTypeInfo(
      type: 'other',
      label: 'Other Hazard',
      icon: Icons.warning_amber_rounded,
      description: 'Stray animals, debris, temporary events or hazards',
    ),
  ];

  // Route Review Available Tags
  static const List<String> reviewTags = [
    'Well Lit',
    'Low Traffic',
    'Smooth Surface',
    'Bike Lane',
    'Scenic View',
    'Paved Trail',
    'Night Safe',
    'Wide Shoulders',
    'Crowded',
    'Poor Lighting',
    'Heavy Traffic',
    'Rough Road',
    'Steep Incline',
    'Blind Corners',
  ];
}

class HazardTypeInfo {
  final String type;
  final String label;
  final IconData icon;
  final String description;

  const HazardTypeInfo({
    required this.type,
    required this.label,
    required this.icon,
    required this.description,
  });
}
