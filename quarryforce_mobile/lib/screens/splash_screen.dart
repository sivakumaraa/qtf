import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../utils/logger.dart';

/// Splash screen shown during app startup
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Wait for auth provider to fully initialize
      await authProvider.waitForInitialization();

      if (!mounted) return;

      // Debug output
      final loggedIn = authProvider.isLoggedIn;
      final hasUser = authProvider.currentUser != null;
      final userId = authProvider.currentUser?.id;
      final userEmail = authProvider.currentUser?.email;

      AppLogger.divider('AUTH CHECK');
      AppLogger.debug('isLoggedIn: $loggedIn');
      AppLogger.debug('hasCurrentUser: $hasUser');
      AppLogger.debug('userId: $userId');
      AppLogger.debug('userEmail: $userEmail');
      AppLogger.debug('isInitialized: ${authProvider.isInitialized}');

      // Navigate based on login status
      if (loggedIn && hasUser) {
        AppLogger.info('ROUTING TO: /dashboard');
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        AppLogger.info('ROUTING TO: /login');
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      AppLogger.error('ERROR in _initializeApp', e);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo Placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.white.withValues(alpha: 0.9),
                ),
                child: const Center(
                  child: Text(
                    'QF',
                    style: TextStyle(
                      fontSize: AppTheme.font3Xl,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: AppTheme.font2Xl,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'v${AppConstants.appVersion}',
                style: TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 48),
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Initializing...',
                style: TextStyle(
                  fontSize: AppTheme.fontMd,
                  color: AppTheme.white,
                ),
              ),
              // DEBUG INFO - VISUAL DISPLAY
              const SizedBox(height: 48),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEBUG INFO:',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'isInitialized: ${authProvider.isInitialized}',
                          style: const TextStyle(
                              color: AppTheme.white, fontSize: 11),
                        ),
                        Text(
                          'isLoggedIn: ${authProvider.isLoggedIn}',
                          style: const TextStyle(
                              color: AppTheme.white, fontSize: 11),
                        ),
                        Text(
                          'hasUser: ${authProvider.currentUser != null}',
                          style: const TextStyle(
                              color: AppTheme.white, fontSize: 11),
                        ),
                        Text(
                          'userId: ${authProvider.currentUser?.id}',
                          style: const TextStyle(
                              color: AppTheme.white, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
