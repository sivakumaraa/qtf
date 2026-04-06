# QuarryForce Tracker - Mobile App

## Phase 2a: Core Setup Complete ✅

A Flutter-based mobile application for field representatives to track sales, manage GPS locations, submit visits, and monitor compensation in real-time.

## Project Status

### ✅ Completed (Step 1-3)

**Step 1: Project Structure** - COMPLETE

- Organized directory structure with:
  - `lib/config/` - Constants and theme configuration
  - `lib/models/` - Data models
  - `lib/services/` - API and platform services
  - `lib/providers/` - State management
  - `lib/screens/` - UI screens
  - `lib/widgets/` - Reusable components
  - `lib/utils/` - Helper utilities
  - `android/` and `ios/` - Platform-specific code

**Step 2: Dependencies Configuration** - COMPLETE

- `pubspec.yaml` with all required packages:
  - **HTTP**: Dio for API calls
  - **GPS**: Location, Geolocator, Google Maps
  - **Camera**: Image picker, Camera
  - **Database**: SQLite for offline storage
  - **State**: Provider for state management
  - **Storage**: Shared preferences
  - **Other**: UUID, Intl, Connectivity, Firebase

**Step 3: API Service Setup** - COMPLETE

- Dio configured with:
  - Base URL: `http://10.0.2.2:3000` (Android emulator)
  - Request/response logging
  - Error handling
  - Token management
  - Interceptors for auth headers
- API methods for:
  - Login (device binding)
  - Check-in
  - Visit submission
  - Fuel logging
  - Data retrieval (reps, customers, targets, progress)
- Error handling with user-friendly messages

## File Structure

```
quarryforce_mobile/
├── lib/
│   ├── config/
│   │   ├── constants.dart         ✅ API endpoints & app constants
│   │   └── theme.dart              ✅ App theming & colors
│   ├── models/
│   │   └── models.dart             ✅ User, Customer, Visit, Fuel, Target, Compensation
│   ├── services/
│   │   └── api_service.dart        ✅ Dio client with all 9 API endpoints
│   ├── providers/
│   │   ├── auth_provider.dart      (Coming)
│   │   ├── location_provider.dart  (Coming)
│   │   ├── visit_provider.dart     (Coming)
│   │   └── compensation_provider.dart  (Coming)
│   ├── screens/
│   │   ├── splash_screen.dart      ✅ Loading screen
│   │   ├── login_screen.dart       (Coming)
│   │   ├── dashboard_screen.dart   (Coming)
│   │   ├── visit_screen.dart       (Coming)
│   │   ├── fuel_screen.dart        (Coming)
│   │   ├── compensation_screen.dart (Coming)
│   │   └── location_tracking_screen.dart (Coming)
│   ├── widgets/
│   │   ├── custom_button.dart      (Coming)
│   │   └── custom_input.dart       (Coming)
│   ├── utils/
│   │   ├── validators.dart         (Coming)
│   │   └── formatters.dart         (Coming)
│   └── main.dart                   ✅ App entry point
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml     (Needs permissions)
├── ios/
│   └── Runner/
│       └── Info.plist              (Needs permissions)
├── pubspec.yaml                    ✅ Dependencies configured
├── pubspec.lock                    (Auto-generated)
└── README.md                       (This file)
```

## Technology Stack

- **Framework**: Flutter (3.x+)
- **Language**: Dart 3.0+
- **State Management**: Provider
- **HTTP Client**: Dio (v5.0)
- **Location**: Location, Geolocator
- **Maps**: Google Maps Flutter
- **Database**: SQLite
- **Storage**: Shared Preferences
- **Camera**: Image Picker, Camera
- **Backend**: Node.js Express (localhost:3000)

## API Integration

The app connects to 9 backend endpoints:

### Authentication (1)

- `POST /api/login` - Device binding & login

### Submission (2)

- `POST /api/visit/submit` - Submit visits with GPS & photos
- `POST /api/fuel/submit` - Submit fuel logs

### Data Sync (3)

- `GET /api/admin/reps` - List of representatives
- `GET /api/admin/customers` - Customer/quarry list
- `GET /api/admin/rep-targets/:rep_id` - Sales target

### Progress (1)

- `GET /api/admin/rep-progress/:rep_id` - Monthly earnings

### Check-in (1)

- `POST /api/checkin` - Device check-in

### Settings (1)

- `GET /api/settings` - App configuration

## Configuration

### API Base URL

Default: `http://10.0.2.2:3000` (Android emulator)

**To change for different environments:**

- Android physical device: `http://192.168.x.x:3000`
- iOS emulator: `http://localhost:3000`
- Production: `https://your-api-domain.com`

Edit in `lib/config/constants.dart`:

```dart
static const String API_BASE_URL = 'http://10.0.2.2:3000';
```

## Installation

### Prerequisites

- Flutter SDK (3.0+) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- Android Studio or Xcode (for emulator)
- Device with Android/iOS support

### Setup Steps

