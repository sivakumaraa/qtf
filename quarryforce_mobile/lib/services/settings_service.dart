import 'package:dio/dio.dart';
import 'package:quarryforce_mobile/config/constants.dart';
import 'package:quarryforce_mobile/utils/logger.dart';

/// Manages app settings synchronized from the backend
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  late Dio _dio;
  bool _initialized = false;

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  /// Initialize settings from backend on app startup
  Future<void> loadSettings() async {
    if (_initialized) return;

    try {
      AppLogger.info('Loading settings from ${AppConstants.defaultApiUrl}');

      final response = await _dio.get(
        '${AppConstants.defaultApiUrl}${AppConstants.settingsEndpoint}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final settings = data['data'] as Map<String, dynamic>;
          _applySettings(settings);
          _initialized = true;
          AppLogger.info('Settings loaded successfully');
        }
      }
    } catch (e) {
      // Use defaults on error - this is not critical
      AppLogger.warning('Failed to load settings, using defaults: $e');
      _initialized = true;
    }
  }

  /// Apply settings to AppConstants
  void _applySettings(Map<String, dynamic> settings) {
    try {
      // Apply API endpoint if provided
      if (settings['api_endpoint'] != null) {
        AppConstants.apiBaseUrl = settings['api_endpoint'] as String;
        AppLogger.debug('API endpoint updated to: ${AppConstants.apiBaseUrl}');
      }

      // Apply GPS settings
      if (settings['gps_update_interval'] != null) {
        AppConstants.gpsUpdateInterval =
            int.parse(settings['gps_update_interval'].toString());
        AppLogger.debug(
            'GPS update interval set to: ${AppConstants.gpsUpdateInterval}ms');
      }

      if (settings['gps_min_distance'] != null) {
        AppConstants.gpsMinDistance =
            int.parse(settings['gps_min_distance'].toString());
        AppLogger.debug(
            'GPS min distance set to: ${AppConstants.gpsMinDistance}m');
      }

      // Apply API timeout
      if (settings['api_timeout'] != null) {
        AppConstants.apiTimeout = int.parse(settings['api_timeout'].toString());
        AppLogger.debug('API timeout set to: ${AppConstants.apiTimeout}ms');
      }

      // Apply company currency
      if (settings['currency_symbol'] != null) {
        AppConstants.companyCurrency = settings['currency_symbol'] as String;
        AppLogger.debug(
            'Currency symbol set to: ${AppConstants.companyCurrency}');
      }

      // Apply min visit duration (in seconds)
      if (settings['min_visit_duration'] != null) {
        AppConstants.minVisitDuration =
            double.parse(settings['min_visit_duration'].toString());
        AppLogger.debug(
            'Min visit duration set to: ${AppConstants.minVisitDuration}s');
      }
    } catch (e) {
      AppLogger.warning('Error applying settings: $e');
    }
  }

  /// Update a setting on the backend (admin only)
  Future<bool> updateSetting(String key, dynamic value) async {
    try {
      AppLogger.info('Updating setting: $key = $value');

      final response = await _dio.put(
        '${AppConstants.defaultApiUrl}${AppConstants.settingsEndpoint}',
        data: {key: value},
      );

      if (response.statusCode == 200) {
        AppLogger.info('Setting updated successfully');
        return true;
      }
    } catch (e) {
      AppLogger.error('Failed to update setting: $e');
    }
    return false;
  }

  /// Get all current settings
  Map<String, dynamic> getSettings() {
    return {
      'api_endpoint': AppConstants.apiBaseUrl,
      'api_timeout': AppConstants.apiTimeout,
      'gps_update_interval': AppConstants.gpsUpdateInterval,
      'gps_min_distance': AppConstants.gpsMinDistance,
      'min_visit_duration': AppConstants.minVisitDuration,
      'currency_symbol': AppConstants.companyCurrency,
    };
  }
}
