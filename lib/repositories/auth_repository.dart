import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  FirebaseAuth? _authInstance;
  FirebaseFirestore? _firestoreInstance;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _authInstance = auth,
        _firestoreInstance = firestore;

  FirebaseAuth? get _auth {
    if (_authInstance != null) return _authInstance;
    try {
      if (Firebase.apps.isNotEmpty) {
        _authInstance = FirebaseAuth.instance;
      }
    } catch (e) {
      debugPrint('FirebaseAuth instance note: $e');
    }
    return _authInstance;
  }

  FirebaseFirestore? get _firestore {
    if (_firestoreInstance != null) return _firestoreInstance;
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestoreInstance = FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('FirebaseFirestore instance note: $e');
    }
    return _firestoreInstance;
  }

  Stream<User?> get authStateChanges {
    try {
      final auth = _auth;
      if (auth != null) {
        return auth.authStateChanges().handleError((e) {
          debugPrint('Auth state stream note: $e');
          return null;
        });
      }
    } catch (e) {
      debugPrint('Error getting auth state stream: $e');
    }
    return Stream.value(null);
  }

  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Sign In with Email & Password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final auth = _auth;
      if (auth != null) {
        return await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      }
      // Demo / offline fallback success if Firebase is in demo mode
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Unable to sign in. Please verify your credentials.';
    }
  }

  /// Sign Up with Email, Password and Name
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final auth = _auth;
      if (auth != null) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final user = credential.user;
        if (user != null) {
          await user.updateDisplayName(name).catchError((_) {});

          final userModel = UserModel(
            id: user.uid,
            email: email.trim(),
            name: name.trim(),
            createdAt: DateTime.now(),
          );

          final firestore = _firestore;
          if (firestore != null) {
            await firestore
                .collection(AppConstants.usersCollection)
                .doc(user.uid)
                .set(userModel.toMap())
                .catchError((_) {});
          }
        }

        return credential;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Registration failed. Please try again.';
    }
  }

  /// Send password reset link
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final auth = _auth;
      if (auth != null) {
        await auth.sendPasswordResetEmail(email: email.trim());
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Could not send reset email. Please try again.';
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (e) {
      debugPrint('Sign out notice: $e');
    }
  }

  /// Helper to convert Firebase Auth codes into user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please register.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please verify your credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection error. Check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
