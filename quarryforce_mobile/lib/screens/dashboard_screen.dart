import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../utils/logger.dart';

/// Main Dashboard Screen - Showing reps quick actions and stats
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocationService _locationService = LocationService();
  int _selectedIndex = 0;
  final int _todayVisits = 0;
  double _todayDistance = 0.0;
  SalesTarget? _currentTarget;
  Compensation? _currentCompensation;
  bool _isLoadingTarget = true;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  /// Initialize dashboard
  Future<void> _initializeDashboard() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    AppLogger.divider('DASHBOARD INIT');
    AppLogger.debug('isLoggedIn: ${authProvider.isLoggedIn}');
    AppLogger.debug('currentUser: ${authProvider.currentUser}');

    // Security check: Redirect to login if not authenticated
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      AppLogger.warning(
          'DASHBOARD: User not authenticated, redirecting to login');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    AppLogger.info('DASHBOARD: User authenticated, proceeding');

    // Perform check-in
    await authProvider.checkIn();

    // Load target and compensation data
    _loadTargetData(authProvider);

    // Fetch and apply server-side GPS settings
    try {
      final apiService = ApiService.instance;
      final settings = await apiService.getSettings();

      if (settings.isNotEmpty) {
        final gpsUpdateInterval =
            settings['gps_update_interval'] ?? AppConstants.gpsUpdateInterval;
        final gpsMinDistance =
            settings['gps_min_distance'] ?? AppConstants.gpsMinDistance;

        AppLogger.info('Fetched GPS settings from server:');
        AppLogger.debug('  - Update interval: ${gpsUpdateInterval}ms');
        AppLogger.debug('  - Min distance: ${gpsMinDistance}m');

        _locationService.updateGPSSettings(
          updateIntervalMs: gpsUpdateInterval,
          minDistanceM: gpsMinDistance,
        );
      }
    } catch (e) {
      AppLogger.error('Failed to fetch GPS settings: $e');
      // Continue with default settings if fetch fails
    }

    // Initialize location service (only on Android/iOS, skip on web/windows/macos)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      AppLogger.info('Initializing location service on mobile platform');
      final hasPermission = await _locationService.initialize();
      if (hasPermission) {
        AppLogger.info('Location permission granted, starting GPS tracking');
        // Start location tracking
        _locationService.startTracking(
          onLocationChanged: (location) {
            if (mounted) {
              setState(() {
                _todayDistance = _locationService.getDistanceTraveled();
              });
            }
          },
        );
      } else {
        AppLogger.warning('Location permission denied or service unavailable');
      }
    } else {
      AppLogger.info(
          'Skipping GPS tracking: kIsWeb=$kIsWeb, Android=${Platform.isAndroid}, iOS=${Platform.isIOS}');
    }
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on selected index
    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        Navigator.pushNamed(context, '/visits');
        break;
      case 2:
        Navigator.pushNamed(context, '/customers');
        break;
      case 3:
        Navigator.pushNamed(context, '/orders');
        break;
      case 4:
        Navigator.pushNamed(context, '/fuel');
        break;
      case 5:
        Navigator.pushNamed(context, '/compensation');
        break;
      case 6:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Future<void> _loadTargetData(AuthProvider authProvider) async {
    if (authProvider.currentUser?.id == null) {
      setState(() => _isLoadingTarget = false);
      return;
    }

    try {
      final apiService = ApiService.instance;

      final targetData = await apiService.getRepTarget(
        authProvider.currentUser!.id!,
      );
      final progressData = await apiService.getRepProgress(
        authProvider.currentUser!.id!,
      );

      if (mounted) {
        setState(() {
          _currentTarget = SalesTarget.fromJson(targetData);
          _currentCompensation = Compensation.fromJson(progressData);
          _isLoadingTarget = false;
        });
      }
    } catch (e) {
      AppLogger.debug('Failed to load target data: $e');
      if (mounted) {
        setState(() => _isLoadingTarget = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Logout button
          Consumer<AuthProvider>(
            builder: (builderContext, authProvider, _) {
              return PopupMenuButton(
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutDialog(authProvider);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                children: [
                  // Welcome Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            authProvider.currentUser?.name ??
                                authProvider.currentUser?.username ??
                                'User',
                            style: const TextStyle(
                              fontSize: AppTheme.font2Xl,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            'Rep ID: ${authProvider.currentUser?.id ?? '-'}',
                            style: TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Target Summary Card
                  if (_isLoadingTarget)
                    const Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          height: 80,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    )
                  else if (_currentTarget != null &&
                      _currentCompensation != null)
                    _buildTargetSummaryCard(
                        _currentTarget!, _currentCompensation!)
                  else
                    const SizedBox.shrink(),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Today's Stats
                  _buildStatsSection(),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Location Status
                  _buildLocationStatus(),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Quick Actions
                  _buildQuickActions(),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Device Info
                  _buildDeviceInfo(authProvider),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Visits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: 'Fuel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Compensation',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  /// Build today's statistics
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Activity", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                label: 'Visits',
                value: _todayVisits.toString(),
                color: AppTheme.info,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _buildStatCard(
                icon: Icons.directions_walk,
                label: 'Distance',
                value: '${(_todayDistance / 1000).toStringAsFixed(1)} km',
                color: AppTheme.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build target summary card for dashboard
  Widget _buildTargetSummaryCard(
      SalesTarget target, Compensation compensation) {
    final targetM3 = target.monthlySalesTargetM3 ?? 0;
    final achievedM3 = compensation.salesVolumeM3 ?? 0;
    final achievementPercent = targetM3 > 0 ? (achievedM3 / targetM3 * 100) : 0;
    final isOnTrack = achievementPercent >= 100;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isOnTrack
                ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                : [const Color(0xFFFFA726), const Color(0xFFF57C00)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Target',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/compensation'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:
                    achievementPercent > 100 ? 1.0 : achievementPercent / 100,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Achievement percentage and metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${achievementPercent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Achievement',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${achievedM3.toStringAsFixed(1)} / ${targetM3.toStringAsFixed(1)} m³',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Sold / Target',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Earnings info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Earnings: ₹${(compensation.netCompensation ?? 0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOnTrack
                        ? Colors.green[700]?.withValues(alpha: 0.5)
                        : Colors.orange[700]?.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOnTrack ? 'ON TRACK ✓' : 'NEEDS BOOST',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSm,
                color: AppTheme.gray,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              value,
              style: TextStyle(
                fontSize: AppTheme.fontXl,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build location status
  Widget _buildLocationStatus() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gps_fixed, color: AppTheme.success),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'GPS Tracking',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: _locationService.isTracking
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    _locationService.isTracking ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: AppTheme.fontXs,
                      fontWeight: FontWeight.bold,
                      color: _locationService.isTracking
                          ? AppTheme.success
                          : AppTheme.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Real-time location tracking is ${_locationService.isTracking ? 'active' : 'inactive'}',
              style: const TextStyle(
                fontSize: AppTheme.fontSm,
                color: AppTheme.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick action buttons
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingMd),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          children: [
            _buildActionButton(
              icon: Icons.add_location,
              label: 'Start Visit',
              color: AppTheme.primary,
              onTap: () {
                if (mounted) Navigator.pushNamed(context, '/visits');
              },
            ),
            _buildActionButton(
              icon: Icons.local_gas_station,
              label: 'Log Fuel',
              color: AppTheme.warning,
              onTap: () {
                if (mounted) Navigator.pushNamed(context, '/fuel');
              },
            ),
            _buildActionButton(
              icon: Icons.attach_money,
              label: 'View Earnings',
              color: AppTheme.success,
              onTap: () {
                if (mounted) Navigator.pushNamed(context, '/compensation');
              },
            ),
            _buildActionButton(
              icon: Icons.info,
              label: 'More',
              color: AppTheme.info,
              onTap: () {
                if (mounted) Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTheme.fontSm,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build device info
  Widget _buildDeviceInfo(AuthProvider authProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildDeviceRow(
              'Device UID',
              authProvider.deviceUid?.substring(0, 8) ?? '--',
            ),
            _buildDeviceRow('AppVersion', AppConstants.appVersion),
            const SizedBox(height: AppTheme.spacingMd),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () async {
                  if (!mounted) return;
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    if (!mounted) return;
                    await authProvider.logout();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(AuthProvider authProvider) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await authProvider.logout();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Build device info row
  Widget _buildDeviceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: AppTheme.fontSm, color: AppTheme.gray),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTheme.fontSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
