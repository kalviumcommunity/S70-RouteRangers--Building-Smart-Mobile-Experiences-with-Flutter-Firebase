import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/app_state.dart';
import '../models/hazard_pin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  LatLng _currentPosition = const LatLng(0, 0);
  bool _isLoading = true;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable them in your settings.')));
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen((Position pos) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
            _mapController.move(_currentPosition, _mapController.camera.zoom);
          });
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onMapLongPress(LatLng pos) {
    _showHazardForm(context, pos);
  }

  void _showHazardForm(BuildContext context, LatLng pos) {
    int rating = 0;
    String selectedType = '🚧 Construction';
    final descController = TextEditingController();
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 16, left: 20, right: 20, top: 12),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('📍 Report Hazard here', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text('Location: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}', style: const TextStyle(color: Color(0xFF999999), fontSize: 13)),
            const SizedBox(height: 16),
            const Text('Danger Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Row(children: List.generate(5, (i) => GestureDetector(
              onTap: () => setS(() => rating = i + 1),
              child: Padding(padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.star_rounded, size: 32, color: i < rating ? const Color(0xFFFFC107) : Colors.grey[300])),
            ))),
            const SizedBox(height: 16),
            const Text('Hazard Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedType,
              isExpanded: true,
              items: ['🔦 Poor Lighting', '🚗 Traffic', '🚧 Construction', '🕳️ Road Damage', '⚠️ Unsafe Area']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setS(() => selectedType = v!),
            ),
            const SizedBox(height: 16),
            TextField(controller: descController, decoration: const InputDecoration(hintText: 'Description (optional)')),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
              onPressed: () {
                if (rating == 0) return;
                final pin = HazardPin(
                  id: '',
                  type: selectedType,
                  safetyRating: rating,
                  description: descController.text,
                  location: GeoPoint(pos.latitude, pos.longitude),
                  timestamp: DateTime.now(),
                  userId: appState.user?.uid ?? 'anonymous',
                );
                appState.addHazard(pin);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Pin Dropped!')));
              },
              child: const Text('Drop Pin', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            )),
            const SizedBox(height: 20),
            ]),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    List<Marker> markers = appState.hazards.map((h) {
      return Marker(
        point: LatLng(h.location.latitude, h.location.longitude),
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.type, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    Text('Danger Level: ${h.safetyRating}/5', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    if (h.description != null && h.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(h.description!, style: const TextStyle(fontSize: 14)),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
          child: Icon(
            Icons.location_on,
            color: h.safetyRating > 3 ? Colors.red : Colors.orange,
            size: 48,
            shadows: [Shadow(color: Colors.black.withAlpha(60), blurRadius: 8, offset: const Offset(0, 4))],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition,
                  initialZoom: 15.0,
                  onLongPress: (tapPosition, point) => _onMapLongPress(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.routehive.app',
                  ),
                  MarkerLayer(
                    markers: [
                      ...markers,
                      Marker(
                        point: _currentPosition,
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withAlpha(30),
                            border: Border.all(color: Colors.blue.withAlpha(80), width: 1),
                          ),
                          child: const Center(
                            child: Icon(Icons.circle, color: Colors.blue, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          // Floating Search Bar
          Positioned(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16,
            child: Container(
              height: 48, padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Row(children: [
                if (Navigator.of(context).canPop()) ...[
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A2E), size: 22),
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
                  const SizedBox(width: 10),
                ],
                Expanded(child: Text('Search location…', style: TextStyle(color: Colors.grey[400], fontSize: 14))),
                CircleAvatar(radius: 16, backgroundColor: const Color(0xFFFFF3E0),
                  child: const Icon(Icons.person, color: Color(0xFFFFC107), size: 18)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
