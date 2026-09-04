import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_model.dart';
import '../repositories/route_repository.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository();
});

/// Stream of all community routes
final routesStreamProvider = StreamProvider<List<RouteModel>>((ref) {
  final repository = ref.watch(routeRepositoryProvider);
  return repository.getRoutesStream();
});

/// Single route provider by ID
final singleRouteProvider =
    FutureProvider.family<RouteModel?, String>((ref, routeId) async {
  final repository = ref.watch(routeRepositoryProvider);
  return repository.getRouteById(routeId);
});

/// Search & Filter criteria providers
final routeSearchQueryProvider = StateProvider<String>((ref) => '');
final routeFilterVerifiedOnlyProvider = StateProvider<bool>((ref) => false);
final routeSortByProvider = StateProvider<String>((ref) => 'safety'); // 'safety', 'distance', 'reviews'
final routeSelectedTagProvider = StateProvider<String?>((ref) => null);

/// Filtered and sorted route list
final filteredRoutesProvider = Provider<AsyncValue<List<RouteModel>>>((ref) {
  final routesAsync = ref.watch(routesStreamProvider);
  final query = ref.watch(routeSearchQueryProvider).toLowerCase().trim();
  final verifiedOnly = ref.watch(routeFilterVerifiedOnlyProvider);
  final sortBy = ref.watch(routeSortByProvider);
  final selectedTag = ref.watch(routeSelectedTagProvider);

  return routesAsync.whenData((routes) {
    var result = List<RouteModel>.from(routes);

    // Filter by search query
    if (query.isNotEmpty) {
      result = result
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.description.toLowerCase().contains(query) ||
              r.tags.any((t) => t.toLowerCase().contains(query)))
          .toList();
    }

    // Filter by Verified Hive status
    if (verifiedOnly) {
      result = result.where((r) => r.isVerifiedHive).toList();
    }

    // Filter by tag
    if (selectedTag != null && selectedTag.isNotEmpty) {
      result = result.where((r) => r.tags.contains(selectedTag)).toList();
    }

    // Sort
    if (sortBy == 'safety') {
      result.sort((a, b) => b.safetyRating.compareTo(a.safetyRating));
    } else if (sortBy == 'distance') {
      result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (sortBy == 'reviews') {
      result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    return result;
  });
});
