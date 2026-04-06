// ================================================================
// File: quarryforce_mobile/lib/services/auth_service.dart
// Purpose: Authentication service with JWT token management
// Date: March 14, 2026
// ================================================================

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'device_service.dart';

/// Authentication service for login, token management, and session handling
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceService _deviceService = DeviceService();
  final Logger _logger = Logger();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _mobileNoKey = 'mobile_no';

  String? _token;
  String? _currentUserID;
  String? _currentUserEmail;
  String? _currentUserName;
  String? _currentUserRole;

  // Getters
  String? get token => _token;
  String? get currentUserID => _currentUserID;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  String? get currentUserRole => _currentUserRole;

  bool get isAuthenticated => _token != null && _currentUserID != null;

  /// Initialize authentication service with API base URL
  void initialize(String apiBaseURL) {
    _dio.options.baseUrl = apiBaseURL;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  /// Login with email and password
  /// Returns: true if successful, false otherwise
  Future<bool> login(String email, String password) async {
    try {
      String deviceUID = await _deviceService.getOrGenerateDeviceUID();
      Map<String, String> deviceInfo = await _deviceService.getDeviceInfo();

      _logger.i('Attempting login for: $email');

      final response = await _dio.post(
        '/login?action=login',
        data: FormData.fromMap({
          'email': email,
          'password': password,
          'device_uid': deviceUID,
          'device_model': deviceInfo['device_model'] ?? 'Unknown',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map && responseData['success'] == true) {
          final userData = responseData['data'];
          _token = userData['token'];
          _currentUserID = userData['user']?['id']?.toString();
          _currentUserEmail = userData['user']?['email']?.toString();
          _currentUserName = userData['user']?['name']?.toString();
          _currentUserRole = userData['user']?['role']?.toString();

          // Store sensitive data securely
          await _secureStorage.write(key: _tokenKey, value: _token!);
          await _secureStorage.write(key: _userIdKey, value: _currentUserID!);
          await _secureStorage.write(
              key: _userEmailKey, value: _currentUserEmail!);
          await _secureStorage.write(
              key: _userNameKey, value: _currentUserName!);
          await _secureStorage.write(
              key: _userRoleKey, value: _currentUserRole!);
          await _secureStorage.write(
            key: _mobileNoKey,
            value: userData['user']?['mobile_no']?.toString() ?? '',
          );

          // Set default auth header
          _dio.options.headers['Authorization'] = 'Bearer $_token';

          _logger.i('Login successful for: $_currentUserEmail');
          return true;
        } else {
          final errorMessage = responseData?['message'] ?? 'Login failed';
          _logger.e('Login failed: $errorMessage');
        }
      } else {
        _logger.e('Login failed: HTTP ${response.statusCode}');
      }
      return false;
    } on DioException catch (e) {
      _logger.e('Login error: ${e.message}');
      if (e.response != null) {
        _logger.e('Response: ${e.response!.data}');
      }
      return false;
    } catch (e) {
      _logger.e('Unexpected error during login: $e');
      return false;
    }
  }

  /// Restore authentication session from secure storage
  /// Called on app startup to check if user is already logged in
  Future<bool> restoreSession() async {
    try {
      _logger.i('Attempting to restore session...');

      _token = await _secureStorage.read(key: _tokenKey);
      _currentUserID = await _secureStorage.read(key: _userIdKey);
      _currentUserEmail = await _secureStorage.read(key: _userEmailKey);
      _currentUserName = await _secureStorage.read(key: _userNameKey);
      _currentUserRole = await _secureStorage.read(key: _userRoleKey);

      if (_token != null && _currentUserID != null) {
        // Set default auth header
        _dio.options.headers['Authorization'] = 'Bearer $_token';

        _logger.i('Session restored for: $_currentUserEmail');
        return true;
      }

      _logger.i('No previous session found');
      return false;
    } catch (e) {
      _logger.e('Error restoring session: $e');
      return false;
    }
  }

  /// Verify if token is still valid by calling a simple API endpoint
  /// Returns: true if token is valid
  Future<bool> verifyToken() async {
    try {
      if (_token == null) {
        return false;
      }

      // This would call an API endpoint to verify token
      // For now, we'll assume token is valid if it exists
      _logger.i('Token verification pending API call');
      return true;
    } catch (e) {
      _logger.e('Token verification error: $e');
      return false;
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      _token = null;
      _currentUserID = null;
      _currentUserEmail = null;
      _currentUserName = null;
      _currentUserRole = null;

      // Clear secure storage
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);
      await _secureStorage.delete(key: _userNameKey);
      await _secureStorage.delete(key: _userRoleKey);
      await _secureStorage.delete(key: _mobileNoKey);

      // Clear auth header
      _dio.options.headers.remove('Authorization');

      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Error during logout: $e');
    }
  }

  /// Get Dio instance for making API calls
  Dio get dio => _dio;

  /// Get current authentication header
  String? getAuthHeader() {
    return _token != null ? 'Bearer $_token' : null;
  }

  /// Debug: Log current auth state
  Future<void> debugLogAuthState() async {
    _logger.i('=== Auth State ===');
    _logger.d('Authenticated: $isAuthenticated');
    _logger.d('User ID: $_currentUserID');
    _logger.d('Email: $_currentUserEmail');
    _logger.d('Name: $_currentUserName');
    _logger.d('Role: $_currentUserRole');
    _logger.d(
        'Token: ${_token != null ? '${_token!.substring(0, 20)}...' : 'null'}');
    _logger.i('==================');
  }
}

/// Global auth service instance
final authService = AuthService();
