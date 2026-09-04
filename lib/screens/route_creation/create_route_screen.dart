import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/geo_utils.dart';
import '../../models/route_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateRouteScreen extends ConsumerStatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  ConsumerState<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends ConsumerState<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<LatLng> _points = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double _calculateTotalDistanceKm() {
    if (_points.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < _points.length - 1; i++) {
      total += GeoUtils.calculateDistanceKm(
        _points[i].latitude,
        _points[i].longitude,
        _points[i + 1].latitude,
        _points[i + 1].longitude,
      );
    }
    return total;
  }

  Future<void> _submitRoute() async {
    if (!_formKey.currentState!.validate()) return;
    if (_points.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please tap on the map to add at least 2 route waypoints.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      final userProfile = ref.read(currentUserProfileProvider).asData?.value;

      final creatorId = user?.uid ?? 'guest_user';
      final creatorName = userProfile?.name ?? user?.displayName ?? 'Community Runner';

      final totalDist = _calculateTotalDistanceKm();
      final estimatedMin = (totalDist * 6.5).round(); // ~6.5 min/km estimate

      final coordinates = _points
          .map((p) => RoutePoint(latitude: p.latitude, longitude: p.longitude))
          .toList();

      final routeRepo = ref.read(routeRepositoryProvider);
      await routeRepo.createRoute(
        creatorId: creatorId,
        creatorName: creatorName,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        distanceKm: double.parse(totalDist.toStringAsFixed(1)),
        durationMinutes: estimatedMin > 0 ? estimatedMin : 10,
        coordinates: coordinates,
        tags: _selectedTags,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Route successfully mapped and published to the Hive!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish route: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalDistance = _calculateTotalDistanceKm();

    final polyline = Polyline(
      polylineId: const PolylineId('creation_poly'),
      points: _points,
      color: AppColors.primary,
      width: 5,
    );

    final markers = _points.asMap().entries.map((entry) {
      final idx = entry.key;
      final pt = entry.value;
      return Marker(
        markerId: MarkerId('pt_$idx'),
        position: pt,
        icon: idx == 0
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : idx == _points.length - 1
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map New Safe Route'),
        actions: [
          if (_points.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo last point',
              onPressed: () {
                setState(() {
                  _points.removeLast();
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive Map Area to place waypoints
              SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
                        zoom: 14.0,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      polylines: {polyline},
                      markers: markers,
                      onTap: (latLng) {
                        setState(() {
                          _points.add(latLng);
                        });
                      },
                    ),
                    Positioned(
                      top: 10,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tap map to add path points (${_points.length})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              GeoUtils.formatDistance(totalDistance),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Name
                    CustomTextField(
                      label: 'Route Name',
                      hintText: 'e.g. Koramangala Green Loop',
                      controller: _nameController,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a route name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Route Description
                    CustomTextField(
                      label: 'Route Description',
                      hintText: 'Share surface conditions, lighting hours, or safety advice...',
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please describe the route';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Tags selector
                    const Text(
                      'Route Tags',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: AppConstants.reviewTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          checkmarkColor: AppColors.onPrimary,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.onPrimary : null,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 26),

                    // Submit Button
                    CustomButton(
                      text: 'Publish Route to Hive',
                      isLoading: _isSubmitting,
                      onPressed: _submitRoute,
                      icon: Icons.publish_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
