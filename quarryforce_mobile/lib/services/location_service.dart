import 'package:location/location.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:async';
import 'dart:math' as math;
import '../config/constants.dart';
import '../utils/logger.dart';

/// Model for GPS location data
class GPSLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final DateTime timestamp;

  GPSLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GPSLocation.fromLocationData(LocationData data) {
    return GPSLocation(
      latitude: data.latitude ?? 0.0,
      longitude: data.longitude ?? 0.0,
      accuracy: data.accuracy,
      altitude: data.altitude,
      speed: data.speed,
    );
  }

  /// Calculate distance to another location (in meters)
  double distanceTo(GPSLocation other) {
    const earthRadiusM = 6371000;
    final dLat = _toRad(other.latitude - latitude);
    final dLon = _toRad(other.longitude - longitude);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRad(latitude)) *
            math.cos(_toRad(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  double _toRad(double degrees) => degrees * (3.141592653589793 / 180.0);
}

/// Service for handling GPS location tracking
class LocationService {
  static final LocationService _instance = LocationService._internal();
  Location? _location;
  StreamSubscription<LocationData>? _locationSubscription;
  final List<GPSLocation> _locationHistory = [];
  bool _isTracking = false;
  bool _hasPermission = kIsWeb; // Web doesn't need permission setup

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  static LocationService get instance => _instance;

  /// Get or create Location instance (lazy initialization, only on non-web)
  Location _getLocation() {
    if (kIsWeb) {
      throw UnsupportedError(
          'Location service is not available on web platform');
    }
    _location ??= Location();
    return _location!;
  }

  // Getters
  bool get isTracking => _isTracking;
  List<GPSLocation> get locationHistory => _locationHistory;
  bool get hasPermission => _hasPermission;

  /// Initialize location service and request permissions
  Future<bool> initialize() async {
    // Skip initialization on web platform
    if (kIsWeb) {
      return true;
    }

    // Skip location on desktop platforms (Windows, macOS, Linux)
    // Location package only works on mobile (Android, iOS)
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false; // Desktop platforms don't support location tracking
    }

    try {
      final location = _getLocation();
      // Check if location service is enabled
      final serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        final result = await location.requestService();
        if (!result) {
          return false;
        }
      }

      // Request location permission
      final permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        final result = await location.requestPermission();
        if (result != PermissionStatus.granted) {
          return false;
        }
      }

      _hasPermission = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current location
  Future<GPSLocation?> getCurrentLocation() async {
    // Return mock location on web platform
    if (kIsWeb) {
      return GPSLocation(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 0.0,
      );
    }

    try {
      if (!_hasPermission) {
        final initialized = await initialize();
        if (!initialized) return null;
      }

      final location = _getLocation();
      final locationData = await location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        return null;
      }

      final gpsLocation = GPSLocation.fromLocationData(locationData);
      _locationHistory.add(gpsLocation);
      return gpsLocation;
    } catch (e) {
      return null;
    }
  }

  /// Start continuous location tracking
  ///
  /// Uses configurable update interval and min distance from AppConstants
  /// [onLocationChanged] - Callback when location changes
  void startTracking({
    required Function(GPSLocation location) onLocationChanged,
  }) async {
    // Skip tracking on web platform
    if (kIsWeb) {
      return;
    }

    if (_isTracking) {
      return;
    }

    try {
      if (!_hasPermission) {
        final initialized = await initialize();
        if (!initialized) {
          return;
        }
      }

      _isTracking = true;
      final location = _getLocation();

      // Get configured values from AppConstants
      final updateInterval = AppConstants.gpsUpdateInterval;
      final minDistance = AppConstants.gpsMinDistance.toDouble();

      AppLogger.info(
          'Starting GPS tracking with interval=${updateInterval}ms, minDistance=${minDistance}m');

      // Configure location settings
      location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: updateInterval,
        distanceFilter: minDistance,
      );

      // Listen to location changes
      _locationSubscription = location.onLocationChanged.listen(
        (LocationData locationData) {
          if (locationData.latitude != null && locationData.longitude != null) {
            final gpsLocation = GPSLocation.fromLocationData(locationData);
            _locationHistory.add(gpsLocation);

            // Limit history to last 1000 points
            if (_locationHistory.length > 1000) {
              _locationHistory.removeAt(0);
            }

            onLocationChanged(gpsLocation);
          }
        },
        onError: (error) {
          // Ignore location tracking errors
        },
      );
    } catch (e) {
      _isTracking = false;
    }
  }

  /// Stop location tracking
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTracking = false;
  }

  /// Get distance traveled (sum of distances between consecutive points)
  double getDistanceTraveled() {
    if (_locationHistory.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < _locationHistory.length - 1; i++) {
      totalDistance += _locationHistory[i].distanceTo(_locationHistory[i + 1]);
    }
    return totalDistance;
  }

  /// Clear location history
  void clearHistory() {
    _locationHistory.clear();
  }

  /// Get average accuracy of tracked points
  double? getAverageAccuracy() {
    if (_locationHistory.isEmpty) return null;

    final accuracies =
        _locationHistory.where((loc) => loc.accuracy != null).toList();
    if (accuracies.isEmpty) return null;

    final sum = accuracies.fold<double>(
      0.0,
      (prev, loc) => prev + (loc.accuracy ?? 0.0),
    );
    return sum / accuracies.length;
  }

  /// Get center point of all locations
  GPSLocation? getCenterPoint() {
    if (_locationHistory.isEmpty) return null;

    final avgLat = _locationHistory.fold<double>(
          0.0,
          (prev, loc) => prev + loc.latitude,
        ) /
        _locationHistory.length;
    final avgLon = _locationHistory.fold<double>(
          0.0,
          (prev, loc) => prev + loc.longitude,
        ) /
        _locationHistory.length;

    return GPSLocation(
      latitude: avgLat,
      longitude: avgLon,
    );
  }

  /// Check if user is within geofence
  ///
  /// [centerLat], [centerLon] - Center of geofence
  /// [radiusMeters] - Radius in meters
  bool isWithinGeofence({
    required double centerLat,
    required double centerLon,
    required double radiusMeters,
  }) {
    if (_locationHistory.isEmpty) return false;

    final lastLocation = _locationHistory.last;
    final center = GPSLocation(latitude: centerLat, longitude: centerLon);
    final distance = lastLocation.distanceTo(center);

    return distance <= radiusMeters;
  }

  /// Get all locations in JSON format
  List<Map<String, dynamic>> getLocationsAsJson() {
    return _locationHistory.map((loc) => loc.toJson()).toList();
  }

  /// Update GPS tracking settings
  /// Should be called after fetching settings from server
  void updateGPSSettings({
    required int updateIntervalMs,
    required int minDistanceM,
  }) {
    if (updateIntervalMs < 1000 || updateIntervalMs > 60000) {
      AppLogger.warning(
          'Invalid GPS interval, keeping current: $updateIntervalMs');
      return;
    }
    if (minDistanceM < 0 || minDistanceM > 1000) {
      AppLogger.warning(
          'Invalid GPS min distance, keeping current: $minDistanceM');
      return;
    }

    AppLogger.info(
        'Updating GPS settings: interval=$updateIntervalMs ms, minDistance=$minDistanceM m');
    AppConstants.gpsUpdateInterval = updateIntervalMs;
    AppConstants.gpsMinDistance = minDistanceM;

    // If tracking is active, restart to apply new settings
    if (_isTracking) {
      AppLogger.info('Restarting GPS tracking with new settings');
      stopTracking();
      // Note: caller should restart tracking if needed
    }
  }

  /// Cleanup resources
  void dispose() {
    stopTracking();
  }
}
