# Phase 4.1: Rep Login & Live Location Tracking - Implementation Guide

**Date:** March 14, 2026  
**Status:** Implementation Ready  
**Priority:** High - Core Functionality

---

## 📋 Overview

This phase implements two critical features:

1. **One-Time Device Binding** - Secure device identification on first login
2. **Live Location Tracking** - Real-time rep location updates visible on admin dashboard

---

## 📦 Files Created/Modified

### Backend (PHP)

| File                              | Purpose                                         | Status     |
| --------------------------------- | ----------------------------------------------- | ---------- |
| `PHASE_4_LOCATION_MIGRATION.sql`  | Database schema for locations & device binding  | ✅ Created |
| `qft-deployment/api_location.php` | API endpoints for login, location, and tracking | ✅ Created |

### Mobile (Flutter)

| File                                 | Purpose                                 | Status                   |
| ------------------------------------ | --------------------------------------- | ------------------------ |
| `lib/services/device_service.dart`   | Device identification & secure storage  | ✅ Created               |
| `lib/services/auth_service.dart`     | JWT authentication & session management | ✅ Created               |
| `lib/services/location_service.dart` | Continuous GPS tracking & syncing       | ⚠️ Needs Update          |
| `lib/screens/login_screen.dart`      | Rep login UI with device binding        | ⚠️ Exists (needs update) |

### Frontend (React)

| File                                         | Purpose                      | Status     |
| -------------------------------------------- | ---------------------------- | ---------- |
| `admin-dashboard/src/pages/RepLocations.jsx` | Live map & rep location list | ✅ Created |

---

## 🔧 Implementation Steps

### Step 1: Database Setup (5 minutes)

**Location:** `PHASE_4_LOCATION_MIGRATION.sql`

```bash
# Run this SQL migration on your MySQL server
mysql -u quarryforce -p quarryforce < PHASE_4_LOCATION_MIGRATION.sql
```

**What it does:**

- Adds `device_uid`, `device_bound`, `last_login` columns to `users` table
- Creates `live_locations` table (stores latest location per rep)
- Creates `location_history` table (archives all locations for analytics)
- Creates `device_bind_log` table (audit trail for device binding)
- Creates `location_access_log` table (audit trail for admin access)

**Verification:**

```sql
-- Check if migration was successful
SELECT COUNT(*) as users_count FROM users;
SELECT * FROM live_locations LIMIT 1;
SELECT * FROM device_bind_log LIMIT 1;
```

---

### Step 2: Update PHP API (10 minutes)

**Location:** `qft-deployment/api_location.php`

**Key Endpoints:**

#### `POST /login?action=login`

- Email & password authentication
- One-time device binding via `device_uid`
- Returns JWT token for subsequent requests
- Logs device binding events

**Request:**

```json
{
  "email": "rep@example.com",
  "password": "password123",
  "device_uid": "auto-generated-or-existing",
  "device_model": "SM-G991B (optional)"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "rep@example.com",
      "role": "Rep",
      "device_uid": "550e8400-e29b-41d4-a716-446655440000"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "device_status": "new_binding",
    "expires_in": 86400
  }
}
```

#### `POST /api/location/update?action=location_update`

- Called every 30 seconds by mobile app
- Requires JWT token in Authorization header
- Stores latest location in `live_locations` table
- Archives to `location_history` for analytics

**Request:**

```bash
# With Authorization header
curl -X POST 'https://api.example.com/api/location/update?action=location_update' \
  -H 'Authorization: Bearer <JWT_TOKEN>' \
  -F 'lat=28.6139' \
  -F 'lng=77.2090' \
  -F 'accuracy=15.5' \
  -F 'timestamp=2026-03-14T10:30:45Z'
```

#### `GET /api/reps/locations?action=reps_locations`

- Admin only: fetches all rep locations
- Called every 10 seconds by admin dashboard
- Returns latest location for each active rep

**Response:**

```json
{
  "success": true,
  "data": {
    "total_reps": 5,
    "online_count": 3,
    "offline_count": 2,
    "locations": [
      {
        "rep_id": 1,
        "name": "John Doe",
        "lat": 28.6139,
        "lng": 77.209,
        "accuracy": 15.5,
        "timestamp": "2026-03-14T10:30:45Z",
        "minutes_ago": 0,
        "status": "online"
      }
    ]
  }
}
```

**Integration:**

