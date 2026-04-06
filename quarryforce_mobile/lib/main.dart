import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'services/settings_service.dart';
import 'providers/auth_provider.dart';
import 'screens/root_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/feature_screens.dart' hide ProfileScreen;
import 'screens/customers_screen.dart';
import 'screens/add_customer_screen.dart';
import 'screens/orders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set platform-aware API URL (Android emulator uses 10.0.2.2, web uses localhost)
  AppConstants.apiBaseUrl = AppConstants.defaultApiUrl;

  // Initialize API service
  final apiService = ApiService.instance;
  await apiService.initialize();

  // Load settings from backend
  final settingsService = SettingsService();
  await settingsService.loadSettings();

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide API service to all widgets
        Provider<ApiService>.value(value: apiService),

        // Auth provider for managing login state
        ChangeNotifierProvider(
          create: (context) => AuthProvider(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: ThemeMode.light,
        home: const RootScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/visits': (context) => const VisitScreen(),
          '/customers': (context) => const CustomersScreen(),
          '/add-customer': (context) => const AddCustomerScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/fuel': (context) => const FuelScreen(),
          '/compensation': (context) => const CompensationScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
