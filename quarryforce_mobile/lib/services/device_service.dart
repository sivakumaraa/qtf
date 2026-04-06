// ================================================================
// File: quarryforce_mobile/lib/services/device_service.dart
// Purpose: Device identification and binding service
// Date: March 14, 2026
// ================================================================

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

/// Service for managing device identification and one-time binding
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();

  factory DeviceService() {
    return _instance;
  }

  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  static const String _deviceUIDKey = 'device_uid';
  static const String _deviceBindingKey = 'device_binding_timestamp';

  /// Get or generate device UID (one-time only)
  Future<String> getOrGenerateDeviceUID() async {
    try {
      // Check if already stored in secure storage
      String? storedUID = await _secureStorage.read(key: _deviceUIDKey);

      if (storedUID?.isNotEmpty ?? false) {
        _logger
            .i('Existing device UID found: ${storedUID!.substring(0, 8)}****');
        return storedUID;
      }

      // Generate new UUID v4
      const uuid = Uuid();
      String newUID = uuid.v4();

      // Store securely
      await _secureStorage.write(key: _deviceUIDKey, value: newUID);

      // Store binding timestamp
      await _secureStorage.write(
        key: _deviceBindingKey,
        value: DateTime.now().toIso8601String(),
      );

      _logger.i('New device UID generated: ${newUID.substring(0, 8)}****');
      return newUID;
    } catch (e) {
      _logger.e('Error generating device UID: $e');
      // Fallback: generate UUID but don't store
      const uuid = Uuid();
      return uuid.v4();
    }
  }

  /// Get stored device UID without generating new one
  Future<String?> getStoredDeviceUID() async {
    try {
      return await _secureStorage.read(key: _deviceUIDKey);
    } catch (e) {
      _logger.e('Error retrieving stored UID: $e');
      return null;
    }
  }

  /// Check if device is already bound
  Future<bool> isDeviceBound() async {
    String? uid = await _secureStorage.read(key: _deviceUIDKey);
    return uid?.isNotEmpty ?? false;
  }

  /// Get device binding timestamp
  Future<DateTime?> getDeviceBindingTime() async {
    try {
      String? timestamp = await _secureStorage.read(key: _deviceBindingKey);
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      _logger.e('Error retrieving binding time: $e');
    }
    return null;
  }

  /// Get complete device information
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      String deviceUID = await getOrGenerateDeviceUID();

      if (Platform.isAndroid) {
        return await _getAndroidDeviceInfo(deviceUID);
      } else if (Platform.isIOS) {
        return await _getIOSDeviceInfo(deviceUID);
      }
    } catch (e) {
      _logger.e('Error getting device info: $e');
    }

    return {
      'device_uid': await getOrGenerateDeviceUID(),
      'device_model': 'Unknown',
      'device_manufacturer': 'Unknown',
      'os': 'Unknown',
      'os_version': 'Unknown',
    };
  }

  /// Get Android-specific device information
  Future<Map<String, String>> _getAndroidDeviceInfo(String deviceUID) async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;

      return {
        'device_uid': deviceUID,
        'device_id': androidInfo.id ?? 'Unknown',
        'device_model': androidInfo.model ?? 'Unknown',
        'device_manufacturer': androidInfo.manufacturer ?? 'Unknown',
        'os': 'Android',
        'os_version': androidInfo.version.release ?? 'Unknown',
        'device_brand': androidInfo.brand ?? 'Unknown',
        'device_name': androidInfo.device ?? 'Unknown',
      };
    } catch (e) {
      _logger.e('Error getting Android info: $e');
      return {
        'device_uid': deviceUID,
        'device_model': 'Android Device',
        'device_manufacturer': 'Unknown',
        'os': 'Android',
        'os_version': 'Unknown',
      };
    }
  }

  /// Get iOS-specific device information
  Future<Map<String, String>> _getIOSDeviceInfo(String deviceUID) async {
    try {
      final iosInfo = await _deviceInfo.iosInfo;

      return {
        'device_uid': deviceUID,
        'device_id': iosInfo.identifierForVendor ?? 'Unknown',
        'device_model': iosInfo.model ?? 'Unknown',
        'device_manufacturer': 'Apple',
        'os': 'iOS',
        'os_version': iosInfo.systemVersion ?? 'Unknown',
        'device_name': iosInfo.name ?? 'Unknown',
      };
    } catch (e) {
      _logger.e('Error getting iOS info: $e');
      return {
        'device_uid': deviceUID,
        'device_model': 'iOS Device',
        'device_manufacturer': 'Apple',
        'os': 'iOS',
        'os_version': 'Unknown',
      };
    }
  }

  /// Clear all device-related data (for logout or reset)
  Future<void> clearDeviceData() async {
    try {
      await _secureStorage.delete(key: _deviceUIDKey);
      await _secureStorage.delete(key: _deviceBindingKey);
      _logger.i('Device data cleared');
    } catch (e) {
      _logger.e('Error clearing device data: $e');
    }
  }

  /// Verify device integrity (check if device UID matches)
  Future<bool> verifyDeviceIntegrity(String expectedUID) async {
    try {
      String? storedUID = await _secureStorage.read(key: _deviceUIDKey);
      return storedUID == expectedUID;
    } catch (e) {
      _logger.e('Error verifying device integrity: $e');
      return false;
    }
  }

  /// Get device fingerprint (combination of device identifiers)
  Future<String> getDeviceFingerprint() async {
    try {
      Map<String, String> info = await getDeviceInfo();
      String fingerprint =
          '${info['device_model']}-${info['os']}-${info['device_uid']}';
      return fingerprint;
    } catch (e) {
      _logger.e('Error getting device fingerprint: $e');
      return 'unknown-fingerprint';
    }
  }

  /// Get human-readable device name
  Future<String> getDeviceName() async {
    try {
      Map<String, String> info = await getDeviceInfo();
      return '${info['device_manufacturer']} ${info['device_model']} (${info['os']} ${info['os_version']})';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Log device information to console (for debugging)
  Future<void> debugLogDeviceInfo() async {
    _logger.i('=== Device Information ===');
    try {
      Map<String, String> info = await getDeviceInfo();
      info.forEach((key, value) {
        _logger.d('$key: $value');
      });
      bool bound = await isDeviceBound();
      _logger.d('Device Bound: $bound');
      DateTime? bindTime = await getDeviceBindingTime();
      _logger.d('Bound At: $bindTime');
    } catch (e) {
      _logger.e('Error: $e');
    }
    _logger.i('========================');
  }
}
