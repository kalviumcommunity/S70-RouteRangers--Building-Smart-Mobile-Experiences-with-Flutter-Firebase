import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/hazard_pin.dart';
import '../models/route_review.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  User? get user => _user;

  List<HazardPin> _hazards = [];
  List<HazardPin> get hazards => _hazards;

  AppState() {
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });

    _firestoreService.getHazardPins().listen((pins) {
      _hazards = pins;
      notifyListeners();
    });
  }

  // --- Auth Actions ---

  Future<bool> signIn(String email, String password) async {
    final cred = await _authService.signInWithEmail(email, password);
    if (cred != null && cred.user != null) {
      _user = cred.user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signUp(String email, String password) async {
    final cred = await _authService.registerWithEmail(email, password);
    if (cred != null && cred.user != null) {
      _user = cred.user;
      notifyListeners();
      return true;
    }
    return false;
  }



  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // --- Firestore Actions ---

  Future<void> addHazard(HazardPin pin) async {
    await _firestoreService.addHazardPin(pin);
  }

  Future<void> addReview(RouteReview review) async {
    await _firestoreService.addRouteReview(review);
  }

  Stream<List<RouteReview>> getRecentReviews() {
    return _firestoreService.getRecentReviews();
  }
}
