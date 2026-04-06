import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../config/constants.dart';
import '../utils/logger.dart';
import 'cache_service.dart';
import 'offline_queue_service.dart';
import '../utils/error_handling.dart';

/// Main API Service for handling all backend communication
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  late SharedPreferences _prefs;
  late CacheService _cacheService;
  late OfflineQueueService _offlineQueueService;
  late ErrorHandlingService _errorHandlingService;
  String? _authToken;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  static ApiService get instance => _instance;

  /// Initialize Dio with base options and interceptors
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  /// Initialize with shared preferences and services
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _cacheService = CacheService();
    _offlineQueueService = OfflineQueueService();
    _errorHandlingService = ErrorHandlingService();

    // Initialize cache service
    await _cacheService.initialize();
    await _offlineQueueService.initialize();

    // Load stored auth token if available
    _authToken = _prefs.getString(AppConstants.userTokenKey);
    AppLogger.debug('ApiService initialized with all services');
  }

  /// Set auth token (called after successful login)
  void setAuthToken(String token) {
    _authToken = token;
    _prefs.setString(AppConstants.userTokenKey, token);
  }

  /// Clear auth token (called on logout)
  void clearAuthToken() {
    _authToken = null;
    _prefs.remove(AppConstants.userTokenKey);
  }

  // ==========================================
  // AUTHENTICATION APIs
  // ==========================================

  /// Login - Bind device and authenticate
  ///
  /// POST /api/login
  /// Body: {
  ///   email: string,
  ///   device_uid: string
  /// }
  Future<Map<String, dynamic>> login({
    required String email,
    required String deviceUid,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'device_uid': deviceUid,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Extract and store token if provided
          if (data['token'] != null) {
            setAuthToken(data['token']);
          }
          AppLogger.info('Login successful for user: $email');
          return data;
        } else {
          throw AppException(
            message: data['message'] ?? 'Login failed',
            userMessage: 'Invalid email or device. Please try again.',
            errorCode: 'LOGIN_FAILED',
          );
        }
      } else {
        throw AppException(
          message: 'Login failed with status ${response.statusCode}',
          userMessage: 'Unable to login. Please try again.',
          statusCode: response.statusCode,
          errorCode: 'LOGIN_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  /// Device check-in
  ///
  /// POST /api/checkin
  /// Body: {
  ///   rep_id: number,
  ///   device_uid: string,
  ///   timestamp: string (ISO)
  /// }
  Future<Map<String, dynamic>> checkIn({
    required int repId,
    required String deviceUid,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.checkinEndpoint,
        data: {
          'rep_id': repId,
          'device_uid': deviceUid,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        AppLogger.info('Check-in successful for rep: $repId');
        return response.data;
      } else {
        throw AppException(
          message: 'Check-in failed',
          userMessage: 'Unable to check in. Please try again.',
          statusCode: response.statusCode,
          errorCode: 'CHECKIN_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  // ==========================================
  // DATA SUBMISSION APIs
  // ==========================================

  /// Submit visit data with location and photo
  ///
  /// POST /api/visit/submit
  /// Body: {
  ///   rep_id: number,
  ///   customer_id: number,
  ///   location_lat: number,
  ///   location_lon: number,
  ///   visit_photo_path: string (base64 or file path),
  ///   selfie_path: string (base64 or file path),
  ///   visit_start_time: string (ISO),
  ///   visit_end_time: string (ISO),
  ///   notes: string,
  ///   device_uid: string
  /// }
  Future<Map<String, dynamic>> submitVisit({
    required int repId,
    required int customerId,
    required double latitude,
    required double longitude,
    required String visitPhotoPath,
    required String selfiePath,
    required DateTime startTime,
    required DateTime endTime,
    required String notes,
    required String deviceUid,
  }) async {
    try {
      final visitData = {
        'rep_id': repId,
        'customer_id': customerId,
        'location_lat': latitude,
        'location_lon': longitude,
        'visit_photo_path': visitPhotoPath,
        'selfie_path': selfiePath,
        'visit_start_time': startTime.toIso8601String(),
        'visit_end_time': endTime.toIso8601String(),
        'notes': notes,
        'device_uid': deviceUid,
      };

      final response = await _dio.post(
        AppConstants.visitSubmitEndpoint,
        data: visitData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        AppLogger.info(
            'Visit submitted successfully for customer: $customerId');
        return response.data;
      } else {
        throw AppException(
          message: 'Visit submission failed',
          userMessage: 'Unable to submit visit. Please try again.',
          statusCode: response.statusCode,
          errorCode: 'VISIT_SUBMIT_ERROR',
        );
      }
    } on DioException catch (e) {
      // Queue the request for offline retry
      await _offlineQueueService.enqueue(
        AppConstants.visitSubmitEndpoint,
        'POST',
        {
          'rep_id': repId,
          'customer_id': customerId,
          'location_lat': latitude,
          'location_lon': longitude,
          'visit_photo_path': visitPhotoPath,
          'selfie_path': selfiePath,
          'visit_start_time': startTime.toIso8601String(),
          'visit_end_time': endTime.toIso8601String(),
          'notes': notes,
          'device_uid': deviceUid,
        },
      );
      AppLogger.warning('Visit queued for offline retry');
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  /// Submit fuel log
  ///
  /// POST /api/fuel/submit
  /// Body: {
  ///   rep_id: number,
  ///   fuel_liters: number,
  ///   fuel_cost: number,
  ///   fuel_type: string ('petrol' or 'diesel'),
  ///   receipt_photo_path: string,
  ///   location_lat: number,
  ///   location_lon: number,
  ///   timestamp: string (ISO),
  ///   device_uid: string
  /// }
  Future<Map<String, dynamic>> submitFuel({
    required int repId,
    required double liters,
    required double cost,
    required String fuelType,
    String? receiptPhotoPath,
    required double latitude,
    required double longitude,
    String? deviceUid,
    int? odometerReading,
  }) async {
    try {
      final fuelData = {
        'rep_id': repId,
        'fuel_quantity': liters,
        'amount': cost,
        'fuel_type': fuelType,
        'odometer_reading': odometerReading,
        'lat': latitude,
        'lng': longitude,
      };

      final response = await _dio.post(
        AppConstants.fuelSubmitEndpoint,
        data: fuelData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        AppLogger.info('Fuel submitted successfully');
        return response.data;
      } else {
        throw AppException(
          message: 'Fuel submission failed',
          userMessage: 'Unable to submit fuel record. Please try again.',
          statusCode: response.statusCode,
          errorCode: 'FUEL_SUBMIT_ERROR',
        );
      }
    } on DioException catch (e) {
      // Queue the request for offline retry
      await _offlineQueueService.enqueue(
        AppConstants.fuelSubmitEndpoint,
        'POST',
        {
          'rep_id': repId,
          'fuel_quantity': liters,
          'amount': cost,
          'fuel_type': fuelType,
          'odometer_reading': odometerReading,
          'lat': latitude,
          'lng': longitude,
        },
      );
      AppLogger.warning('Fuel record queued for offline retry');
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  // ==========================================
  // DATA RETRIEVAL APIs
  // ==========================================

  /// Get all representatives
  ///
  /// GET /api/admin/reps
  /// Cached for 1 hour
  Future<List<Map<String, dynamic>>> getAllReps() async {
    try {
      // Check cache first
      final cachedReps = await _cacheService.getCache('all_reps');
      if (cachedReps != null) {
        AppLogger.debug('Returning cached reps');
        return List<Map<String, dynamic>>.from(cachedReps as List);
      }

      final response = await _dio.get(AppConstants.adminRepsEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        List<Map<String, dynamic>> reps = [];

        if (data is List) {
          reps = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          reps = List<Map<String, dynamic>>.from(data['data']);
        }

        // Cache for 1 hour (3600 seconds)
        await _cacheService.setCache('all_reps', reps, ttlSeconds: 3600);

        return reps;
      } else {
        throw AppException(
          message: 'Failed to fetch reps',
          userMessage: 'Unable to load representatives. Please try again.',
          statusCode: response.statusCode,
          errorCode: 'FETCH_REPS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  /// Get all customers for targeting
  ///
  /// GET /api/admin/customers
  /// Cached for 1 hour
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      // Check cache first
      final cachedCustomers = await _cacheService.getCache('all_customers');
      if (cachedCustomers != null) {
        AppLogger.debug('Returning cached customers');
        return List<Map<String, dynamic>>.from(cachedCustomers as List);
      }

      final response = await _dio.get(AppConstants.adminCustomersEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        List<Map<String, dynamic>> customers = [];

        if (data is List) {
          customers = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          customers = List<Map<String, dynamic>>.from(data['data']);
        }

        // Cache for 1 hour (3600 seconds)
        await _cacheService.setCache('all_customers', customers,
            ttlSeconds: 3600);

        return customers;
      } else {
        throw AppException(
          message: 'Failed to fetch customers',
          userMessage: 'Unable to load customers. Please try again.',
          statusCode: response.statusCode,
          errorCode: 'FETCH_CUSTOMERS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  /// Get customers assigned to a specific rep
  ///
  /// GET /api/rep/customers/:rep_id
  Future<List<Map<String, dynamic>>> getRepCustomers(int repId, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      final cacheKey = 'rep_customers_$repId';
      if (!forceRefresh) {
        final cachedCustomers = await _cacheService.getCache(cacheKey);
        if (cachedCustomers != null) {
          AppLogger.debug('Returning cached customers for rep $repId');
          return List<Map<String, dynamic>>.from(cachedCustomers as List);
        }
      }

      final endpoint = AppConstants.repCustomersEndpoint(repId);
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        List<Map<String, dynamic>> customers = [];

        if (data is Map && data['success'] == true) {
          if (data['data'] is List) {
            customers = List<Map<String, dynamic>>.from(data['data']);
          }
        } else if (data is List) {
          customers = List<Map<String, dynamic>>.from(data);
        }

        // Cache for 1 hour
        await _cacheService.setCache(cacheKey, customers, ttlSeconds: 3600);

        AppLogger.info('Fetched ${customers.length} customers for rep $repId');
        return customers;
      } else {
        throw AppException(
          message: 'Failed to fetch rep customers',
          userMessage: 'Unable to load your customers. Please try again.',
          statusCode: response.statusCode,
          errorCode: 'FETCH_REP_CUSTOMERS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  /// Create a new customer
  ///
  /// POST /admin/customers
  Future<Map<String, dynamic>> createCustomer({
    required int repId,
    required String name,
    String? phone,
    String? location,
    double? latitude,
    double? longitude,
    String? contactPerson,
    String? siteType,
    String? address,
    List<String>? materialNeeds,
    String? rmcGrade,
    List<String>? aggregateTypes,
    double? volume,
    String? volumeUnit,
    DateTime? requiredDate,
    double? amountPerUnit,
    double? boomPumpAmount,
  }) async {
    try {
      final payload = {
        'name': name,
        'assigned_rep_id': repId,
        if (phone != null && phone.isNotEmpty) 'phone_no': phone,
        if (location != null && location.isNotEmpty) 'location': location,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (contactPerson != null && contactPerson.isNotEmpty)
          'site_incharge_name': contactPerson,
        if (siteType != null && siteType.isNotEmpty) 'site_type': siteType,
        if (address != null && address.isNotEmpty) 'address': address,
        if (materialNeeds != null && materialNeeds.isNotEmpty)
          'material_needs': jsonEncode(materialNeeds),
        if (rmcGrade != null && rmcGrade.isNotEmpty) 'rmc_grade': rmcGrade,
        if (aggregateTypes != null && aggregateTypes.isNotEmpty)
          'aggregate_types': jsonEncode(aggregateTypes),
        if (volume != null && volume > 0) 'volume': volume,
        if (volumeUnit != null && volumeUnit.isNotEmpty)
          'volume_unit': volumeUnit,
        if (requiredDate != null)
          'required_date': requiredDate.toIso8601String(),
        if (amountPerUnit != null && amountPerUnit > 0)
          'amount_concluded_per_unit': amountPerUnit,
        if (boomPumpAmount != null && boomPumpAmount > 0)
          'boom_pump_amount': boomPumpAmount,
      };

      AppLogger.debug('Creating customer: $name for rep: $repId');

      final response = await _dio.post(
        '${AppConstants.apiBaseUrl}/admin/customers',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          AppLogger.info('Customer created successfully');
          // Invalidate cached customer lists so new customer appears
          await _cacheService.clearCache('rep_customers_$repId');
          await _cacheService.clearCache('all_customers');
          return {
            'success': true,
            'message': data['message'] ?? 'Customer created successfully',
            'data': data['data'],
          };
        } else {
          throw AppException(
            message: 'Failed to create customer',
            userMessage: data['error'] ?? 'Unable to create customer',
            statusCode: response.statusCode,
            errorCode: 'CREATE_CUSTOMER_ERROR',
          );
        }
      } else {
        throw AppException(
          message: 'Failed to create customer',
          userMessage: 'Server returned status ${response.statusCode}',
          statusCode: response.statusCode,
          errorCode: 'CREATE_CUSTOMER_ERROR',
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException creating customer: ${e.message}');
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('Unexpected error creating customer', e, st);
      throw _errorHandlingService.handleError(e, st);
    }
  }

  /// Update an existing customer
  ///
  /// PUT /admin/customers/:id
  Future<Map<String, dynamic>> updateCustomer({
    required int customerId,
    required Map<String, dynamic> fields,
  }) async {
    try {
      AppLogger.debug('Updating customer $customerId');

      final response = await _dio.put(
        '${AppConstants.adminCustomersEndpoint}/$customerId',
        data: fields,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          // Invalidate all customer caches so changes appear immediately
          await _cacheService.clearCache('all_customers');
          await _cacheService.clearCacheByPrefix('rep_customers_');
          AppLogger.info('Customer $customerId updated successfully');
          return Map<String, dynamic>.from(data);
        }
        throw AppException(
          message: 'Failed to update customer',
          userMessage: (data is Map ? data['error'] : null) ??
              'Unable to update customer',
          errorCode: 'UPDATE_CUSTOMER_ERROR',
        );
      } else {
        throw AppException(
          message: 'Failed to update customer',
          userMessage: 'Server returned status ${response.statusCode}',
          statusCode: response.statusCode,
          errorCode: 'UPDATE_CUSTOMER_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  /// Create an order with multiple line items
  ///
  /// POST /rep/create-order
  Future<List<dynamic>> getRepOrders(int repId) async {
    try {
      AppLogger.debug('Fetching orders for rep $repId');
      final response = await _dio.get('/rep/orders/$repId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          return data['data'] as List? ?? [];
        }
      }
      return [];
    } on DioException catch (e) {
      AppLogger.error('DioException fetching rep orders: ${e.message}');
      return [];
    } catch (e) {
      AppLogger.error('Error fetching rep orders', e);
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required int repId,
    required int customerId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // Calculate total amount and build product details from items
      double totalAmount = 0;
      double totalBoomPump = 0;
      final productLines = <String>[];
      String? firstRequiredDate;
      for (final item in items) {
        final qty = (item['quantity'] as num?)?.toDouble() ?? 0;
        final price = (item['unit_price'] as num?)?.toDouble() ?? 0;
        final boomPump = (item['boom_pump_amount'] as num?)?.toDouble() ?? 0;
        totalAmount += qty * price;
        totalBoomPump += boomPump;
        productLines.add(
            '${item['product_name']} x$qty ${item['volume_unit'] ?? ''} @₹$price');
        if (firstRequiredDate == null && item['required_date'] != null) {
          firstRequiredDate = item['required_date'] as String;
        }
      }

      final payload = {
        'rep_id': repId,
        'customer_id': customerId,
        'order_amount': totalAmount,
        'boom_pump_amount': totalBoomPump,
        'product_details': productLines.join('; '),
        'order_date': DateTime.now().toIso8601String().split('T')[0],
        'required_date': firstRequiredDate,
        'status': 'pending',
        'items': items,
      };

      AppLogger.debug(
          'Creating order for customer $customerId with ${items.length} items');

      final response = await _dio.post(
        AppConstants.adminOrdersEndpoint,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          AppLogger.info('Order created successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Order created successfully',
            'data': data['data'],
          };
        } else {
          throw AppException(
            message: 'Failed to create order',
            userMessage: data['message'] ?? 'Unable to create order',
            statusCode: response.statusCode,
            errorCode: 'CREATE_ORDER_ERROR',
          );
        }
      } else {
        throw AppException(
          message: 'Failed to create order',
          userMessage: 'Server returned status ${response.statusCode}',
          statusCode: response.statusCode,
          errorCode: 'CREATE_ORDER_ERROR',
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException creating order: ${e.message}');
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('Unexpected error creating order', e, st);
      throw _errorHandlingService.handleError(e, st);
    }
  }

  /// Get rep's sales target
  ///
  /// GET /api/admin/rep-targets/:rep_id
  Future<Map<String, dynamic>> getRepTarget(int repId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.adminRepTargetsEndpoint}/$repId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Unwrap {success, data} envelope
        if (responseData is Map && responseData['data'] != null) {
          final inner = responseData['data'];
          if (inner is List && inner.isNotEmpty) {
            return Map<String, dynamic>.from(inner[0] as Map);
          } else if (inner is Map) {
            return Map<String, dynamic>.from(inner);
          }
        }
        // Fallback: treat entire response as target data
        if (responseData is Map) {
          return Map<String, dynamic>.from(responseData);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to fetch rep target');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get rep's progress for current month
  ///
  /// GET /api/admin/rep-progress/:rep_id?month=YYYY-MM
  Future<Map<String, dynamic>> getRepProgress(
    int repId, {
    String? month,
  }) async {
    try {
      String endpoint = '${AppConstants.adminRepProgressEndpoint}/$repId';
      if (month != null) {
        endpoint += '?month=$month';
      }

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final responseData = response.data ?? {};
        // Unwrap {success, data} envelope
        if (responseData is Map && responseData['data'] != null) {
          return Map<String, dynamic>.from(responseData['data'] as Map);
        }
        return responseData is Map
            ? Map<String, dynamic>.from(responseData)
            : {};
      } else {
        throw Exception('Failed to fetch rep progress');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get rep's historical progress (all months)
  ///
  /// GET /api/admin/rep-progress-history/:rep_id
  Future<List<Map<String, dynamic>>> getRepProgressHistory(int repId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.adminRepProgressEndpoint}-history/$repId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return List<Map<String, dynamic>>.from(
            (data['data'] as List)
                .map((item) => Map<String, dynamic>.from(item as Map)),
          );
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item as Map)),
          );
        }
        return [];
      } else {
        throw Exception('Failed to fetch rep progress history');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get settings
  ///
  /// GET /api/settings
  /// Cached for 6 hours
  Future<Map<String, dynamic>> getSettings() async {
    try {
      // Check cache first
      final cachedSettings = await _cacheService.getCache('settings');
      if (cachedSettings != null) {
        AppLogger.debug('Returning cached settings');
        return Map<String, dynamic>.from(cachedSettings as Map);
      }

      final response = await _dio.get(AppConstants.settingsEndpoint);

      if (response.statusCode == 200) {
        final settings = response.data ?? {};
        // Cache for 6 hours (21600 seconds)
        await _cacheService.setCache('settings', settings, ttlSeconds: 21600);
        return settings;
      } else {
        throw AppException(
          message: 'Failed to fetch settings',
          userMessage: 'Unable to load settings. Please try again.',
          statusCode: response.statusCode,
          errorCode: 'SETTINGS_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw _errorHandlingService.handleError(e, st);
    }
  }

  // ==========================================
  // PROFILE APIs
  // ==========================================

  /// Update user profile with name, phone, and optional photo
  ///
  /// POST /api/profile/update
  /// Body (multipart):
  ///   rep_id: number
  ///   name: string
  ///   phone: string
  ///   photo: File (optional)
  Future<Map<String, dynamic>> updateProfile({
    required int repId,
    required String name,
    required String phone,
    File? photoFile,
  }) async {
    try {
      late Response response;

      if (photoFile != null) {
        // Use multipart/form-data for file upload
        final formData = FormData.fromMap({
          'rep_id': repId,
          'name': name,
          'phone': phone,
          'photo': await MultipartFile.fromFile(
            photoFile.path,
            filename: 'profile_photo.jpg',
          ),
        });

        response = await _dio.post(
          '/profile/update',
          data: formData,
        );
      } else {
        // Use JSON for text-only updates
        response = await _dio.post(
          '/profile/update',
          data: {
            'rep_id': repId,
            'name': name,
            'phone': phone,
          },
        );
      }

      final responseData = response.data is String
          ? jsonDecode(response.data)
          : response.data ?? {};

      AppLogger.debug('Profile update response: $responseData');
      AppLogger.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          AppLogger.info('Profile updated successfully');
          AppLogger.debug('User data from response: ${responseData['user']}');
          return {
            'success': true,
            'message':
                responseData['message'] ?? 'Profile updated successfully',
            'data': responseData['user'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to update profile',
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } on DioException catch (e) {
      AppLogger.error('DioException updating profile: ${e.message}');
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Connection error';
      return {
        'success': false,
        'message': 'Error updating profile: $errorMessage',
      };
    } catch (e) {
      AppLogger.error('Unexpected error updating profile: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // ==========================================
  // ERROR HANDLING
  // ==========================================

  /// Handle Dio errors using centralized error service
  AppException _handleDioError(DioException error, [StackTrace? stackTrace]) {
    AppException appException;

    switch (error.type) {
      case DioExceptionType.badResponse:
        if (error.response != null) {
          appException = _errorHandlingService.handleHttpError(
            error.response!.statusCode ?? 500,
            error.response?.data?.toString() ?? '',
          );
        } else {
          appException = _errorHandlingService.handleError(error, stackTrace);
        }
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        appException = AppException(
          message: 'Request timeout',
          userMessage:
              'The request took too long. Please check your internet connection.',
          errorCode: 'TIMEOUT_ERROR',
          originalException: error,
          stackTrace: stackTrace,
        );
        break;
      case DioExceptionType.connectionError:
        appException = AppException(
          message: 'Connection error',
          userMessage:
              'Unable to connect to the server. Please check your internet.',
          errorCode: 'CONNECTION_ERROR',
          originalException: error,
          stackTrace: stackTrace,
        );
        break;
      default:
        appException = _errorHandlingService.handleError(error, stackTrace);
    }

    AppLogger.error('API Error: ${appException.message}', error, stackTrace);
    return appException;
  }

  /// Check if online
  Future<bool> isOnline() async {
    try {
      final response = await _dio.get('/').timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Timeout'),
          );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
