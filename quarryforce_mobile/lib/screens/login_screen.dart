import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:io';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../utils/logger.dart';

/// Login Screen with device binding
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if available (for testing)
    _emailController.text = 'demo@quarryforce.local';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Validate inputs
    if (_emailController.text.isEmpty) {
      if (!mounted) return;
      _showError('Please enter your email');
      return;
    }

    // Attempt login with email
    final success = await authProvider.login(
      email: _emailController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to dashboard
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      if (!mounted) return;
      _showError(authProvider.error ?? 'Login failed. Please try again.');
    }
  }

  /// Show error dialog
  void _showError(String message) {
    if (!mounted) return;
    AppLogger.warning('Login error: $message');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                const SizedBox(height: AppTheme.spacingXl),
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'QF',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  'QuarryForce Tracker',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Field Sales Accountability',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: AppTheme.spacingXl * 1.5),

                // Login Form
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email address',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _handleLogin(),
                        ),

                        const SizedBox(height: AppTheme.spacingMd),

                        // Remember Me
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text('Remember me'),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spacingLg),

                        // Login Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return ElevatedButton(
                              onPressed:
                                  authProvider.isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingMd,
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppTheme.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: AppTheme.fontLg,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Device Info Section
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Device Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDeviceInfoRow(
                                'Device Type',
                                kIsWeb
                                    ? 'Web'
                                    : (Platform.isAndroid ? 'Android' : 'iOS'),
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              _buildDeviceInfoRow(
                                'Device UID',
                                authProvider.deviceUid?.substring(0, 8) ??
                                    '...',
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              const Text(
                                'This device will be bound to your account for security.',
                                style: TextStyle(
                                  fontSize: AppTheme.fontXs,
                                  color: AppTheme.gray,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Help Text
                const Text(
                  'Use admin credentials provided to your email',
                  style: TextStyle(
                    fontSize: AppTheme.fontXs,
                    color: AppTheme.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build device info row
  Widget _buildDeviceInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSm,
            color: AppTheme.gray,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.fontSm,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}
