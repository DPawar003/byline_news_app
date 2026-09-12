import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  User? _user;
  AppUser? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthViewModel({
    FirebaseAuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirestoreService() {
    _initAuthListener();
  }

  User? get user => _user;
  AppUser? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((User? firebaseUser) async {
      _user = firebaseUser;
      if (firebaseUser != null) {
        _userProfile = await _firestoreService.getUserProfile(firebaseUser.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.signIn(email: email, password: password);
      _user = credential.user;
      if (_user != null) {
        _userProfile = await _firestoreService.getUserProfile(_user!.uid);
      }
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Authentication failed. Please try again.";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.signUp(email: email, password: password);
      _user = credential.user;
      if (_user != null) {
        await _firestoreService.createUserProfile(
          uid: _user!.uid,
          email: email,
          displayName: displayName,
        );
        _userProfile = await _firestoreService.getUserProfile(_user!.uid);
      }
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Registration failed. Please try again.";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Failed to send password reset email. Please try again.";
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  void clearErrorMessage() {
    _clearError();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _parseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection error. Please check your connection.';
      case 'operation-not-allowed':
        return 'Sign in method is not enabled. Please contact support.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
