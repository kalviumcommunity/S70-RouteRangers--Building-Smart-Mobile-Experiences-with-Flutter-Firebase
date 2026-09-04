import 'package:flutter/material.dart';

/// Professional color system tailored for RouteHive.
/// High contrast, minimal, startup aesthetic inspired by Strava, Citymapper & Citizen.
class AppColors {
  AppColors._();

  // Primary Brand - Warm Hive Gold / Amber (Accents & Primary CTAs only)
  static const Color primary = Color(0xFFF59E0B);
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFFCD34D);
  static const Color primaryContainer = Color(0xFFFEF3C7);
  static const Color onPrimary = Color(0xFF111827);

  // Secondary & Dark Accents
  static const Color secondary = Color(0xFF1E293B);
  static const Color secondaryLight = Color(0xFF334155);
  static const Color accent = Color(0xFF10B981);

  // Modern Neutral Surfaces (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Modern Neutral Surfaces (Dark Mode - Deep Slate & Onyx)
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF151C2C);
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF27354A);

  // Safety & Hazard Category Indicators (Clean, High-Readability)
  static const Color hazardConstruction = Color(0xFFEA580C); // Vibrant Orange
  static const Color hazardClosure = Color(0xFFDC2626);      // Crimson
  static const Color hazardPoorRoad = Color(0xFF7C3AED);     // Deep Violet
  static const Color hazardTraffic = Color(0xFF2563EB);      // Cobalt Blue
  static const Color hazardLighting = Color(0xFFDB2777);     // Rose
  static const Color hazardOther = Color(0xFF475569);        // Slate

  // Status & Scores
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Verified Badge
  static const Color verifiedBadge = Color(0xFF059669);
  static const Color verifiedBadgeBackground = Color(0xFFD1FAE5);
  static const Color verifiedBadgeBackgroundDark = Color(0xFF064E3B);
}
