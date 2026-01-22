import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';
import '../../constants/api_constants.dart';

/// HTTP client with automatic token management and error handling
class ApiClient {
  final SecureStorage _storage;
  final http.Client _client;
  final String baseUrl;

  ApiClient({
    required SecureStorage storage,
    http.Client? client,
    String? baseUrl,
  })  : _storage = storage,
        _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl;

  /// GET request
  Future<ApiResponse> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    return _request(
      'GET',
      path,
      headers: headers,
      queryParams: queryParams,
    );
  }

  /// POST request
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _request(
      'POST',
      path,
      body: body,
      headers: headers,
    );
  }

  /// PUT request
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _request(
      'PUT',
      path,
      body: body,
      headers: headers,
    );
  }

  /// DELETE request
  Future<ApiResponse> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _request(
      'DELETE',
      path,
      headers: headers,
    );
  }

  /// Core request method with error handling and token refresh
  Future<ApiResponse> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool isRetry = false,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final requestHeaders = await _buildHeaders(headers);

      http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: requestHeaders)
              .timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: requestHeaders)
              .timeout(const Duration(seconds: 30));
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      // Handle 401 and token refresh
      if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          return _request(
            method,
            path,
            body: body,
            headers: headers,
            queryParams: queryParams,
            isRetry: true,
          );
        }
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'No internet connection',
        type: ApiExceptionType.network,
      );
    } on TimeoutException {
      throw ApiException(
        'Request timeout',
        type: ApiExceptionType.timeout,
      );
    } on FormatException {
      throw ApiException(
        'Invalid response format',
        type: ApiExceptionType.parse,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String path, Map<String, dynamic>? queryParams) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }
    return uri;
  }

  /// Build headers with authentication
  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? additionalHeaders,
  ) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    final dynamic data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        statusCode: response.statusCode,
        data: data,
        success: true,
      );
    }

    // Extract error message
    String message = 'Request failed';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
      type: _getExceptionType(response.statusCode),
    );
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.refreshTokenEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }

      // Refresh failed, clear storage
      await _storage.clear();
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get exception type from status code
  ApiExceptionType _getExceptionType(int statusCode) {
    switch (statusCode) {
      case 400:
        return ApiExceptionType.badRequest;
      case 401:
        return ApiExceptionType.unauthorized;
      case 403:
        return ApiExceptionType.forbidden;
      case 404:
        return ApiExceptionType.notFound;
      case 500:
        return ApiExceptionType.server;
      default:
        return ApiExceptionType.unknown;
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}

/// API Response model
class ApiResponse {
  final int statusCode;
  final dynamic data;
  final bool success;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.success,
  });
}

/// API Exception types
enum ApiExceptionType {
  network,
  timeout,
  parse,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  server,
  unknown,
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;

  ApiException(
    this.message, {
    this.statusCode,
    this.type = ApiExceptionType.unknown,
  });

  @override
  String toString() => 'ApiException: $message';

  /// User-friendly error message
  String get userMessage {
    switch (type) {
      case ApiExceptionType.network:
        return 'No internet connection. Please check your network.';
      case ApiExceptionType.timeout:
        return 'Request timed out. Please try again.';
      case ApiExceptionType.unauthorized:
        return 'Session expired. Please login again.';
      case ApiExceptionType.server:
        return 'Server error. Please try again later.';
      default:
        return message;
    }
  }
}