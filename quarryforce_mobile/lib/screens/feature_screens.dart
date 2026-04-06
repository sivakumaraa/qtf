import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/image_compression_service.dart';
import '../utils/error_handling.dart';
import '../utils/logger.dart';

class VisitScreen extends StatefulWidget {
  const VisitScreen({Key? key}) : super(key: key);

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
  final _formKey = GlobalKey<FormState>();
  late LocationService _locationService;
  late ApiService _apiService;
  late ImageCompressionService _imageCompressionService;

  String? _selectedCustomerId;
  String? _visitNotes;
  File? _visitPhoto;
  File? _selfiePhoto;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  final ImagePicker _imagePicker = ImagePicker();
  List<Customer> _customers = [];
  bool _loadingCustomers = true;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService.instance;
    _apiService = ApiService.instance;
    _imageCompressionService = ImageCompressionService();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final customersData = await _apiService.getAllCustomers();
      final customers = customersData.map((c) => Customer.fromJson(c)).toList();
      if (mounted) {
        setState(() {
          _customers = customers;
          _loadingCustomers = false;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.userMessage ?? e.message;
          _loadingCustomers = false;
        });
      }
      AppLogger.error('Failed to load customers', e);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load customers: $e';
          _loadingCustomers = false;
        });
      }
      AppLogger.error('Unexpected error loading customers', e);
    }
  }

  Future<void> _pickVisitPhoto() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      try {
        File photoFile = File(pickedFile.path);
        final compressedPhoto =
            await _imageCompressionService.compressImage(photoFile);
        if (compressedPhoto != null && mounted) {
          setState(() => _visitPhoto = compressedPhoto);
          AppLogger.info('Visit photo compressed and stored');
        }
      } catch (e) {
        if (mounted) {
          AppLogger.error('Failed to compress visit photo', e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to process photo: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickSelfiePhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (pickedFile != null) {
      try {
        File photoFile = File(pickedFile.path);
        final compressedPhoto =
            await _imageCompressionService.compressImage(photoFile);
        if (compressedPhoto != null && mounted) {
          setState(() => _selfiePhoto = compressedPhoto);
          AppLogger.info('Selfie photo compressed and stored');
        }
      } catch (e) {
        if (mounted) {
          AppLogger.error('Failed to compress selfie photo', e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to process selfie: $e')),
          );
        }
      }
    }
  }

  Future<void> _submitVisit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      double latitude = 0;
      double longitude = 0;

      // Get location only on non-web platforms
      if (!kIsWeb) {
        final location = await _locationService.getCurrentLocation();
        if (location == null) {
          throw AppException(
            message: 'Could not get location',
            userMessage:
                'Unable to get your location. Please check GPS settings.',
            errorCode: 'LOCATION_ERROR',
          );
        }
        latitude = location.latitude;
        longitude = location.longitude;
      }

      // Submit visit to backend
      await _apiService.submitVisit(
        repId: 1,
        customerId: int.parse(_selectedCustomerId ?? '0'),
        latitude: latitude,
        longitude: longitude,
        visitPhotoPath: _visitPhoto?.path ?? '',
        selfiePath: _selfiePhoto?.path ?? '',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        notes: _visitNotes ?? '',
        deviceUid: 'device-001',
      );

      if (mounted) {
        setState(() {
          _successMessage = 'Visit submitted successfully!';
          _isSubmitting = false;
        });

        // Reset form
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _formKey.currentState!.reset();
          setState(() {
            _selectedCustomerId = null;
            _visitNotes = null;
            _visitPhoto = null;
            _selfiePhoto = null;
            _successMessage = null;
          });
        }
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.userMessage ?? e.message;
          _isSubmitting = false;
        });
      }
      AppLogger.error('Visit submission error', e);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to submit visit: $e';
          _isSubmitting = false;
        });
      }
      AppLogger.error('Unexpected error during visit submission', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start a New Visit'), elevation: 0),
      body: _loadingCustomers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status cards
                    if (_successMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: TextStyle(color: Colors.green[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Customer selection
                    Text(
                      'Select Customer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCustomerId,
                      hint: const Text('Choose a customer'),
                      items: _customers.map((customer) {
                        return DropdownMenuItem<String>(
                          value: customer.id.toString(),
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCustomerId = value);
                      },
                      validator: (_) => _selectedCustomerId == null
                          ? 'Please select a customer'
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Visit notes
                    Text(
                      'Visit Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      minLines: 3,
                      maxLines: 5,
                      onSaved: (value) => _visitNotes = value,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about this visit...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Visit photo
                    Text(
                      'Visit Photo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickVisitPhoto,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: _visitPhoto == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 48,
                                    color: AppTheme.primary,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Tap to take photo'),
                                ],
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(_visitPhoto!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () =>
                                            setState(() => _visitPhoto = null),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selfie photo
                    Text(
                      'Selfie (for verification)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickSelfiePhoto,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: _selfiePhoto == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.face,
                                    size: 48,
                                    color: AppTheme.primary,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Tap to take selfie'),
                                ],
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(_selfiePhoto!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () =>
                                            setState(() => _selfiePhoto = null),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitVisit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit Visit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class FuelScreen extends StatefulWidget {
  const FuelScreen({Key? key}) : super(key: key);

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  final _formKey = GlobalKey<FormState>();
  late LocationService _locationService;
  late ApiService _apiService;
  late ImageCompressionService _imageCompressionService;

  String _fuelType = 'petrol';
  double? _fuelQuantity;
  double? _fuelCost;
  int? _odometerReading;
  File? _receiptPhoto;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _locationService = LocationService.instance;
    _apiService = ApiService.instance;
    _imageCompressionService = ImageCompressionService();
  }

  Future<void> _pickReceiptPhoto() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      try {
        File photoFile = File(pickedFile.path);
        final compressedPhoto =
            await _imageCompressionService.compressImage(photoFile);
        if (compressedPhoto != null && mounted) {
          setState(() => _receiptPhoto = compressedPhoto);
          AppLogger.info('Receipt photo compressed and stored');
        }
      } catch (e) {
        if (mounted) {
          AppLogger.error('Failed to compress receipt photo', e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to process receipt: $e')),
          );
        }
      }
    }
  }

  Future<void> _submitFuel() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      double latitude = 0;
      double longitude = 0;

      // Get location only on non-web platforms
      if (!kIsWeb) {
        final location = await _locationService.getCurrentLocation();
        if (location == null) {
          throw AppException(
            message: 'Could not get location',
            userMessage:
                'Unable to get your location. Please check GPS settings.',
            errorCode: 'LOCATION_ERROR',
          );
        }
        latitude = location.latitude;
        longitude = location.longitude;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final repId = authProvider.currentUser?.id ?? 0;

      await _apiService.submitFuel(
        repId: repId,
        liters: _fuelQuantity!,
        cost: _fuelCost!,
        fuelType: _fuelType,
        latitude: latitude,
        longitude: longitude,
        odometerReading: _odometerReading,
      );

      if (mounted) {
        setState(() {
          _successMessage = 'Fuel logged successfully!';
          _isSubmitting = false;
        });

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _formKey.currentState!.reset();
          setState(() {
            _fuelQuantity = null;
            _fuelCost = null;
            _odometerReading = null;
            _fuelType = 'petrol';
            _receiptPhoto = null;
            _successMessage = null;
          });
        }
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.userMessage ?? e.message;
          _isSubmitting = false;
        });
      }
      AppLogger.error('Fuel submission error', e);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to submit fuel log: $e';
          _isSubmitting = false;
        });
      }
      AppLogger.error('Unexpected error during fuel submission', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Fuel Expense'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Fuel Type',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(label: Text('Petrol'), value: 'petrol'),
                        ButtonSegment(label: Text('Diesel'), value: 'diesel'),
                      ],
                      selected: {_fuelType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() => _fuelType = newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Quantity (Liters)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSaved: (value) =>
                    _fuelQuantity = double.tryParse(value ?? '0'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter quantity';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'e.g., 50.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.local_gas_station),
                  suffixText: 'L',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cost (₹ INR)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSaved: (value) => _fuelCost = double.tryParse(value ?? '0'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter cost';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'e.g., 2500.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Odometer Reading (optional)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _odometerReading = int.tryParse(value ?? ''),
                decoration: InputDecoration(
                  hintText: 'e.g., 45230',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.speed),
                  suffixText: 'km',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Receipt Photo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickReceiptPhoto,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: _receiptPhoto == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt,
                              size: 48,
                              color: AppTheme.primary,
                            ),
                            SizedBox(height: 8),
                            Text('Tap to capture receipt'),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_receiptPhoto!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      setState(() => _receiptPhoto = null),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFuel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit Fuel Log',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compensation Screen - Display earnings and targets
class CompensationScreen extends StatefulWidget {
  const CompensationScreen({Key? key}) : super(key: key);

  @override
  State<CompensationScreen> createState() => _CompensationScreenState();
}

class _CompensationScreenState extends State<CompensationScreen> {
  late ApiService _apiService;
  late AuthProvider _authProvider;
  SalesTarget? _currentTarget;
  Compensation? _currentCompensation;
  List<Compensation> _progressHistory = [];
  bool _isLoading = true;
  bool _isLoadingHistory = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService.instance;
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadCompensationData();
  }

  Future<void> _loadCompensationData() async {
    if (_authProvider.currentUser?.id == null) {
      setState(() {
        _errorMessage = 'User not logged in';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Load target and progress in parallel
      final targetData = await _apiService.getRepTarget(
        _authProvider.currentUser!.id!,
      );
      final progressData = await _apiService.getRepProgress(
        _authProvider.currentUser!.id!,
      );

      setState(() {
        _currentTarget = SalesTarget.fromJson(targetData);
        _currentCompensation = Compensation.fromJson(progressData);
        _isLoading = false;
      });

      // Load history in background
      _loadProgressHistory();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load compensation data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProgressHistory() async {
    if (_authProvider.currentUser?.id == null) return;

    try {
      setState(() => _isLoadingHistory = true);

      final historyData = await _apiService.getRepProgressHistory(
        _authProvider.currentUser!.id!,
      );

      setState(() {
        _progressHistory =
            historyData.map((item) => Compensation.fromJson(item)).toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compensation'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCompensationData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCompensationData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Currently Earning Card
                        if (_currentCompensation != null)
                          _buildEarningsCard(_currentCompensation!),
                        const SizedBox(height: 20),

                        // Target & Progress Card
                        if (_currentTarget != null)
                          _buildTargetProgressCard(
                            _currentTarget!,
                            _currentCompensation,
                          ),
                        const SizedBox(height: 20),

                        // Calculation Details
                        if (_currentTarget != null &&
                            _currentCompensation != null)
                          _buildCalculationDetails(
                            _currentTarget!,
                            _currentCompensation!,
                          ),
                        const SizedBox(height: 20),

                        // Monthly Breakdown
                        _buildMonthlyBreakdown(),
                        const SizedBox(height: 20),

                        // Sales History Section
                        _buildSalesHistorySection(),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCompensationData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEarningsCard(Compensation compensation) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Month Earnings',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '₹ ${compensation.netCompensation?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEarningsMetric(
                  'Bonus',
                  '₹ ${compensation.bonusEarned?.toStringAsFixed(2) ?? '0.00'}',
                  Colors.green[300]!,
                ),
                _buildEarningsMetric(
                  'Penalty',
                  '₹ ${compensation.penaltyAmount?.toStringAsFixed(2) ?? '0.00'}',
                  Colors.red[300]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetProgressCard(
    SalesTarget target,
    Compensation? compensation,
  ) {
    final salesVolume = compensation?.salesVolumeM3 ?? 0;
    final targetM3 = target.monthlySalesTargetM3 ?? 0;
    final percentage = targetM3 > 0 ? (salesVolume / targetM3) * 100 : 0.0;
    final isAchieved = percentage >= 100;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Sales Target',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAchieved ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          isAchieved ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isAchieved ? Colors.green : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '$targetM3 m³',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achieved',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '$salesVolume m³',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${targetM3 - salesVolume > 0 ? targetM3 - salesVolume : 0} m³',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationDetails(
    SalesTarget target,
    Compensation compensation,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculation Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Incentive Rate',
              '₹ ${target.incentiveRatePerM3?.toStringAsFixed(2) ?? '0.00'}/m³',
            ),
            _buildDetailRow(
              'Max Incentive',
              '₹ ${target.maxIncentivePerM3?.toStringAsFixed(2) ?? '0.00'}/m³',
            ),
            _buildDetailRow(
              'Penalty Rate',
              '₹ ${target.penaltyRatePerM3?.toStringAsFixed(2) ?? '0.00'}/m³',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Sales Volume',
              '${compensation.salesVolumeM3 ?? 0} m³',
              highlight: true,
            ),
            _buildDetailRow(
              'Target',
              '${target.monthlySalesTargetM3 ?? 0} m³',
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: highlight ? AppTheme.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _currentCompensation?.month ??
                  DateFormat('MMMM yyyy').format(DateTime.now()),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Status', _currentCompensation?.status ?? 'Active'),
            _buildDetailRow(
              'Last Updated',
              _currentCompensation?.createdAt != null
                  ? DateFormat(
                      'MMM dd, yyyy',
                    ).format(_currentCompensation!.createdAt!)
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesHistorySection() {
    if (_progressHistory.isEmpty && !_isLoadingHistory) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sales History',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_isLoadingHistory)
          const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_progressHistory.isEmpty)
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No historical data available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _progressHistory.length,
            itemBuilder: (context, index) {
              final item = _progressHistory[index];

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.month ??
                                DateFormat('MMM yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (item.bonusEarned ?? 0) > 0
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (item.bonusEarned ?? 0) > 0
                                  ? 'BONUS ✓'
                                  : 'PENALTY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (item.bonusEarned ?? 0) > 0
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sold: ${item.salesVolumeM3?.toStringAsFixed(1) ?? '0.0'} m³',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            'Net: ₹${item.netCompensation?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: (item.netCompensation ?? 0) >= 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bonus: ₹${item.bonusEarned?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.green[600]),
                          ),
                          Text(
                            'Penalty: ₹${item.penaltyAmount?.toStringAsFixed(2) ?? '0.00'}',
                            style:
                                TextStyle(fontSize: 12, color: Colors.red[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Profile Screen - User settings and account management
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthProvider _authProvider;
  bool _isEditingPhone = false;
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _phoneController.text = _authProvider.currentUser?.phone ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _savePhone() {
    if (!mounted) return;
    // Could save to backend here
    setState(() => _isEditingPhone = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Phone number updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              (user?.name?.isNotEmpty == true
                                      ? user!.name![0]
                                      : user?.username[0] ?? 'U')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? user?.username ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rep ID: ${user?.id ?? '-'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.deviceUid ?? 'Unknown Device',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Account Information Section
                _buildSectionTitle('Account Information'),
                const SizedBox(height: 12),
                _buildInfoCard('Username', user?.username ?? '-'),
                const SizedBox(height: 8),
                _buildInfoCard('Email', user?.email ?? '-'),
                const SizedBox(height: 20),

                // Contact Information Section
                _buildSectionTitle('Contact Information'),
                const SizedBox(height: 12),
                _isEditingPhone
                    ? _buildEditPhoneField()
                    : _buildInfoCard('Phone', user?.phone ?? '-'),
                if (!_isEditingPhone)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () => setState(() => _isEditingPhone = true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                const SizedBox(height: 20),

                // Account Status Section
                _buildSectionTitle('Account Status'),
                const SizedBox(height: 12),
                _buildInfoCard('Target Status', user?.targetStatus ?? 'Active'),
                const SizedBox(height: 8),
                _buildInfoCard(
                  'Member Since',
                  user?.createdAt != null
                      ? DateFormat('MMM dd, yyyy').format(user!.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 20),

                // Device Information Section
                _buildSectionTitle('Device Information'),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Device UID',
                  authProvider.deviceUid ?? 'Not Set',
                ),
                const SizedBox(height: 20),

                // Actions Section
                _buildSectionTitle('Actions'),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.help,
                  label: 'Help & FAQ',
                  onPressed: () {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help content coming soon')),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: Icons.notification_important,
                  label: 'Notifications',
                  onPressed: () {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications settings coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: Icons.privacy_tip,
                  label: 'Privacy & Security',
                  onPressed: () {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy settings coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout?'),
                          content: const Text(
                            'Are you sure you want to logout? You\'ll need to login again on the next session.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                authProvider.logout();
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEditPhoneField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _isEditingPhone = false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _savePhone, child: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
