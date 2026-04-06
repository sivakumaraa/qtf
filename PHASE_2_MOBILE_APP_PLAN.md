# Phase 2: Mobile App Development (Flutter)

## Overview

Build a Flutter mobile app for field representatives to collect GPS location data, submit visits, fuel logs, take selfies, and view their compensation. The app will sync with the backend APIs created in Phase 1.

## Technology Stack

**Framework:** Flutter (Cross-platform for iOS & Android)
**Language:** Dart
**Backend:** Node.js Express API (localhost:3000 on development)
**Database:** MySQL (shared with admin dashboard)
**Maps:** Google Maps API for location
**Notifications:** Firebase Cloud Messaging
**Local Storage:** SQLite for offline-first capability
**HTTP Client:** Dio package

## Project Structure

```
quarryforce_mobile/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   ├── constants.dart           # API endpoints, app constants
│   │   └── theme.dart               # App styling, colors
│   ├── models/
│   │   ├── user.dart                # User/Rep model
│   │   ├── visit.dart               # Visit model
│   │   ├── fuel_log.dart            # Fuel log model
│   │   ├── location.dart            # GPS location model
│   │   └── compensation.dart        # Compensation model
│   ├── services/
│   │   ├── api_service.dart         # Backend API calls
│   │   ├── location_service.dart    # GPS tracking
│   │   ├── storage_service.dart     # Local SQLite
│   │   ├── auth_service.dart        # Login/logout
│   │   └── camera_service.dart      # Photo capture
│   ├── providers/
│   │   ├── auth_provider.dart       # State management for auth
│   │   ├── location_provider.dart   # State for GPS
│   │   ├── visit_provider.dart      # State for visits
│   │   └── compensation_provider.dart  # State for earnings
│   ├── screens/
│   │   ├── splash_screen.dart       # Loading screen
│   │   ├── login_screen.dart        # Login/device binding
│   │   ├── dashboard_screen.dart    # Main app view
│   │   ├── visit_screen.dart        # Start/end visit
│   │   ├── fuel_screen.dart         # Fuel entry
│   │   ├── expense_screen.dart      # Expense claims
│   │   ├── compensation_screen.dart # View compensation
│   │   ├── location_tracking_screen.dart  # Live GPS tracking
│   │   └── profile_screen.dart      # Rep profile
│   ├── widgets/
│   │   ├── custom_button.dart       # Reusable button
│   │   ├── custom_input.dart        # Reusable input field
│   │   ├── location_card.dart       # Location display card
│   │   ├── visit_card.dart          # Visit display card
│   │   └── app_bar.dart             # Custom app bar
│   └── utils/
│       ├── validators.dart          # Input validation
│       ├── formatters.dart          # Data formatting
│       └── logger.dart              # Debug logging
├── android/
│   └── app/src/main/AndroidManifest.xml  # Android permissions
├── ios/
│   └── Runner/Info.plist            # iOS permissions
├── pubspec.yaml                     # Dependencies
├── pubspec.lock                     # Locked versions
└── README.md                        # Setup instructions
```

## Core Features to Implement

### 1. Authentication & Device Binding

**Screens:** LoginScreen
**API Endpoints:**

- `POST /api/login` - Login with device UID binding
- `POST /api/admin/reset-device` - Admin can unbind device

**Features:**

- Login with username/password
- Automatic device UID generation
- Device binding verification
- Session management
- Logout with cleanup

### 2. Location Tracking

**Screens:** LocationTrackingScreen
**Services:** LocationService, GeoLocationProvider
**Features:**

- Real-time GPS tracking
- Background location updates
- Geofencing for quarry locations
- Track visited customer locations
- Calculate distance between points
- Store location history locally

### 3. Visit Management

**Screens:** VisitScreen
**API Endpoints:**

- `POST /api/visit/submit` - Submit visit data
- `GET /api/admin/customers` - Get customer list

**Features:**

- Start visit at customer location
- Select customer from dropdown
- Auto-capture GPS location
- Take selfie at customer site
- Add notes/observations
- End visit
- Submit all data to backend
- Offline queue for failed submissions

### 4. Fuel Logging

**Screens:** FuelScreen
**API Endpoints:**

- `POST /api/fuel/submit` - Submit fuel expense

**Features:**

- Enter fuel quantity (liters)
- Capture fuel receipt photo
- Enter fuel cost
- Select fuel type (petrol/diesel)
- GPS location auto-capture
- Attach pump receipt
- Submit to backend

### 5. Expense Claims

**Screens:** ExpenseScreen
**Features:**

- Enter expense amount
- Select expense category (food, toll, repair, etc.)
- Add receipt photo
- Add notes
- Queue for monthly reimbursement
- View approval status

### 6. Compensation Tracking

**Screens:** CompensationScreen
**API Endpoints:**

- `GET /api/admin/rep-progress/:rep_id` - Get monthly earnings
- `GET /api/admin/rep-targets/:rep_id` - Get sales target

**Features:**

- View monthly sales target
- Track current sales volume
- See bonus calculation in real-time
- View penalty information
- See net compensation
- Monthly breakdown chart
- Compare against previous months

### 7. Dashboard

**Screens:** DashboardScreen
**Features:**

- Welcome message with rep name
- Today's stats (visits, distance, fuel)
- Quick action buttons (New Visit, Log Fuel, View Compensation)
- Pending submissions counter
- Connection status indicator
- Last sync time display

### 8. Profile & Settings

**Screens:** ProfileScreen
**Features:**

