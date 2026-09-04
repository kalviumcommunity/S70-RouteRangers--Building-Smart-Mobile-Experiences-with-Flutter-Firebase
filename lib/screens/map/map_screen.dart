import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/hazard_model.dart';
import '../../providers/hazard_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/emergency_beacon_sheet.dart';
import '../../widgets/hazard_card.dart';
import '../../widgets/hazard_report_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  HazardModel? _selectedHazard;

  static const LatLng _initialCenter = LatLng(
    AppConstants.defaultLatitude,
    AppConstants.defaultLongitude,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _centerOnUser() async {
    try {
      final pos = await ref.read(userCurrentPositionProvider.future);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error centering on user: $e');
    }
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    switch (type) {
      case 'construction':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'road_closure':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'poor_road':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      case 'heavy_traffic':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'poor_lighting':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  Set<Marker> _buildMarkers(List<HazardModel> hazards) {
    return hazards.map((hazard) {
      return Marker(
        markerId: MarkerId(hazard.id),
        position: LatLng(hazard.latitude, hazard.longitude),
        icon: _getMarkerIcon(hazard.type),
        infoWindow: InfoWindow(
          title: hazard.title,
          snippet: '${hazard.typeLabel} · ${hazard.upvotes} upvotes',
        ),
        onTap: () {
          setState(() {
            _selectedHazard = hazard;
          });
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hazardsAsync = ref.watch(filteredHazardsProvider);
    final selectedFilter = ref.watch(selectedHazardFilterProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialCenter,
              zoom: AppConstants.defaultZoom,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _centerOnUser();
            },
            onLongPress: (latLng) {
              HazardReportSheet.show(
                context,
                latitude: latLng.latitude,
                longitude: latLng.longitude,
              );
            },
            onTap: (_) {
              if (_selectedHazard != null) {
                setState(() {
                  _selectedHazard = null;
                });
              }
            },
            markers: hazardsAsync.maybeWhen(
              data: (hazards) => _buildMarkers(hazards),
              orElse: () => {},
            ),
          ),

          // Top Header & Category Filter Bar
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Search / Instruction pill
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Long-press anywhere on map to report a hazard',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Horizontal Hazard Type Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('all', 'All Hazards', Icons.filter_alt_outlined, selectedFilter),
                      const SizedBox(width: 8),
                      ...AppConstants.hazardTypes.map((typeInfo) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            typeInfo.type,
                            typeInfo.label,
                            typeInfo.icon,
                            selectedFilter,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Selected Hazard Details Popup Card at bottom
          if (_selectedHazard != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: HazardCard(
                hazard: _selectedHazard!,
                onUpvote: () {
                  ref.read(hazardRepositoryProvider).upvoteHazard(_selectedHazard!.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Upvoted hazard! Thank you for validating.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                onTap: () {},
              ),
            ),

          // Floating Action Buttons (Center location & Quick Report)
          Positioned(
            right: 16,
            bottom: _selectedHazard != null ? 180 : 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SOS Safety Beacon Button
                FloatingActionButton.small(
                  heroTag: 'sos_fab',
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  onPressed: () => EmergencyBeaconSheet.show(context),
                  tooltip: 'Safety Beacon & SOS',
                  child: const Icon(Icons.emergency_outlined),
                ),
                const SizedBox(height: 10),

                // Quick Report Button
                FloatingActionButton.small(
                  heroTag: 'report_fab',
                  backgroundColor: AppColors.hazardConstruction,
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    final pos = await ref.read(userCurrentPositionProvider.future);
                    if (context.mounted) {
                      HazardReportSheet.show(
                        context,
                        latitude: pos.latitude,
                        longitude: pos.longitude,
                      );
                    }
                  },
                  tooltip: 'Report Hazard',
                  child: const Icon(Icons.add_location_alt_outlined),
                ),
                const SizedBox(height: 10),

                // Location Centering Button
                FloatingActionButton(
                  heroTag: 'location_fab',
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  elevation: 4,
                  onPressed: _centerOnUser,
                  tooltip: 'My Location',
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String type,
    String label,
    IconData icon,
    String currentFilter,
  ) {
    final isSelected = currentFilter == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(selectedHazardFilterProvider.notifier).state = type;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppColors.onPrimary
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.onPrimary
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
