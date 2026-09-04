import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/geo_utils.dart';
import '../models/route_model.dart';
import '../screens/navigation/live_route_tracking_screen.dart';
import 'verified_hive_badge.dart';

class RouteCard extends StatefulWidget {
  final RouteModel route;
  final VoidCallback onTap;

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final route = widget.route;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Category tag, Verified Badge, Bookmark Icon
                Row(
                  children: [
                    if (route.isVerifiedHive) ...[
                      const VerifiedHiveBadge(isCompact: true),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_run,
                            size: 13,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${GeoUtils.formatDistance(route.distanceKm)} · ${GeoUtils.formatDuration(route.durationMinutes)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Interactive Bookmark Action
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isBookmarked
                                  ? 'Saved "${route.name}" to your bookmarks.'
                                  : 'Removed from bookmarks.',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined,
                          size: 20,
                          color: _isBookmarked ? AppColors.primaryDark : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Route Title
                Text(
                  route.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),

                // Description snippet
                if (route.description.isNotEmpty) ...[
                  Text(
                    route.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Metrics Row: Safety, Lighting, Surface Quality
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark.withValues(alpha: 0.6)
                        : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        context,
                        label: 'Safety',
                        value: route.safetyRating,
                        color: AppColors.success,
                        icon: Icons.shield_outlined,
                      ),
                      _buildDivider(isDark),
                      _buildMetric(
                        context,
                        label: 'Lighting',
                        value: route.lightingRating,
                        color: AppColors.primary,
                        icon: Icons.lightbulb_outline,
                      ),
                      _buildDivider(isDark),
                      _buildMetric(
                        context,
                        label: 'Surface',
                        value: route.surfaceRating,
                        color: AppColors.info,
                        icon: Icons.terrain_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom Action Row: Tag pills and Quick "Start" action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: route.tags.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Quick Start Activity Button
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LiveRouteTrackingScreen(route: route),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 16, color: AppColors.onPrimary),
                            SizedBox(width: 4),
                            Text(
                              'Start',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            Row(
              children: [
                Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.star_rounded, size: 12, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}