- Copy `api_location.php` to your `qft-deployment/` folder
- Update the API base URL in your frontend/mobile apps
- Ensure `.htaccess` routing works with new endpoints

---

### Step 3: Flutter Mobile App Setup (15 minutes)

#### 3A. Update `pubspec.yaml`

Add these dependencies (if not already present):

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Existing
  dio: ^5.3.0
  flutter_secure_storage: ^9.0.0
  sqflite: ^2.3.0

  # New/Updated for location
  geolocator: ^9.0.0
  device_info_plus: ^10.0.0
  uuid: ^4.0.0
  work_manager: ^0.9.0 # For background tasks

dev_dependencies:
  flutter_test:
    sdk: flutter
```

**Install:**

```bash
cd quarryforce_mobile
flutter pub get
```

#### 3B. Update `AndroidManifest.xml`

Add location permissions:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### 3C. Update `Info.plist` (iOS)

Add location permissions:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>QuarryForce needs your location to track field activities</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>QuarryForce needs your location for continuous tracking</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>QuarryForce needs your location for background tracking</string>
```

#### 3D. Update `main.dart`

Initialize services on app startup:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final database = await openDatabase(
    join(await getDatabasesPath(), 'quarryforce.db'),
    onCreate: (db, version) async {
      await db.execute(
        '''CREATE TABLE local_locations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lat REAL NOT NULL,
          lng REAL NOT NULL,
          accuracy REAL,
          timestamp TEXT NOT NULL,
          synced INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )''',
      );
    },
    version: 1,
  );

  // Initialize auth service
  authService.initialize('https://your-api.com/');

  // Initialize location service
  await locationService.initialize(database);

  runApp(QuarryForceApp(database: database));
}
```

#### 3E. Link Providers to Services

Update your login flow to use the new services:

```dart
// In login_screen.dart
final AuthService _authService = AuthService();
final LocationService _locationService = LocationService();
final DeviceService _deviceService = DeviceService();

// On login success
bool success = await _authService.login(email, password);
if (success) {
  await _locationService.startTracking();
  _navigateToHome();
}

// On logout
await _authService.logout();
await _locationService.stopTracking();
```

---

### Step 4: React Admin Dashboard (10 minutes)

#### 4A. Add Route

Update `src/App.jsx` or router configuration:

```jsx
import RepLocations from "./pages/RepLocations";

// Add route
<Route path="/rep-locations" element={<RepLocations />} />;
```

#### 4B. Add Navigation Menu

Update sidebar/navigation:

```jsx
<NavLink to="/rep-locations" className="nav-item">
  <MapPin className="w-4 h-4" />
  Rep Locations
</NavLink>
```

#### 4C. Verify Node Packages

Ensure you have Leaflet installed:

```bash
cd admin-dashboard
npm install leaflet react-leaflet
```

---

## 🔐 Security Considerations

### Device Binding

- ✅ One-time binding per device
- ✅ Device UUID stored securely in encrypted storage (Flutter)
- ✅ Device mismatch detection (prevents multi-device login)
- ✅ Audit trail in `device_bind_log` table

### JWT Token

- ✅ 24-hour expiration
- ✅ Signed with secret key
- ✅ Includes device_uid for additional verification
- ✅ Stored in secure storage (not SharedPreferences)

### Location Data

- ✅ Requires JWT token authentication
- ✅ Admin-only access to all locations
- ✅ Reps can only access their own location
- ✅ Access logged in `location_access_log` table

### Communication

- ✅ HTTPS required (set in config)
- ✅ Device ID verification on backend
- ✅ Server-side validation of coordinates

---

## 🧪 Testing Checklist

### Backend Testing

```bash
# 1. Test login endpoint
curl -X POST 'http://localhost/login?action=login' \
  -d 'email=test.rep@quarryforce.com&password=password123&device_uid='

# 2. Test location update
curl -X POST 'http://localhost/api/location/update?action=location_update' \
  -H 'Authorization: Bearer <TOKEN>' \
  -F 'lat=28.6139' -F 'lng=77.2090' -F 'accuracy=15.5'

# 3. Test fetch all locations
curl -X GET 'http://localhost/api/reps/locations?action=reps_locations' \
  -H 'Authorization: Bearer <TOKEN>'
