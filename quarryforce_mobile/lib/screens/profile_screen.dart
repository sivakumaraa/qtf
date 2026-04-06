import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../utils/logger.dart';

/// Profile Screen - Edit rep profile, upload photo, update details
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values first
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Then load user data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfileData();
    });
  }

  void _initializeProfileData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    AppLogger.info('ProfileScreen - Loading user data');
    AppLogger.debug('Current user: $currentUser');
    AppLogger.debug('User name: ${currentUser?.name}');
    AppLogger.debug('User phone: ${currentUser?.phone}');
    AppLogger.debug('User email: ${currentUser?.email}');
    AppLogger.debug('User photo: ${currentUser?.photo}');

    if (mounted) {
      setState(() {
        _nameController.text = currentUser?.name ?? '';
        _phoneController.text = currentUser?.phone ?? '';
        _emailController.text = currentUser?.email ?? '';
      });
    }

    AppLogger.info('ProfileScreen initialized successfully');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Pick image from device
  Future<void> _pickImage() async {
    AppLogger.info('Gallery button pressed');
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        AppLogger.info('Image selected from gallery: ${pickedFile.name}');
        setState(() {
          _selectedImage = pickedFile;
          _errorMessage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo selected. Tap Update to save.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        AppLogger.info('Image selection cancelled');
      }
    } catch (e) {
      AppLogger.error('Error picking image: $e');
      _showError('Failed to pick image: $e');
    }
  }

  /// Take photo with camera
  Future<void> _takePhoto() async {
    AppLogger.info('Camera button pressed');

    // On Windows, camera is not supported
    if (Platform.isWindows) {
      AppLogger.warning('Camera not available on Windows platform');

      if (mounted) {
        // Show alert dialog with fallback option
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Not Available'),
            content: const Text(
              'Camera is not available on Windows.\n\nPlease use Gallery to select a photo from your device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(); // Auto-open gallery
                },
                child: const Text('Open Gallery'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // For other platforms, try camera
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening camera...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      AppLogger.info('Attempting to access camera via image_picker');

      // Wrap with timeout since camera might hang
      final pickedFile = await _imagePicker
          .pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
        requestFullMetadata: false,
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning('Camera picker timeout after 10 seconds');
          return null; // Return null on timeout
        },
      );

      if (pickedFile != null) {
        AppLogger.info('Photo captured successfully: ${pickedFile.name}');
        setState(() {
          _selectedImage = pickedFile;
          _errorMessage = null;
        });
      } else {
        AppLogger.info('Camera capture cancelled or timeout');
        // Show timeout dialog
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Camera Not Available'),
              content: const Text(
                'Camera is not available or timed out. Please use Gallery instead.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                  child: const Text('Open Gallery'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Camera error: $e');
      AppLogger.error('Error type: ${e.runtimeType}');

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Error'),
            content: const Text(
              'Unable to access camera. Please use Gallery instead.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage();
                },
                child: const Text('Open Gallery'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Build profile photo widget
  Widget _buildProfilePhoto(AuthProvider authProvider) {
    AppLogger.info('Building profile photo widget');
    AppLogger.info('Current user photo: ${authProvider.currentUser?.photo}');
    AppLogger.info('Selected image: $_selectedImage');

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primary,
          width: 3,
        ),
        color: Colors.grey[200],
      ),
      child: _selectedImage != null
          ? ClipOval(
              child: Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.cover,
              ),
            )
          : authProvider.currentUser?.photo != null &&
                  authProvider.currentUser!.photo!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    'http://127.0.0.1:8000${authProvider.currentUser!.photo}?t=${DateTime.now().millisecondsSinceEpoch}',
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    cacheHeight: 300,
                    errorBuilder: (context, error, stackTrace) {
                      AppLogger.error('Error loading network image: $error');
                      return const Center(
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: AppTheme.primary,
                  ),
                ),
    );
  }

  /// Handle profile update
  Future<void> _updateProfile() async {
    AppLogger.info('Update Profile button pressed');
    AppLogger.info(
        'Form data - Name: ${_nameController.text}, Phone: ${_phoneController.text}');
    AppLogger.info('Photo selected: ${_selectedImage != null ? 'Yes' : 'No'}');

    if (!mounted) return;

    // Validate inputs
    if (_nameController.text.isEmpty) {
      AppLogger.warning('Validation failed: Name is empty');
      _showError('Please enter your name');
      return;
    }

    if (_phoneController.text.isEmpty) {
      AppLogger.warning('Validation failed: Phone is empty');
      _showError('Please enter your phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      AppLogger.info('Calling authProvider.updateProfile()');
      final success = await authProvider.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        photoFile: _selectedImage != null ? File(_selectedImage!.path) : null,
      );

      if (!mounted) return;

      if (success) {
        AppLogger.info('Profile updated successfully');
        setState(() {
          _successMessage = 'Profile updated successfully!';
          _selectedImage = null;
        });

        // Show success message for 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        // Show the uploaded photo by calling setState to rebuild
        setState(() {
          _successMessage = null;
        });
      } else {
        final errorMsg = authProvider.error ?? 'Failed to update profile';
        AppLogger.error('Profile update failed: $errorMsg');
        _showError(errorMsg);
      }
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
      _showError('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error message
  void _showError(String message) {
    AppLogger.warning('Profile error: $message');
    setState(() {
      _errorMessage = message;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Ensure controllers are initialized with current user data
        if (_nameController.text.isEmpty && authProvider.currentUser != null) {
          _nameController.text = authProvider.currentUser?.name ?? '';
          _phoneController.text = authProvider.currentUser?.phone ?? '';
          _emailController.text = authProvider.currentUser?.email ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            elevation: 0,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Photo Section
                  Center(
                    child: Column(
                      children: [
                        // Photo display
                        _buildProfilePhoto(authProvider),
                        const SizedBox(height: AppTheme.spacingMd),
                        // Photo action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Success message
                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),

                  if (_errorMessage != null || _successMessage != null)
                    const SizedBox(height: AppTheme.spacingLg),

                  // Form Fields
                  TextField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  TextField(
                    controller: _phoneController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  TextField(
                    controller: _emailController,
                    enabled: false, // Email is read-only
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  // Update Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMd,
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
