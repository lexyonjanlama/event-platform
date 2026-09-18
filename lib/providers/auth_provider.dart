import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  AppUser? _appUser;

  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;

  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authService.authStateChanges.listen(
      (user) async {
        _firebaseUser = user;

        if (user != null) {
          _isLoading = true;
          notifyListeners();

          _appUser = await _authService.getUser(user.uid);
        } else {
          _appUser = null;
        }

        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final appUser = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      if (appUser == null) {
        _errorMessage = 'Unable to create your account.';
        return false;
      }

      // Make sure the provider immediately has the newly
      // created profile instead of waiting for authStateChanges.
      _firebaseUser = FirebaseAuth.instance.currentUser;
      _appUser = appUser;

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      debugPrint('SIGN UP ERROR: $e');
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final appUser = await _authService.signIn(
        email: email,
        password: password,
      );

      if (appUser == null) {
        _errorMessage = 'Your user profile could not be found.';
        return false;
      }

      _firebaseUser = FirebaseAuth.instance.currentUser;
      _appUser = appUser;

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      return false;
    } catch (e) {
      debugPrint('SIGN IN ERROR: $e');
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();

    _firebaseUser = null;
    _appUser = null;

    notifyListeners();
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}