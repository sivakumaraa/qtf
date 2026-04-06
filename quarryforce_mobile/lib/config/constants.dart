import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuration constants for the mobile app
class AppConstants {
  // API Configuration - platform-aware for local development
  // Android emulator uses 10.0.2.2 to reach host machine's localhost
  // Web and Desktop use localhost directly
  static String get defaultApiUrl {
    // Check for build-time defined API_URL, fallback to local dev
    const String buidTimeApiUrl = String.fromEnvironment('API_URL');
    if (buidTimeApiUrl.isNotEmpty) return buidTimeApiUrl;
    
    // For local development on Android emulator:
    return 'http://10.0.2.2:8000/api';
  }

  // Runtime values (can be updated from server)
  static String apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000/api');
  static int apiTimeout = 60000; // 60 seconds
  static int gpsUpdateInterval = 5000; // 5 seconds
  static int gpsMinDistance = 10; // 10 meters
  static double minVisitDuration = 15; // 15 seconds for testing
  static String companyCurrency = '₹';

  // API Endpoints (use apiBaseUrl prefix)
  static const String loginEndpoint = '/login';
  static const String checkinEndpoint = '/checkin';
  static const String visitSubmitEndpoint = '/visit/submit';
  static const String fuelSubmitEndpoint = '/fuel/submit';
  static const String settingsEndpoint = '/settings';

  // Rep endpoints (for mobile app)
  static String repCustomersEndpoint(int repId) => '/rep/customers/$repId';

  // Admin endpoints (for fetching reference data)
  static const String adminRepsEndpoint = '/admin/reps';
  static const String adminCustomersEndpoint = '/admin/customers';
  static const String adminOrdersEndpoint = '/admin/orders';
  static const String adminResetDeviceEndpoint = '/admin/reset-device';
  static const String adminRepTargetsEndpoint = '/admin/rep-targets';
  static const String adminRepProgressEndpoint = '/admin/rep-progress';
  static const String adminRepSalesUpdateEndpoint =
      '/admin/rep-progress/update';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String deviceUidKey = 'device_uid';
  static const String isLoggedInKey = 'is_logged_in';

  // App Configuration
  static const String appVersion = '1.0.0';
  static const String appName = 'QuarryForce Tracker';
}

/// HTTP Status codes
class HttpStatusCode {
  static const int ok = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;
}

/// Error messages
class ErrorMessages {
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorized = 'Unauthorized. Please login again.';
  static const String invalidCredentials = 'Invalid username or password.';
  static const String deviceAlreadyBound =
      'This device is already bound to another account.';
  static const String gpsNotAvailable =
      'GPS is not available. Please enable location services.';
  static const String cameraNotAvailable = 'Camera is not available.';
  static const String permissionDenied =
      'Permission denied. Please enable the required permissions.';
  static const String offlineMode =
      'Operating in offline mode. Data will sync when online.';
}

/// Success messages
class SuccessMessages {
  static const String loginSuccess = 'Login successful!';
  static const String visitSubmitted = 'Visit submitted successfully.';
  static const String fuelSubmitted = 'Fuel log submitted successfully.';
  static const String dataSynced = 'All data synced successfully.';
}
