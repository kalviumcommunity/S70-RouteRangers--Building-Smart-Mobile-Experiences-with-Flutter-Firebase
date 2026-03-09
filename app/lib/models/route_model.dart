import 'package:flutter/material.dart';

class RouteModel {
  final String name;
  final String stars;
  final String rating;
  final String type; // e.g., 'Running', 'Walking', 'Cycling'
  final String typeEmoji;
  final String dist;
  final String time;
  final String desc;
  final bool verified;
  final Color iconBg;

  const RouteModel({
    required this.name,
    required this.stars,
    required this.rating,
    required this.type,
    required this.typeEmoji,
    required this.dist,
    required this.time,
    required this.desc,
    required this.verified,
    required this.iconBg,
  });
}

class TrendingModel {
  final String emoji;
  final String title;
  final String meta;
  final String rating;
  final String type;
  final Color color;

  const TrendingModel({
    required this.emoji,
    required this.title,
    required this.meta,
    required this.rating,
    required this.type,
    required this.color,
  });
}
