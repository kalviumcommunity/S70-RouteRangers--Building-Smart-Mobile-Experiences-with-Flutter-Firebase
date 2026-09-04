import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService.instance;
});

/// Future provider for the initial user position
final userCurrentPositionProvider = FutureProvider<Position>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentPosition();
});

/// Stream of real-time positions
final userPositionStreamProvider = StreamProvider<Position>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.getPositionStream();
});
