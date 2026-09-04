import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/geo_utils.dart';
import '../../models/hazard_model.dart';
import '../../models/route_model.dart';
import '../../providers/hazard_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/hazard_report_sheet.dart';

class LiveRouteTrackingScreen extends ConsumerStatefulWidget {
  final RouteModel route;

  const LiveRouteTrackingScreen({
    super.key,
    required this.route,
  });

  @override
  ConsumerState<LiveRouteTrackingScreen> createState() =>
      _LiveRouteTrackingScreenState();
}

class _LiveRouteTrackingScreenState
    extends ConsumerState<LiveRouteTrackingScreen> {
  GoogleMapController? _mapController;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  double _distanceCoveredKm = 0.0;
  HazardModel? _approachingHazard;
  int _currentWaypointIndex = 0;
  final bool _isSimulatingMovement = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;
          if (_isSimulatingMovement && widget.route.coordinates.isNotEmpty) {
            _distanceCoveredKm += 0.015; // Realistic accelerated simulation pace
            if (_currentWaypointIndex < widget.route.coordinates.length - 1) {
              if (_elapsedSeconds % 2 == 0) {
                _currentWaypointIndex++;
                final pt = widget.route.coordinates[_currentWaypointIndex];
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(LatLng(pt.latitude, pt.longitude)),
                );
              }
            }
          }
        });
        _checkApproachingHazards();
      }
    });
  }

  void _checkApproachingHazards() {
    final hazards = ref.read(hazardsStreamProvider).asData?.value ?? [];
    if (hazards.isNotEmpty && _approachingHazard == null && _elapsedSeconds >= 4) {
      setState(() {
        _approachingHazard = hazards.first;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  String _formatElapsedTime() {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _calculatePace() {
    if (_distanceCoveredKm <= 0.01) return '5:18 /km';
    final paceSeconds = (_elapsedSeconds / _distanceCoveredKm).round();
    final pMin = (paceSeconds ~/ 60).clamp(3, 12);
    final pSec = (paceSeconds % 60).toString().padLeft(2, '0');
    return '$pMin:$pSec /km';
  }

  Set<Polyline> _buildPolyline() {
    if (widget.route.coordinates.isEmpty) return {};

    final points = widget.route.coordinates
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    return {
      Polyline(
        polylineId: PolylineId(widget.route.id),
        points: points,
        color: AppColors.primary,
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (widget.route.coordinates.isNotEmpty) {
      final currentPt = widget.route.coordinates[_currentWaypointIndex.clamp(0, widget.route.coordinates.length - 1)];

      // Live Active Runner Position Marker
      markers.add(
        Marker(
          markerId: const MarkerId('live_runner'),
          position: LatLng(currentPt.latitude, currentPt.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You (Live Navigation)'),
        ),
      );

      // Finish Marker
      final last = widget.route.coordinates.last;
      markers.add(
        Marker(
          markerId: const MarkerId('finish'),
          position: LatLng(last.latitude, last.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Finish Goal'),
        ),
      );
    }

    return markers;
  }

  void _showFinishDialog() {
    _timer?.cancel();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: AppColors.primaryDark, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Run Completed! 🐝', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Great workout on ${widget.route.name}!',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryStat('Distance', GeoUtils.formatDistance(_distanceCoveredKm), AppColors.primaryDark),
                      _buildSummaryStat('Duration', _formatElapsedTime(), AppColors.success),
                      _buildSummaryStat('Avg Pace', _calculatePace(), AppColors.info),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hive Safety Score Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('⭐️ ${widget.route.safetyRating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initialTarget = widget.route.coordinates.isNotEmpty
        ? LatLng(
            widget.route.coordinates.first.latitude,
            widget.route.coordinates.first.longitude,
          )
        : const LatLng(12.9716, 77.5946);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route.name),
        actions: [
          // Live Simulation Badge & Toggle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.verifiedBadgeBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gps_fixed, size: 12, color: AppColors.verifiedBadge),
                SizedBox(width: 4),
                Text('GPS Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.verifiedBadge)),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // Live Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 15.5,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            polylines: _buildPolyline(),
            markers: _buildMarkers(),
            onMapCreated: (controller) => _mapController = controller,
          ),

          // Top Proximity Hazard Alert Banner
          if (_approachingHazard != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.hazardConstruction,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '⚠️ Approaching Hazard: ${_approachingHazard!.title}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${_approachingHazard!.description} (~120m ahead on route)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          onPressed: () => setState(() => _approachingHazard = null),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Tracking HUD Dashboard
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Route Title & Guard status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.route.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.verifiedBadgeBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield, size: 12, color: AppColors.verifiedBadge),
                              SizedBox(width: 4),
                              Text(
                                'Hive Guard Active',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.verifiedBadge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Metrics Grid (Elapsed Time, Distance, Pace)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHUDMetric(
                          context,
                          label: 'TIME',
                          value: _formatElapsedTime(),
                        ),
                        Container(width: 1, height: 36, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        _buildHUDMetric(
                          context,
                          label: 'DISTANCE',
                          value: GeoUtils.formatDistance(_distanceCoveredKm),
                        ),
                        Container(width: 1, height: 36, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        _buildHUDMetric(
                          context,
                          label: 'LIVE PACE',
                          value: _calculatePace(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Controls Row (Pause/Resume, Finish, Quick Hazard Report)
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: _isPaused ? 'Resume' : 'Pause',
                            icon: _isPaused ? Icons.play_arrow : Icons.pause,
                            variant: ButtonVariant.outline,
                            onPressed: () {
                              setState(() {
                                _isPaused = !_isPaused;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'Report Hazard',
                            icon: Icons.add_location_alt_outlined,
                            variant: ButtonVariant.secondary,
                            onPressed: () {
                              HazardReportSheet.show(
                                context,
                                latitude: widget.route.coordinates.isNotEmpty
                                    ? widget.route.coordinates[_currentWaypointIndex.clamp(0, widget.route.coordinates.length - 1)].latitude
                                    : 12.9716,
                                longitude: widget.route.coordinates.isNotEmpty
                                    ? widget.route.coordinates[_currentWaypointIndex.clamp(0, widget.route.coordinates.length - 1)].longitude
                                    : 77.5946,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'Finish',
                            icon: Icons.stop_rounded,
                            variant: ButtonVariant.danger,
                            onPressed: _showFinishDialog,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUDMetric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
