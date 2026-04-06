import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/logger.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

/// Root screen that handles authentication routing
class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure initialization completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.waitForInitialization();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show splash while initializing
        if (!authProvider.isInitialized) {
          return const SplashScreen();
        }

        // After initialization, show appropriate screen
        if (authProvider.isLoggedIn && authProvider.currentUser != null) {
          // User is logged in - show dashboard
          AppLogger.debug(
              'ROOT: Showing DASHBOARD (isLoggedIn=${authProvider.isLoggedIn}, userId=${authProvider.currentUser?.id})');
          return const DashboardScreen();
        } else {
          // User is NOT logged in - show login
          AppLogger.debug(
              'ROOT: Showing LOGIN SCREEN (isLoggedIn=${authProvider.isLoggedIn}, user=${authProvider.currentUser})');
          return const LoginScreen();
        }
      },
    );
  }
}