1. **Navigate to project directory:**

```bash
cd quarryforce_mobile
```

2. **Get Flutter packages:**

```bash
flutter pub get
```

3. **Run on Android emulator:**

```bash
flutter run -d emulator-5554
```

4. **Run on iOS emulator:**

```bash
flutter run -d iphone
```

5. **Run on physical device:**

```bash
flutter run
```

## Development

### Project Structure

- **Models**: Data classes with JSON serialization
- **Services**: API calls and platform integration
- **Providers**: State management for app state
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components

### API Service Usage

```dart
// Get API service from provider
final apiService = Provider.of<ApiService>(context, listen: false);

// Login
try {
  final result = await apiService.login(
    username: 'rajesh',
    password: 'pass123',
    deviceUid: 'device-uuid',
    deviceType: 'android',
    deviceModel: 'Samsung Galaxy S21',
  );
  print('Login successful: ${result['message']}');
} catch (e) {
  print('Login failed: $e');
}

// Get customers
try {
  final customers = await apiService.getAllCustomers();
  // customers is List<Map<String, dynamic>>
} catch (e) {
  print('Error: $e');
}

// Submit visit
try {
  final result = await apiService.submitVisit(
    repId: userId,
    customerId: selectedCustomId,
    latitude: 28.7041,
    longitude: 77.1025,
    visitPhotoPath: 'path/to/photo.jpg',
    selfiePath: 'path/to/selfie.jpg',
    startTime: DateTime.now().subtract(Duration(minutes: 15)),
    endTime: DateTime.now(),
    notes: 'Customer interested in bulk order',
    deviceUid: deviceUid,
  );
} catch (e) {
  print('Error: $e');
}
```

### Error Handling

All API calls include automatic error handling with user-friendly messages:

- Network errors
- Timeout errors
- Server errors (500, 503)
- Unauthorized (401)
- Bad request (400)

## Next Steps (Phase 2b: Location & Tracking)

1. **Authentication Screen**
   - Login UI with device binding
   - Username/password validation
   - Device information capture

2. **Location Service**
   - GPS permission handling
   - Background location tracking
   - Accuracy validation

3. **Navigation Framework**
   - Provider-based state management
   - Named routes
   - Screen transitions

## Testing

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test --verbose
```

### Integration Tests

```bash
flutter test integration_test/
```

### API Testing

1. Ensure backend is running on localhost:3000
2. Check backend is responsive: `curl http://localhost:3000/`
3. Run app in emulator to test API calls

## Debugging

### View logs

```bash
flutter logs
```

### Run in debug mode

```bash
flutter run
```

### Run with verbose output

```bash
flutter run -v
```

### Performance profiling

```bash
flutter run --profile
```

## Permissions (Android & iOS)

The app requires these permissions:

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Camera -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Network -->
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track visits and sales activities.</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture customer visit photos.</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library.</string>
```

## Build

### Build APK (Android)

```bash
flutter build apk --release
```

### Build App Bundle (Android Play Store)

```bash
flutter build appbundle --release
```

### Build IPA (iOS)

```bash
flutter build ios --release
```

## Deployment

### Development

- Run on emulator with localhost backend
- Use test data and endpoints

### Testing

- Build APK/IPA
- Test on physical devices
- Test on different network conditions
- Test offline functionality

### Production

- Update API endpoints to production server
- Configure Firebase (if using)
- Sign APK with release key
- Configure app signing
- Deploy to Google Play & App Store

## Troubleshooting

### Connection Issues

- Ensure backend is running: `node index.js`
- Check API base URL in `constants.dart`
- Verify network connectivity

### Permission Issues

- Grant permissions through app settings
- Check manifest/plist configuration
- Use `permission_handler` package for runtime requests

### Build Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Dependencies

Core packages used:

- **provider** (^6.0.0) - State management
- **dio** (^5.0.0) - HTTP client
- **location** (^4.4.0) - GPS access
- **image_picker** (^0.8.7) - Photo selection
- **sqflite** (^2.2.7) - Local database
- **google_maps_flutter** (^2.2.0) - Maps integration

## Contributing

Follow these guidelines for new code:

1. Use meaningful variable and function names
2. Add comments for complex logic
3. Test API calls manually before committing
4. Update models when API response changes

## Support

For issues or questions:

1. Check backend logs: `node index.js`
2. Review API endpoints in `api_service.dart`
3. Check constants in `config/constants.dart`
4. Review backend documentation: `SYSTEM_ARCHITECTURE_GUIDE.md`

## Timeline

- **Phase 2a**: Core Setup ✅ (COMPLETE)
- **Phase 2b**: Location & Tracking (Starting next)
- **Phase 2c**: Visit & Fuel Features (Week 2-3)
- **Phase 2d**: Compensation View (Week 3)
- **Phase 2e**: Testing & Polish (Week 4)

---

**Status**: Phase 2a (Core Setup) COMPLETE ✅

**Next**: Phase 2b - Implement authentication and location tracking
