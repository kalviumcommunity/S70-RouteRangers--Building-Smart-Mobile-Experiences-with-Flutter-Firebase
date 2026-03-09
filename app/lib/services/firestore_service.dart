import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hazard_pin.dart';
import '../models/route_review.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Hazard Pins ---

  // Stream of all hazard pins for real-time map updates
  Stream<List<HazardPin>> getHazardPins() {
    return _db.collection('hazards').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => HazardPin.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Add a new hazard pin
  Future<void> addHazardPin(HazardPin pin) async {
    await _db.collection('hazards').add(pin.toMap());
  }

  // --- Route Reviews ---

  Stream<List<RouteReview>> getRouteReviews(String routeName) {
    return _db.collection('reviews')
        .where('routeName', isEqualTo: routeName)
        .orderBy('timestamp', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => RouteReview.fromMap(doc.id, doc.data())).toList();
    });
  }

  Stream<List<RouteReview>> getRecentReviews() {
    return _db.collection('reviews')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => RouteReview.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> addRouteReview(RouteReview review) async {
    await _db.collection('reviews').add(review.toMap());
  }
}
