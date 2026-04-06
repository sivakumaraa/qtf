import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/logger.dart';

/// Service for managing local caching of API responses and data
class CacheService {
  static final CacheService _instance = CacheService._internal();

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  late SharedPreferences _prefs;
  static const String _cachePrefix = 'cache_';
  static const String _ttlPrefix = 'ttl_';

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('Cache service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize cache service', e);
    }
  }

  /// Save data to cache with optional TTL (Time To Live) in seconds
  Future<bool> setCache(
    String key,
    dynamic value, {
    int? ttlSeconds,
  }) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final jsonValue = jsonEncode(value);

      await _prefs.setString(cacheKey, jsonValue);

      // Set TTL if provided
      if (ttlSeconds != null) {
        final expirationTime = DateTime.now()
            .add(Duration(seconds: ttlSeconds))
            .millisecondsSinceEpoch;
        final ttlKey = '$_ttlPrefix$key';
        await _prefs.setInt(ttlKey, expirationTime);
      }

      AppLogger.debug('Cache set: $key');
      return true;
    } catch (e) {
      AppLogger.error('Failed to set cache: $key', e);
      return false;
    }
  }

  /// Retrieve data from cache
  Future<dynamic> getCache(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final ttlKey = '$_ttlPrefix$key';

      // Check if cache exists
      final cachedValue = _prefs.getString(cacheKey);
      if (cachedValue == null) {
        return null;
      }

      // Check if cache has expired
      final ttl = _prefs.getInt(ttlKey);
      if (ttl != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > ttl) {
          await clearCache(key);
          AppLogger.debug('Cache expired: $key');
          return null;
        }
      }

      AppLogger.debug('Cache retrieved: $key');
      return jsonDecode(cachedValue);
    } catch (e) {
      AppLogger.error('Failed to get cache: $key', e);
      return null;
    }
  }

  /// Clear specific cache entry
  Future<bool> clearCache(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final ttlKey = '$_ttlPrefix$key';

      await Future.wait([
        _prefs.remove(cacheKey),
        _prefs.remove(ttlKey),
      ]);

      AppLogger.debug('Cache cleared: $key');
      return true;
    } catch (e) {
      AppLogger.error('Failed to clear cache: $key', e);
      return false;
    }
  }

  /// Clear all cached data
  Future<bool> clearAllCache() async {
    try {
      final keys = _prefs.getKeys();
      final cacheKeys = keys.where(
          (key) => key.startsWith(_cachePrefix) || key.startsWith(_ttlPrefix));

      for (final key in cacheKeys) {
        await _prefs.remove(key);
      }

      AppLogger.info('All cache cleared');
      return true;
    } catch (e) {
      AppLogger.error('Failed to clear all cache', e);
      return false;
    }
  }

  /// Clear all cache entries whose key starts with a given prefix
  Future<void> clearCacheByPrefix(String prefix) async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('$_cachePrefix$prefix') ||
            key.startsWith('$_ttlPrefix$prefix')) {
          await _prefs.remove(key);
        }
      }
      AppLogger.debug('Cache cleared for prefix: $prefix');
    } catch (e) {
      AppLogger.error('Failed to clear cache by prefix: $prefix', e);
    }
  }

  /// Check if cache exists and is valid
  Future<bool> isCacheValid(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final ttlKey = '$_ttlPrefix$key';

      if (!_prefs.containsKey(cacheKey)) {
        return false;
      }

      final ttl = _prefs.getInt(ttlKey);
      if (ttl != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > ttl) {
          await clearCache(key);
          return false;
        }
      }

      return true;
    } catch (e) {
      AppLogger.error('Failed to validate cache: $key', e);
      return false;
    }
  }

  /// Get all cache keys
  Set<String> getAllCacheKeys() {
    try {
      return _prefs
          .getKeys()
          .where((key) => key.startsWith(_cachePrefix))
          .map((key) => key.replaceFirst(_cachePrefix, ''))
          .toSet();
    } catch (e) {
      AppLogger.error('Failed to get all cache keys', e);
      return {};
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    try {
      final keys = _prefs.getKeys();
      final cacheKeys =
          keys.where((key) => key.startsWith(_cachePrefix)).toList();
      final ttlKeys = keys.where((key) => key.startsWith(_ttlPrefix)).toList();

      return {
        'total_entries': cacheKeys.length,
        'ttl_entries': ttlKeys.length,
        'cache_keys':
            cacheKeys.map((k) => k.replaceFirst(_cachePrefix, '')).toList(),
      };
    } catch (e) {
      AppLogger.error('Failed to get cache statistics', e);
      return {};
    }
  }
}
