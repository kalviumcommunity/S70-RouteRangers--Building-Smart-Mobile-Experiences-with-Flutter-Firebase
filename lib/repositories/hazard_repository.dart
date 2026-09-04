import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_data_seeder.dart';
import '../models/hazard_model.dart';

class HazardRepository {
  FirebaseFirestore? _firestoreInstance;
  FirebaseStorage? _storageInstance;

  HazardRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestoreInstance = firestore,
        _storageInstance = storage;

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

  FirebaseStorage? get _storage {
    if (_storageInstance != null) return _storageInstance;
    try {
      if (Firebase.apps.isNotEmpty) {
        _storageInstance = FirebaseStorage.instance;
      }
    } catch (e) {
      debugPrint('FirebaseStorage instance note: $e');
    }
    return _storageInstance;
  }

  /// Stream of all active hazards in real-time
  Stream<List<HazardModel>> getHazardsStream() {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        return firestore
            .collection(AppConstants.hazardsCollection)
            .where('status', isEqualTo: 'active')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return MockDataSeeder.initialHazards;
          }
          return snapshot.docs.map((doc) => HazardModel.fromFirestore(doc)).toList();
        }).handleError((error) {
          debugPrint('Hazard stream note: $error');
          return MockDataSeeder.initialHazards;
        });
      }
    } catch (e) {
      debugPrint('Error accessing hazard stream: $e');
    }
    return Stream.value(MockDataSeeder.initialHazards);
  }

  /// Get hazards reported by a specific user
  Stream<List<HazardModel>> getUserHazardsStream(String userId) {
    try {
      final firestore = _firestore;
      if (firestore != null && userId.isNotEmpty) {
        return firestore
            .collection(AppConstants.hazardsCollection)
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => HazardModel.fromFirestore(doc)).toList())
            .handleError((error) {
          debugPrint('User hazards note: $error');
          return <HazardModel>[];
        });
      }
    } catch (e) {
      debugPrint('Error accessing user hazards stream: $e');
    }
    return Stream.value(<HazardModel>[]);
  }

  /// Submit a new community hazard report
  Future<void> reportHazard({
    required String userId,
    required String userName,
    required String type,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      final hazardId = const Uuid().v4();
      String? imageUrl;

      final storage = _storage;
      if (imageFile != null && storage != null) {
        try {
          final ref = storage
              .ref()
              .child('hazards')
              .child(hazardId)
              .child('photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
          final uploadTask = await ref.putFile(imageFile);
          imageUrl = await uploadTask.ref.getDownloadURL();
        } catch (storageError) {
          debugPrint('Storage upload note (proceeding without image): $storageError');
        }
      }

      final hazard = HazardModel(
        id: hazardId,
        userId: userId,
        userName: userName,
        type: type,
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        status: 'active',
      );

      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection(AppConstants.hazardsCollection)
            .doc(hazardId)
            .set(hazard.toMap());

        if (userId.isNotEmpty) {
          await firestore
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .update({
            'hazardsReported': FieldValue.increment(1),
            'reputationScore': FieldValue.increment(15),
          }).catchError((_) {});
        }
      }
    } catch (e) {
      debugPrint('Error reporting hazard: $e');
      throw 'Failed to submit hazard report. Please try again.';
    }
  }

  /// Upvote or verify a hazard
  Future<void> upvoteHazard(String hazardId) async {
    try {
      await _firestore
          ?.collection(AppConstants.hazardsCollection)
          .doc(hazardId)
          .update({'upvotes': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Upvote note: $e');
    }
  }

  /// Mark hazard as resolved
  Future<void> resolveHazard(String hazardId) async {
    try {
      await _firestore
          ?.collection(AppConstants.hazardsCollection)
          .doc(hazardId)
          .update({'status': 'resolved'});
    } catch (e) {
      debugPrint('Error resolving hazard: $e');
      throw 'Unable to resolve hazard.';
    }
  }
}
