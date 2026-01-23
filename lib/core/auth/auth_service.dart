import 'package:productivity/core/auth/network/api_client.dart';
import 'package:productivity/core/auth/storage/secure_storage.dart';
import 'package:productivity/core/constants/api_constants.dart';
import 'auth_user.dart';

/// Authentication service handling login, logout, and token management
class AuthService {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  AuthService({
    required ApiClient apiClient,
    required SecureStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  /// Login user with email and password
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      _validateEmail(email);
      _validatePassword(password);

      final response = await _apiClient.post(
        ApiConstants.loginEndpoint,
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (!response.success) {
        throw AuthException('Login failed');
      }

      final data = response.data;

      // Validate response structure
      if (data == null || data is! Map<String, dynamic>) {
        throw AuthException('Invalid response format');
      }

      if (!data.containsKey('accessToken') || !data.containsKey('refreshToken')) {
        throw AuthException('Missing authentication tokens');
      }

      if (!data.containsKey('user')) {
        throw AuthException('Missing user data');
      }

      // Save tokens
      await _storage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      // Parse and save user
      final user = AuthUser.fromJson(data['user']);
      await _storage.saveUserData(
        id: user.id,
        email: user.email,
      );

      return user;
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  /// Register new user
  Future<AuthUser> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _validateEmail(email);
      _validatePassword(password);
      _validateName(name);

      final response = await _apiClient.post(
        ApiConstants.registerEndpoint,
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'name': name.trim(),
        },
      );

      if (!response.success) {
        throw AuthException('Registration failed');
      }

      final data = response.data;

      await _storage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      final user = AuthUser.fromJson(data['user']);
      await _storage.saveUserData(
        id: user.id,
        email: user.email,
      );

      return user;
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  /// Try to auto-login using stored tokens
  Future<AuthUser?> tryAutoLogin() async {
    try {
      // Check if tokens exist
      final hasTokens = await _storage.hasTokens();
      if (!hasTokens) return null;

      // Try to get user data from storage first
      final userData = await _storage.getUserData();
      if (userData != null) {
        // Verify token is still valid by fetching current user
        try {
          final response = await _apiClient.get(ApiConstants.currentUserEndpoint);
          if (response.success) {
            return AuthUser.fromJson(response.data);
          }
        } catch (e) {
          // Token invalid, clear storage
          await _storage.clear();
          return null;
        }
      }

      // Fetch user data from API
      final response = await _apiClient.get(ApiConstants.currentUserEndpoint);

      if (!response.success) {
        await _storage.clear();
        return null;
      }

      final user = AuthUser.fromJson(response.data);
      await _storage.saveUserData(
        id: user.id,
        email: user.email,
      );

      return user;
    } catch (e) {
      // Any error during auto-login should clear storage
      await _storage.clear();
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Try to call logout endpoint (don't wait for it)
      _apiClient.post(ApiConstants.logoutEndpoint).catchError((_) {
        
      });
    } finally {
      // Always clear local storage
      await _storage.clear();
    }
  }

  /// Update user profile
  Future<AuthUser> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) {
        _validateName(name);
        body['name'] = name.trim();
      }
      if (email != null) {
        _validateEmail(email);
        body['email'] = email.trim().toLowerCase();
      }

      final response = await _apiClient.put(
        ApiConstants.updateProfileEndpoint,
        body: body,
      );

      final user = AuthUser.fromJson(response.data);
      await _storage.saveUserData(
        id: user.id,
        email: user.email,
      );

      return user;
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Update failed: ${e.toString()}');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _validatePassword(currentPassword);
      _validatePassword(newPassword);

      if (currentPassword == newPassword) {
        throw AuthException('New password must be different');
      }

      await _apiClient.post(
        ApiConstants.changePasswordEndpoint,
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Password change failed: ${e.toString()}');
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      _validateEmail(email);

      await _apiClient.post(
        ApiConstants.forgotPasswordEndpoint,
        body: {'email': email.trim().toLowerCase()},
      );
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Password reset request failed');
    }
  }

  /// Validation helpers
  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw AuthException('Email is required');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw AuthException('Invalid email format');
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw AuthException('Password is required');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }
  }

  void _validateName(String name) {
    if (name.isEmpty) {
      throw AuthException('Name is required');
    }
    if (name.length < 2) {
      throw AuthException('Name must be at least 2 characters');
    }
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}

/// Custom authentication exception
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}