- View rep profile details
- View assigned targets
- App version info
- Manual sync option
- Clear local cache
- Logout

## API Integration Checklist

Backend endpoints used by mobile app:

### Authentication (1 endpoint)

- [ ] `POST /api/login` - Login with device binding

### Data Submission (3 endpoints)

- [ ] `POST /api/checkin` - Device checkin
- [ ] `POST /api/visit/submit` - Submit visit with GPS & photo
- [ ] `POST /api/fuel/submit` - Submit fuel log

### Data Retrieval (3 endpoints)

- [ ] `GET /api/admin/reps` - Get all reps
- [ ] `GET /api/admin/customers` - Get customers for visit targeting
- [ ] `GET /api/admin/rep-targets/:rep_id` - Get sales targets

### Compensation (2 endpoints)

- [ ] `GET /api/admin/rep-progress/:rep_id` - Get earnings
- [ ] `POST /api/admin/rep-progress/update` - Record sales (indirect via rep dashboard)

**Total APIs needed:** 9 endpoints ✓ (All already exist in backend)

## Development Phases

### Phase 2a: Core Setup (Week 1)

1. Create Flutter project structure
2. Configure packages and dependencies
3. Setup API service with Dio
4. Implement authentication/login screen
5. Create local storage (SQLite)
6. Build basic navigation

### Phase 2b: Location & Tracking (Week 2)

1. Integrate Google Maps
2. Implement GPS tracking service
3. Build location tracking UI
4. Add geofencing for quarries
5. Test location accuracy

### Phase 2c: Visit & Fuel Features (Week 2-3)

1. Build visit submission flow
2. Implement photo capture (selfies, receipts)
3. Create fuel logging screen
4. Add expense tracking
5. Implement offline queueing

### Phase 2d: Compensation View (Week 3)

1. Build compensation tracking screen
2. Display target vs achieved
3. Show bonus/penalty calculations
4. Add monthly breakdown
5. Create performance charts

### Phase 2e: Testing & Polish (Week 4)

1. Test all API integrations
2. Test offline functionality
3. Performance optimization
4. UI/UX refinement
5. Build APK/IPA for deployment

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.0.0 # HTTP client
  google_maps_flutter: ^2.2.0 # Maps
  location: ^4.4.0 # GPS
  image_picker: ^0.8.5 # Photo capture
  sqflite: ^2.1.0 # Local database
  provider: ^6.0.0 # State management
  intl: ^0.18.0 # Date formatting
  uuid: ^3.0.7 # Device UID
  shared_preferences: ^2.0.15 # Quick storage
  camera: ^0.10.0 # Camera for selfies
  path_provider: ^2.0.11 # File paths
  connectivity_plus: ^3.0.2 # Network status
  firebase_messaging: ^13.0.0 # Push notifications
  charts_flutter: ^0.10.0 # Performance charts
```

## Key Implementation Details

### Device Binding (Security)

```dart
// Generate unique device identifier
String deviceUID = const Uuid().v4();
// Store securely in device
// Send to backend on login
// Backend prevents multiple device logins for same rep
```

### Offline-First Architecture

```dart
// All submissions queued locally first
// When online, sync queue to backend
// Mark as synced after confirmation
// Allow viewing local data while offline
```

### GPS Tracking

```dart
// Continuous background location tracking
// Update every 30 seconds
// Store in local SQLite
// Submit with visit/fuel data
```

### Photo Capture for Verification

```dart
// Each visit requires selfie at customer location
// GPS location verified with photo timestamp
// Device UID embedded in photo metadata
// Prevents fake GPS + old photo combinations
```

## Testing Strategy

### Backend Testing

- [ ] Test all 9 API endpoints with mobile payloads
- [ ] Verify device binding enforcement
- [ ] Test offline sync scenarios
- [ ] Validate GPS data storage

### Mobile Testing

- [ ] Emulator testing (Android)
- [ ] Physical device testing
- [ ] Offline functionality
- [ ] GPS accuracy in different locations
- [ ] Photo capture and sync
- [ ] Battery consumption monitoring

### Integration Testing

- [ ] End-to-end visit submission
- [ ] Compensation calculation from mobile data
- [ ] Admin dashboard display of mobile data
- [ ] Real data flowing: Mobile → Backend → Admin Dashboard

## Success Criteria

- ✓ Mobile app builds and runs on iOS/Android
- ✓ Login with device binding works
- ✓ GPS tracking functional
- ✓ Visit submission with photo works
- ✓ Fuel logging works
- ✓ Offline queue system operational
- ✓ Compensation displayed correctly
- ✓ Backend receives all mobile data
- ✓ Admin dashboard displays mobile data
- ✓ Full pipeline: Mobile → API → Admin Dashboard

## Next Steps

1. ✅ Phase 1: Admin Dashboard - COMPLETE
2. 🔄 Phase 2: Mobile App - START HERE (Flutter setup)
3. ⏳ Phase 3: Fraud Detection Enhancement
4. ⏳ Phase 4: Production Deployment
5. ⏳ Phase 5: Advanced Analytics

## Deployment

**Development:**

- Run on local emulator
- Connect to localhost:3000 backend
- Use mock GPS for initial testing

**Testing:**

- Build APK for Android testing
- Build IPA for iOS testing
- Test with real backend

**Production:**

- Update API endpoints to production server
- Sign and distribute on Google Play & App Store
- Configure production database

---

**Ready to start Phase 2?** Let me know and we'll initialize the Flutter project and start building the mobile app!
