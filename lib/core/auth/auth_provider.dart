import 'package:flutter/material.dart';
import 'auth_user.dart';
import 'auth_service.dart';

/// Authentication state
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthState _state = AuthState.initial;
  AuthUser? _user;
  String? _error;

  AuthProvider({required AuthService authService})
      : _authService = authService {
    _initialize();
  }

  // Getters
  AuthState get state => _state;
  AuthUser? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;
  bool get isInitial => _state == AuthState.initial;

  /// Initialize and attempt auto-login
  Future<void> _initialize() async {
    try {
      _setState(AuthState.loading);
      _user = await _authService.tryAutoLogin();
      
      if (_user != null) {
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Initialization failed: ${e.toString()}');
      _setState(AuthState.unauthenticated);
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      _user = await _authService.login(
        email: email,
        password: password,
      );

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      _user = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      _setState(AuthState.loading);
      await _authService.logout();
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      // Still set to unauthenticated even if API call fails
      _user = null;
      _setState(AuthState.unauthenticated);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      _user = await _authService.updateProfile(
        name: name,
        email: email,
      );

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.authenticated); // Stay authenticated
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _clearError();

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      _clearError();

      await _authService.requestPasswordReset(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (_state != AuthState.authenticated) return;

    try {
      final user = await _authService.tryAutoLogin();
      if (user != null) {
        _user = user;
        notifyListeners();
      } else {
        // Token expired, logout
        await logout();
      }
    } catch (e) {
      _setError('Failed to refresh user: ${e.toString()}');
    }
  }

  /// Clear error
  void clearError() {
    _clearError();
  }

  // Private helpers
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}