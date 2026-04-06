import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../utils/logger.dart';
import 'dart:io';

/// Authentication Provider for managing user login state
class AuthProvider extends ChangeNotifier {
  final ApiService apiService;

  User? _currentUser;
  String? _deviceUid;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  late Future<void> _initFuture;

  AuthProvider({required this.apiService}) {
    _initFuture = _initializeAuth();
  }

  // Getters
  User? get currentUser => _currentUser;
  String? get deviceUid => _deviceUid;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  /// Wait for initialization to complete
  Future<void> waitForInitialization() => _initFuture;

  /// Initialize authentication - check if user is already logged in
  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user was previously logged in
      final userId = prefs.getInt('user_id');
      final token = prefs.getString('user_token');

      AppLogger.divider('AUTH INIT');
      AppLogger.debug('userId from prefs: $userId');
      AppLogger.debug('token from prefs: $token');

      if (userId != null && token != null) {
        AppLogger.info('Found saved login, restoring user');
        // Safely extract user data with defaults
        final username = prefs.getString('username') ?? 'User';
        final email = prefs.getString('email') ?? 'user@example.com';

        _currentUser = User(
          id: userId,
          username: username,
          email: email,
          name: prefs.getString('user_name'),
          phone: prefs.getString('phone'),
          photo: prefs.getString('user_photo'),
        );

        _isLoggedIn = true;
        _deviceUid = prefs.getString('device_uid');
        AppLogger.debug('User restored: $_currentUser');
      } else {
        // No saved login - user must login
        AppLogger.info('No saved login found, user must authenticate');
        _isLoggedIn = false;
        _currentUser = null;
      }

      // Load or generate device UID
      _deviceUid ??= prefs.getString('device_uid');
      if (_deviceUid == null) {
        _deviceUid = const Uuid().v4();
        await prefs.setString('device_uid', _deviceUid!);
        AppLogger.debug('Generated new device UID: $_deviceUid');
      } else {
        AppLogger.debug('Using existing device UID: $_deviceUid');
      }

      AppLogger.debug('Final isLoggedIn: $_isLoggedIn');

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Initialization error is non-critical, proceed with defaults
      AppLogger.error('ERROR in _initializeAuth', e);
      _isLoggedIn = false;
      _currentUser = null;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Login with email and device binding
  Future<bool> login({
    required String email,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Ensure device UID exists
      if (_deviceUid == null) {
        _deviceUid = const Uuid().v4();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_uid', _deviceUid!);
      }

      // Call login API
      final result = await apiService.login(
        email: email,
        deviceUid: _deviceUid!,
      );

      if (result['success'] == true) {
        // Extract user data from response
        final userData = result['user'] ?? result['data'];

        // Safely handle null values from API response
        if (userData == null || userData is! Map<String, dynamic>) {
          _error = 'Invalid response from server';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _currentUser = User(
          id: userData['id'] as int?,
          username: userData['username'] as String? ?? 'User',
          email: userData['email'] as String? ?? email,
          name: userData['name'] as String?,
          phone: userData['phone'] as String?,
          photo: userData['photo'] as String?,
          targetStatus: userData['target_status'] as String?,
          targetId: userData['target_id'] as int?,
        );

        _isLoggedIn = true;

        // Save login data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', _currentUser!.id ?? 0);
        await prefs.setString('username', _currentUser!.username);
        await prefs.setString('email', _currentUser!.email);
        if (_currentUser!.name != null) {
          await prefs.setString('user_name', _currentUser!.name!);
        }
        if (_currentUser!.phone != null) {
          await prefs.setString('phone', _currentUser!.phone!);
        }
        if (_currentUser!.photo != null) {
          await prefs.setString('user_photo', _currentUser!.photo!);
        }
        if (result['token'] != null) {
          await prefs.setString('user_token', result['token']);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout and clear user data
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('username');
      await prefs.remove('email');
      await prefs.remove('user_name');
      await prefs.remove('phone');
      await prefs.remove('user_photo');
      await prefs.remove('user_token');

      _currentUser = null;
      _isLoggedIn = false;
      _error = null;

      // Clear auth token from API service
      apiService.clearAuthToken();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Logout error is non-critical, user state already cleared
    }
  }

  /// Check in device with backend
  Future<bool> checkIn() async {
    try {
      if (_currentUser?.id == null || _deviceUid == null) {
        _error = 'Missing user ID or device UID';
        return false;
      }

      final result = await apiService.checkIn(
        repId: _currentUser!.id!,
        deviceUid: _deviceUid!,
      );

      if (result['success'] == true) {
        return true;
      } else {
        _error = result['message'] ?? 'Check-in failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Update user profile with name, phone, and optional photo
  Future<bool> updateProfile({
    required String name,
    required String phone,
    File? photoFile,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_currentUser?.id == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Call API service to update profile
      final result = await apiService.updateProfile(
        repId: _currentUser!.id!,
        name: name,
        phone: phone,
        photoFile: photoFile,
      );

      if (result['success'] == true) {
        // Update local user object with API response data
        final userData = result['data'] as Map<String, dynamic>?;
        AppLogger.info('API response result keys: ${result.keys.toList()}');
        AppLogger.info('API response data: $userData');
        AppLogger.debug('Response data type: ${userData.runtimeType}');
        AppLogger.debug('Full result: $result');

        if (userData != null) {
          AppLogger.debug(
              'Available keys in response: ${userData.keys.toList()}');
          AppLogger.debug('Photo value: ${userData['photo']}');
          AppLogger.debug('Photo type: ${userData['photo'].runtimeType}');
        }

        _currentUser = _currentUser!;
        _currentUser!.name = name;
        _currentUser!.phone = phone;

        // Update photo if provided by API (handle both photo and photoPath keys)
        String? photoPath = userData?['photo'] ?? userData?['photoPath'];
        if (photoPath != null && photoPath.isNotEmpty) {
          _currentUser!.photo = photoPath;
          AppLogger.info('Photo updated to: $photoPath');
        } else if (photoFile != null) {
          // If photo file was sent but API didn't return path, log warning
          AppLogger.warning(
              'Photo file was sent but no path in response. Available keys: ${userData?.keys.toList()}');
        } else {
          AppLogger.debug(
              'No photo update - either no file or API returned empty');
        }

        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name);
        await prefs.setString('phone', phone);
        if (_currentUser!.photo != null && _currentUser!.photo!.isNotEmpty) {
          await prefs.setString('user_photo', _currentUser!.photo!);
          AppLogger.info(
              'Photo saved to SharedPreferences: ${_currentUser!.photo}');

          // Verify it was saved
          final savedPhoto = prefs.getString('user_photo');
          AppLogger.debug('Verified saved photo: $savedPhoto');
        } else {
          AppLogger.info('No photo to save or photo is empty');
        }

        AppLogger.info('Profile updated successfully');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
      _error = 'Error updating profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
