import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.asData?.value;
});

/// Custom local state to hold active session profile
final customUserProfileStateProvider = StateProvider<UserModel?>((ref) => null);

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final customUser = ref.watch(customUserProfileStateProvider);
  if (customUser != null) {
    return Stream.value(customUser);
  }

  final user = ref.watch(currentUserProvider);
  if (user == null) {
    // Default guest profile when not logged in or during offline demo
    return Stream.value(
      UserModel(
        id: 'guest_user',
        email: 'runner@routehive.app',
        name: 'Alex Rivera',
        bio: 'Marathon runner & night cyclist exploring safe urban trails',
        routesReviewed: 14,
        hazardsReported: 6,
        reputationScore: 280,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    );
  }

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUserStream(user.uid);
});

/// Auth Controller to manage sign in, register, and reset flows
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final Ref _ref;

  AuthController(this._authRepo, this._ref) : super(const AuthState());

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final namePart = email.contains('@') ? email.split('@').first : 'Runner';
      final formattedName = namePart.isNotEmpty
          ? '${namePart[0].toUpperCase()}${namePart.substring(1)}'
          : 'Runner';

      _ref.read(customUserProfileStateProvider.notifier).state = UserModel(
        id: 'user_active',
        email: email.trim(),
        name: formattedName,
        bio: 'Urban runner & cyclist exploring safe routes with RouteHive',
        routesReviewed: 12,
        hazardsReported: 5,
        reputationScore: 240,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepo.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      _ref.read(customUserProfileStateProvider.notifier).state = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        name: name.trim(),
        bio: 'New RouteHive Explorer & Community Contributor',
        routesReviewed: 0,
        hazardsReported: 0,
        reputationScore: 100,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepo.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    _ref.read(customUserProfileStateProvider.notifier).state = null;
    await _authRepo.signOut();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthController(authRepo, ref);
});
