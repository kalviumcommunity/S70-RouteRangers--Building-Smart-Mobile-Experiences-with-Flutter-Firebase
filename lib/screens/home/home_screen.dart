import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hazard_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/emergency_beacon_sheet.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/hazard_card.dart';
import '../../widgets/hazard_report_sheet.dart';
import '../../widgets/route_card.dart';
import '../main_nav_screen.dart';
import '../route_creation/create_route_screen.dart';
import '../route_details/route_details_screen.dart';

final selectedActivityFilterProvider = StateProvider<String>((ref) => 'all');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getVisibilityStatus() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      return '☀️ Optimal Daylight · Clear Visibility';
    } else if (hour >= 18 && hour < 20) {
      return '🌅 Dusk / Twilight · Street Lighting Active';
    } else {
      return '🌙 Night Run Active · Well-Lit Corridors Recommended';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final user = ref.watch(currentUserProvider);
    final hazardsAsync = ref.watch(hazardsStreamProvider);
    final routesAsync = ref.watch(routesStreamProvider);
    final activityFilter = ref.watch(selectedActivityFilterProvider);

    final displayName = userProfileAsync.asData?.value?.name ??
        user?.displayName ??
        'Runner';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hive_rounded,
                size: 20,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Route',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const TextSpan(
                    text: 'Hive',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency_outlined, color: AppColors.error),
            tooltip: 'Safety Beacon & SOS',
            onPressed: () => EmergencyBeaconSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hive Alerts: 2 new hazards reported nearby today.'),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(hazardsStreamProvider);
          ref.invalidate(routesStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Greeting & Hive Live Ticker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, $displayName 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getVisibilityStatus(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Interactive Segmented Activity Filter
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildActivityTab(context, ref, 'all', '✨ All Safe Routes', activityFilter),
                    const SizedBox(width: 8),
                    _buildActivityTab(context, ref, 'run', '🏃 Running Loops', activityFilter),
                    const SizedBox(width: 8),
                    _buildActivityTab(context, ref, 'cycle', '🚴 Bike Lanes', activityFilter),
                    const SizedBox(width: 8),
                    _buildActivityTab(context, ref, 'night', '🌙 Night Safe', activityFilter),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Safety Snapshot Hero Card
              _buildSafetySummary(context, hazardsAsync, routesAsync),
              const SizedBox(height: 20),

              // Quick Action Tiles
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.add_location_alt_outlined,
                      title: 'Report Hazard',
                      subtitle: 'Alert the Hive',
                      accentColor: AppColors.hazardConstruction,
                      onTap: () async {
                        final pos = await ref.read(userCurrentPositionProvider.future);
                        if (context.mounted) {
                          HazardReportSheet.show(
                            context,
                            latitude: pos.latitude,
                            longitude: pos.longitude,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.add_road_outlined,
                      title: 'Map Route',
                      subtitle: 'Draw safe path',
                      accentColor: AppColors.primaryDark,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateRouteScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.explore_outlined,
                      title: 'Live Map',
                      subtitle: 'Track vicinity',
                      accentColor: AppColors.info,
                      onTap: () {
                        ref.read(mainNavIndexProvider.notifier).state = 1;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Featured Safe Routes Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Curated Safe Routes',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(mainNavIndexProvider.notifier).state = 2; // Discover tab
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explore All', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right, size: 16, color: AppColors.primaryDark),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Filtered Routes Feed
              routesAsync.when(
                data: (routes) {
                  var filtered = routes;
                  if (activityFilter == 'night') {
                    filtered = routes.where((r) => r.lightingRating >= 4.4 || r.tags.contains('Night Safe') || r.tags.contains('Well Lit')).toList();
                  } else if (activityFilter == 'cycle') {
                    filtered = routes.where((r) => r.tags.contains('Bike Lane') || r.distanceKm > 4.5).toList();
                  } else if (activityFilter == 'run') {
                    filtered = routes.where((r) => r.tags.contains('Smooth Surface') || r.tags.contains('Paved Trail')).toList();
                  }

                  if (filtered.isEmpty) {
                    filtered = routes;
                  }

                  return Column(
                    children: filtered.take(3).map((route) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RouteCard(
                          route: route,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RouteDetailsScreen(routeId: route.id),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading routes: $err'),
                ),
              ),
              const SizedBox(height: 20),

              // Live Community Hazards Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.hazardConstruction.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.hazardConstruction),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Hazard Alerts',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(mainNavIndexProvider.notifier).state = 1; // Map tab
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('View on Map', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Hazards Stream Feed
              hazardsAsync.when(
                data: (hazards) {
                  final activeHazards = hazards.take(3).toList();
                  if (activeHazards.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'All Clear Around You',
                      description: 'No active hazards reported in your perimeter. Safe runs!',
                    );
                  }
                  return Column(
                    children: activeHazards.map((hazard) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: HazardCard(
                          hazard: hazard,
                          onUpvote: () {
                            ref.read(hazardRepositoryProvider).upvoteHazard(hazard.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you for verifying this hazard report!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          onTap: () {
                            ref.read(mainNavIndexProvider.notifier).state = 1;
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading hazards: $err'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTab(
    BuildContext context,
    WidgetRef ref,
    String key,
    String label,
    String selectedKey,
  ) {
    final isSelected = key == selectedKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(selectedActivityFilterProvider.notifier).state = key;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryContainer : AppColors.primary)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.onPrimary)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetySummary(
    BuildContext context,
    AsyncValue<List<dynamic>> hazardsAsync,
    AsyncValue<List<dynamic>> routesAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hazardCount = hazardsAsync.asData?.value.length ?? 0;
    final routeCount = routesAsync.asData?.value.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Hive Safety Snapshot',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.verifiedBadgeBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '● Live Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.verifiedBadge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSnapshotItem(
                  context,
                  title: '$routeCount',
                  subtitle: 'Safe Loops',
                  color: AppColors.primaryDark,
                ),
              ),
              Container(width: 1, height: 32, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              Expanded(
                child: _buildSnapshotItem(
                  context,
                  title: '$hazardCount',
                  subtitle: 'Active Hazards',
                  color: AppColors.hazardConstruction,
                ),
              ),
              Container(width: 1, height: 32, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              Expanded(
                child: _buildSnapshotItem(
                  context,
                  title: '98%',
                  subtitle: 'Safe Index',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: accentColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
