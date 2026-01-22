import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data
/// Uses platform-specific secure storage (Keychain on iOS, Keystore on Android)
class SecureStorage {
  final FlutterSecureStorage _storage;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  /// Save authentication tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
    } catch (e) {
      throw StorageException('Failed to save tokens: $e');
    }
  }

  /// Save user data
  Future<void> saveUserData({
    required String id,
    required String email,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _userIdKey, value: id),
        _storage.write(key: _userEmailKey, value: email),
      ]);
    } catch (e) {
      throw StorageException('Failed to save user data: $e');
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw StorageException('Failed to read access token: $e');
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw StorageException('Failed to read refresh token: $e');
    }
  }

  /// Get stored user data
  Future<Map<String, String>?> getUserData() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _userIdKey),
        _storage.read(key: _userEmailKey),
      ]);

      final id = results[0];
      final email = results[1];

      if (id == null || email == null) return null;

      return {'id': id, 'email': email};
    } catch (e) {
      throw StorageException('Failed to read user data: $e');
    }
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored data
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear storage: $e');
    }
  }

  /// Delete specific token
  Future<void> deleteToken(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException('Failed to delete token: $e');
    }
  }
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}