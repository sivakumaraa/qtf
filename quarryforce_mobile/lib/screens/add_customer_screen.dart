import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/error_handling.dart';
import '../utils/logger.dart';

/// Add New Customer Screen
class AddCustomerScreen extends StatefulWidget {
  final Function(Customer)? onCustomerCreated;

  const AddCustomerScreen({Key? key, this.onCustomerCreated}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  late ApiService _apiService;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _addressController = TextEditingController();

  String _siteType = 'Quarry';

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _siteTypes = ['Quarry', 'Site', 'Dump'];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService.instance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _contactPersonController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (_nameController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer name is required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final repId = authProvider.currentUser?.id ?? 0;

      if (repId == 0) {
        throw AppException(
          message: 'User ID not available',
          userMessage: 'Invalid user session',
        );
      }

      final result = await _apiService.createCustomer(
        repId: repId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        latitude: _latitudeController.text.isEmpty
            ? null
            : double.tryParse(_latitudeController.text),
        longitude: _longitudeController.text.isEmpty
            ? null
            : double.tryParse(_longitudeController.text),
        contactPerson: _contactPersonController.text.trim().isEmpty
            ? null
            : _contactPersonController.text.trim(),
        siteType: _siteType,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        AppLogger.info('Customer created with ID: ${result['data']['id']}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Customer created successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Create Customer object from result
        if (result['data'] is Map) {
          final customer = Customer.fromJson(result['data']);
          widget.onCustomerCreated?.call(customer);
        }

        // Return to previous screen
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } on AppException catch (e) {
      AppLogger.error('Form submission error', e);
      if (mounted) {
        setState(() => _errorMessage = e.userMessage);
      }
    } catch (e) {
      AppLogger.error('Unexpected error', e);
      if (mounted) {
        setState(() => _errorMessage = 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer'),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Section 1: Basic Information
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    // Customer Name (Required)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name *',
                        hintText: 'Enter business/quarry name',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Customer name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        hintText: 'Enter phone number',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // Contact Person
                    TextFormField(
                      controller: _contactPersonController,
                      decoration: InputDecoration(
                        labelText: 'Contact Person',
                        hintText: 'Site in-charge name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Location Information
                    Text(
                      'Location (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    // Location/Address
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location/City',
                        hintText: 'e.g., Bangalore, Pune',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Latitude & Longitude
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            decoration: InputDecoration(
                              labelText: 'Latitude',
                              hintText: 'e.g., 12.9716',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                              hintText: 'e.g., 77.5946',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Full Address
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Full Address',
                        hintText: 'Complete address of the site',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // Section 3: Site Details
                    Text(
                      'Site Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    // Site Type
                    DropdownButtonFormField<String>(
                      initialValue: _siteType,
                      decoration: InputDecoration(
                        labelText: 'Site Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _siteTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _siteType = value ?? 'Quarry');
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Customer',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
