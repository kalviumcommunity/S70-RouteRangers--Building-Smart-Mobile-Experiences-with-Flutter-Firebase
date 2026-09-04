import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/geo_utils.dart';
import '../../models/route_model.dart';
import '../../providers/hazard_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/verified_hive_badge.dart';
import '../navigation/live_route_tracking_screen.dart';
import '../review/create_review_screen.dart';

class RouteDetailsScreen extends ConsumerStatefulWidget {
  final String routeId;

  const RouteDetailsScreen({
    super.key,
    required this.routeId,
  });

  @override
  ConsumerState<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends ConsumerState<RouteDetailsScreen> {
  final Set<String> _helpfulReviews = {};

  Set<Polyline> _buildPolyline(RouteModel route) {
    if (route.coordinates.isEmpty) return {};

    final points = route.coordinates
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    return {
      Polyline(
        polylineId: PolylineId(route.id),
        points: points,
        color: AppColors.primary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  Set<Marker> _buildMarkers(RouteModel route) {
    if (route.coordinates.isEmpty) return {};

    final first = route.coordinates.first;
    final last = route.coordinates.last;

    return {
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(first.latitude, first.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start Point'),
      ),
      Marker(
        markerId: const MarkerId('finish'),
        position: LatLng(last.latitude, last.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Finish Point'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routeAsync = ref.watch(singleRouteProvider(widget.routeId));
    final reviewsAsync = ref.watch(routeReviewsStreamProvider(widget.routeId));
    final hazardsAsync = ref.watch(hazardsStreamProvider);

    return routeAsync.when(
      data: (route) {
        if (route == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Route Details')),
            body: const EmptyStateView(
              icon: Icons.error_outline,
              title: 'Route Not Found',
              description: 'This route may have been removed or archived.',
            ),
          );
        }

        final initialTarget = route.coordinates.isNotEmpty
            ? LatLng(route.coordinates.first.latitude, route.coordinates.first.longitude)
            : const LatLng(12.9716, 77.5946);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Interactive Map Preview Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: initialTarget,
                          zoom: 14.2,
                        ),
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        polylines: _buildPolyline(route),
                        markers: _buildMarkers(route),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header info & Verified Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (route.isVerifiedHive)
                            const VerifiedHiveBadge()
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Community Safe Route',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          Text(
                            'Mapped by ${route.creatorName}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        route.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Distance, Duration, Est. Pace Pills
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatPill(
                            context,
                            icon: Icons.straighten,
                            label: GeoUtils.formatDistance(route.distanceKm),
                          ),
                          _buildStatPill(
                            context,
                            icon: Icons.timer_outlined,
                            label: GeoUtils.formatDuration(route.durationMinutes),
                          ),
                          _buildStatPill(
                            context,
                            icon: Icons.speed,
                            label: 'Est. 5:15 /km',
                          ),
                          _buildStatPill(
                            context,
                            icon: Icons.terrain,
                            label: '+18m gain',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Route Description
                      if (route.description.isNotEmpty) ...[
                        Text(
                          route.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Condition Tags
                      if (route.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: route.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Multi-Metric Safety Score Breakdown Card
                      _buildSafetyBreakdown(context, route),
                      const SizedBox(height: 24),

                      // Route Safety Checklist
                      _buildCorridorSafetyChecklist(context),
                      const SizedBox(height: 24),

                      // Hazard Warnings Along this Route
                      _buildHazardsSection(context, hazardsAsync, route),
                      const SizedBox(height: 24),

                      // Community Reviews & Rating Breakdown
                      _buildReviewsHeader(context, route),
                      const SizedBox(height: 12),

                      reviewsAsync.when(
                        data: (reviews) {
                          if (reviews.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: EmptyStateView(
                                icon: Icons.rate_review_outlined,
                                title: 'No Reviews Yet',
                                description: 'Be the first runner or cyclist to review this safe route!',
                              ),
                            );
                          }

                          return Column(
                            children: reviews.map((review) {
                              final isHelpful = _helpfulReviews.contains(review.id);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: AppColors.primaryContainer,
                                              child: Text(
                                                review.userName.isNotEmpty
                                                    ? review.userName[0].toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primaryDark,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              review.userName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateFormatter.timeAgo(review.createdAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Star score display
                                    Row(
                                      children: [
                                        _buildRatingMiniBadge('Safety', review.safetyRating, AppColors.success),
                                        const SizedBox(width: 8),
                                        _buildRatingMiniBadge('Light', review.lightingRating, AppColors.primary),
                                        const SizedBox(width: 8),
                                        _buildRatingMiniBadge('Surface', review.surfaceRating, AppColors.info),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    if (review.comment.isNotEmpty) ...[
                                      Text(
                                        review.comment,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.4,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],

                                    // Helpful Action
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isHelpful) {
                                                _helpfulReviews.remove(review.id);
                                              } else {
                                                _helpfulReviews.add(review.id);
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                isHelpful ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                                size: 14,
                                                color: isHelpful ? AppColors.primaryDark : AppColors.textMutedLight,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isHelpful ? 'Helpful (1)' : 'Helpful',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isHelpful ? AppColors.primaryDark : AppColors.textMutedLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text('Error loading reviews: $err')),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Write Review',
                      variant: ButtonVariant.outline,
                      icon: Icons.rate_review_outlined,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreateReviewScreen(route: route),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Start Activity HUD',
                      icon: Icons.play_arrow_rounded,
                      variant: ButtonVariant.primary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LiveRouteTrackingScreen(route: route),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading route: $err')),
      ),
    );
  }

  Widget _buildSafetyBreakdown(BuildContext context, RouteModel route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safety Score Breakdown',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '${route.reviewCount} Reviews',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildScoreBar('Overall Safety', route.safetyRating, AppColors.success, isDark),
          const SizedBox(height: 10),
          _buildScoreBar('Street Lighting', route.lightingRating, AppColors.primary, isDark),
          const SizedBox(height: 10),
          _buildScoreBar('Road & Surface Quality', route.surfaceRating, AppColors.info, isDark),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String title, double score, Color color, bool isDark) {
    final percent = (score / 5.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              '${score.toStringAsFixed(1)} / 5.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCorridorSafetyChecklist(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Corridor Safety Attributes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCheckItem('Dedicated pedestrian & cycling path separated from road'),
          _buildCheckItem('LED street illumination active dusk to dawn'),
          _buildCheckItem('High community runner frequency (popular safe loop)'),
          _buildCheckItem('Multiple emergency exit intersections & taxi stands'),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHazardsSection(
    BuildContext context,
    AsyncValue<List<dynamic>> hazardsAsync,
    RouteModel route,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return hazardsAsync.when(
      data: (hazards) {
        if (hazards.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.hazardConstruction),
                  const SizedBox(width: 8),
                  Text(
                    'Hazards Near This Route',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Community reported ${hazards.length} alerts in this vicinity. Exercise caution.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildReviewsHeader(BuildContext context, RouteModel route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Community Reviews',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          '${route.reviewCount} total',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingMiniBadge(String label, double rating, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ${rating.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.star, size: 10, color: color),
        ],
      ),
    );
  }

  Widget _buildStatPill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