```

### Mobile Testing

- [ ] Login with email/password (first time)
- [ ] Verify device_uid is generated and stored
- [ ] Check location permission is granted
- [ ] Confirm location updates every 30 seconds
- [ ] Verify offline queue stores location when offline
- [ ] Check location syncing when coming online
- [ ] Logout and verify session is cleared
- [ ] Second login with same device (should use same device_uid)

### Admin Dashboard Testing

- [ ] Navigate to Rep Locations page
- [ ] Verify map loads with markers
- [ ] Check location list updates every 10 seconds
- [ ] Confirm online/offline status is correct
- [ ] Test filter by online/offline
- [ ] Verify accuracy and timestamp display
- [ ] Check for any performance issues with large datasets

---

## 📊 Database Schema

### live_locations Table

```sql
id (PK) | rep_id (FK) | lat | lng | accuracy | timestamp | synced | created_at
```

- **Purpose:** Store latest location for each rep
- **Updates:** Replaced on each new location update
- **Used by:** Admin dashboard (every 10 seconds)

### location_history Table

```sql
id (PK) | rep_id (FK) | lat | lng | accuracy | timestamp | date_key | created_at
```

- **Purpose:** Archive all location history for analytics
- **Records:** Every 30 seconds per rep
- **Used by:** Analytics, reports, path visualization

### device_bind_log Table

```sql
id (PK) | user_id (FK) | device_uid | device_model | bind_status | ip_address | user_agent | timestamp
```

- **Purpose:** Audit trail for device binding
- **Records:** On every login attempt
- **Used by:** Security audits, device verification

### location_access_log Table

```sql
id (PK) | admin_id (FK) | rep_id (FK) | access_type | timestamp | ip_address
```

- **Purpose:** Audit trail for location data access
- **Records:** When admin views locations
- **Used by:** Privacy compliance, access audits

---

## 🔍 Troubleshooting

### Issue: Device Mismatch Error on Second Login

**Cause:** Different device or cleared app data  
**Solution:** Clear app data and re-login, or contact admin for device rebinding

### Issue: Location Not Updating on Dashboard

**Cause:** API not returning data or network issue  
**Solution:**

1. Check if location updates are arriving in database: `SELECT * FROM live_locations`
2. Verify rep is authenticated: Check `device_bind_log` table
3. Check API logs for errors
4. Verify HTTPS is configured

### Issue: Location Permission Denied

**Cause:** User refused permission prompt  
**Solution:**

1. Open app settings → Permissions → Location
2. Change to "Always" or "While Using App"
3. Restart app

### Issue: Offline Queue Not Syncing

**Cause:** Device still offline or token expired  
**Solution:**

1. Check internet connectivity
2. Re-login if token expired
3. Clear app cache and restart

---

## 📈 Deployment Checklist

### Pre-Deployment

- [ ] Database migration executed successfully
- [ ] API endpoints tested with curl/Postman
- [ ] Flutter packages updated and compiled
- [ ] React components added to routing
- [ ] SSL certificate installed (HTTPS)
- [ ] Environment variables configured

### Deployment

- [ ] Upload `api_location.php` to server
- [ ] Update `.htaccess` if needed for routing
- [ ] Build and upload Flutter APK/IPA
- [ ] Build and deploy React dashboard
- [ ] Update API base URLs in configs

### Post-Deployment

- [ ] Test login with test rep account
- [ ] Verify locations appear on dashboard
- [ ] Check database for location records
- [ ] Monitor error logs for issues
- [ ] Conduct user training if needed

---

## 📞 Support & Maintenance

### Monitoring

- Monitor `device_bind_log` for unusual binding attempts
- Check `location_access_log` for admin access patterns
- Archive old location history monthly for performance

### Maintenance Tasks

```sql
-- Monthly: Archive old location history
DELETE FROM location_history
WHERE DATE(timestamp) < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Weekly: Clean up failed device bindings
DELETE FROM device_bind_log
WHERE bind_status = 'mismatch'
AND timestamp < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- As needed: Verify data integrity
SELECT rep_id, MAX(timestamp) as latest_update
FROM live_locations
GROUP BY rep_id;
```

---

## 🎯 Next Steps

After successful implementation:

1. **Phase 4.2** - Add biometric authentication (fingerprint)
2. **Phase 4.3** - Add geofencing alerts
3. **Phase 4.4** - Add voice recording & photo capture
4. **Phase 4.5** - Add advanced analytics dashboard

---

**Last Updated:** March 14, 2026  
**Version:** 1.0  
**Status:** Ready for Implementation
