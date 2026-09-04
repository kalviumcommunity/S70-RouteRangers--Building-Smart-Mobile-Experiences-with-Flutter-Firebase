import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserRepository {
  FirebaseFirestore? _firestoreInstance;

  UserRepository({
    FirebaseFirestore? firestore,
  }) : _firestoreInstance = firestore;

  FirebaseFirestore? get _firestore {
    if (_firestoreInstance != null) return _firestoreInstance;
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestoreInstance = FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('Firestore instance note: $e');
    }
    return _firestoreInstance;
  }

  /// Stream of a user's profile data
  Stream<UserModel?> getUserStream(String userId) {
    if (userId.isEmpty) return Stream.value(null);

    try {
      final firestore = _firestore;
      if (firestore != null) {
        return firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .snapshots()
            .map((doc) {
          if (doc.exists) {
            return UserModel.fromFirestore(doc);
          }
          return null;
        }).handleError((error) {
          debugPrint('User stream note: $error');
          return null;
        });
      }
    } catch (e) {
      debugPrint('Error accessing user stream: $e');
    }

    return Stream.value(null);
  }

  /// Fetch user profile once
  Future<UserModel?> getUser(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final doc = await firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile details
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String bio,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'name': name.trim(),
        'bio': bio.trim(),
      };
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update(updateData);
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      throw 'Failed to update profile. Please try again.';
    }
  }
}
