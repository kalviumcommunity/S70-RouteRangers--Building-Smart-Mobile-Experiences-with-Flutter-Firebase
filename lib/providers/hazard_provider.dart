import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hazard_model.dart';
import '../repositories/hazard_repository.dart';
import 'auth_provider.dart';

final hazardRepositoryProvider = Provider<HazardRepository>((ref) {
  return HazardRepository();
});

/// Live stream of active hazards
final hazardsStreamProvider = StreamProvider<List<HazardModel>>((ref) {
  final repository = ref.watch(hazardRepositoryProvider);
  return repository.getHazardsStream();
});

/// Selected hazard type filter ('all', 'construction', 'poor_lighting', etc.)
final selectedHazardFilterProvider = StateProvider<String>((ref) => 'all');

/// Filtered list of hazards based on selected category
final filteredHazardsProvider = Provider<AsyncValue<List<HazardModel>>>((ref) {
  final hazardsAsync = ref.watch(hazardsStreamProvider);
  final filter = ref.watch(selectedHazardFilterProvider);

  return hazardsAsync.whenData((hazards) {
    if (filter == 'all') {
      return hazards;
    }
    return hazards.where((h) => h.type == filter).toList();
  });
});

/// User's own reported hazards
final userHazardsProvider = StreamProvider<List<HazardModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(<HazardModel>[]);
  }
  final repository = ref.watch(hazardRepositoryProvider);
  return repository.getUserHazardsStream(user.uid);
});

/// State for reporting hazards
class HazardReportState {
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const HazardReportState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  HazardReportState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return HazardReportState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class HazardReportNotifier extends StateNotifier<HazardReportState> {
  final HazardRepository _repository;

  HazardReportNotifier(this._repository) : super(const HazardReportState());

  Future<bool> reportHazard({
    required String userId,
    required String userName,
    required String type,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false);
    try {
      await _repository.reportHazard(
        userId: userId,
        userName: userName,
        type: type,
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        imageFile: imageFile,
      );
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = const HazardReportState();
  }
}

final hazardReportNotifierProvider =
    StateNotifierProvider<HazardReportNotifier, HazardReportState>((ref) {
  final repo = ref.watch(hazardRepositoryProvider);
  return HazardReportNotifier(repo);
});
