import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/logger.dart';

/// Represents a queued request for offline mode
class QueuedRequest {
  final String id;
  final String endpoint;
  final String method;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;

  QueuedRequest({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'endpoint': endpoint,
        'method': method,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory QueuedRequest.fromJson(Map<String, dynamic> json) => QueuedRequest(
        id: json['id'] as String,
        endpoint: json['endpoint'] as String,
        method: json['method'] as String,
        data: json['data'] as Map<String, dynamic>,
        createdAt: DateTime.parse(json['createdAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

/// Service for managing offline request queue
class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();

  factory OfflineQueueService() {
    return _instance;
  }

  OfflineQueueService._internal();

  late SharedPreferences _prefs;
  static const String _queueKey = 'offline_queue';
  static const int _maxRetries = 3;
  static const int _maxQueueSize = 100;

  /// Initialize the offline queue service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('Offline queue service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize offline queue service', e);
    }
  }

  /// Add a request to the queue
  Future<bool> enqueue(
    String endpoint,
    String method,
    Map<String, dynamic> data,
  ) async {
    try {
      final queue = await getQueue();

      // Check queue size limit
      if (queue.length >= _maxQueueSize) {
        AppLogger.warning('Offline queue is full, removing oldest request');
        queue.removeAt(0);
      }

      final request = QueuedRequest(
        id: '${DateTime.now().millisecondsSinceEpoch}_${endpoint.hashCode}',
        endpoint: endpoint,
        method: method,
        data: data,
        createdAt: DateTime.now(),
      );

      queue.add(request);
      await _saveQueue(queue);

      AppLogger.info('Request queued: $endpoint');
      return true;
    } catch (e) {
      AppLogger.error('Failed to enqueue request', e);
      return false;
    }
  }

  /// Get all queued requests
  Future<List<QueuedRequest>> getQueue() async {
    try {
      final queueJson = _prefs.getString(_queueKey);
      if (queueJson == null) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(queueJson);
      return decodedList
          .map((item) => QueuedRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get offline queue', e);
      return [];
    }
  }

  /// Remove a request from the queue
  Future<bool> dequeue(String requestId) async {
    try {
      final queue = await getQueue();
      queue.removeWhere((req) => req.id == requestId);
      await _saveQueue(queue);

      AppLogger.debug('Request dequeued: $requestId');
      return true;
    } catch (e) {
      AppLogger.error('Failed to dequeue request', e);
      return false;
    }
  }

  /// Update retry count for a request
  Future<bool> updateRetryCount(String requestId) async {
    try {
      final queue = await getQueue();
      final requestIndex = queue.indexWhere((req) => req.id == requestId);

      if (requestIndex != -1) {
        queue[requestIndex].retryCount++;

        // Remove if max retries exceeded
        if (queue[requestIndex].retryCount >= _maxRetries) {
          AppLogger.warning('Max retries exceeded for request: $requestId');
          queue.removeAt(requestIndex);
        }

        await _saveQueue(queue);
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Failed to update retry count', e);
      return false;
    }
  }

  /// Clear the entire queue
  Future<bool> clearQueue() async {
    try {
      await _prefs.remove(_queueKey);
      AppLogger.info('Offline queue cleared');
      return true;
    } catch (e) {
      AppLogger.error('Failed to clear offline queue', e);
      return false;
    }
  }

  /// Get queue statistics
  Future<Map<String, dynamic>> getQueueStats() async {
    try {
      final queue = await getQueue();
      return {
        'total_requests': queue.length,
        'pending_requests':
            queue.where((r) => r.retryCount < _maxRetries).length,
        'failed_requests':
            queue.where((r) => r.retryCount >= _maxRetries).length,
        'oldest_request': queue.isNotEmpty ? queue.first.createdAt : null,
        'newest_request': queue.isNotEmpty ? queue.last.createdAt : null,
      };
    } catch (e) {
      AppLogger.error('Failed to get queue statistics', e);
      return {};
    }
  }

  /// Save queue to local storage
  Future<void> _saveQueue(List<QueuedRequest> queue) async {
    try {
      final queueJson = jsonEncode(queue.map((r) => r.toJson()).toList());
      await _prefs.setString(_queueKey, queueJson);
    } catch (e) {
      AppLogger.error('Failed to save offline queue', e);
    }
  }
}
