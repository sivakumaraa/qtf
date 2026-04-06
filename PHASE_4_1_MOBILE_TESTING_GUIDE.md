# Phase 4.1 Mobile App Testing Guide

## Complete Testing Procedures for Login & Location Tracking

**Last Updated:** March 14, 2026  
**Status:** Ready for Testing

---

## 🚀 Quick Start Testing (5 Minutes)

### Prerequisites

- [ ] **Flutter SDK installed and updated**

  ```bash
  flutter --version
  # Should show 3.0.0 or higher
  ```

- [ ] **Dart SDK 3.0+**

  ```bash
  dart --version
  # Should show 3.0.0 or higher
  ```

- [ ] **Android Studio OR Xcode** (pick one)

  ```bash
  # For Android
  flutter doctor | grep "Android Studio"

  # For iOS
  flutter doctor | grep "Xcode"
  ```

- [ ] **At least one device/emulator target ready**

  ```bash
  flutter devices
  # Should list at least 1 device or emulator
  ```

- [ ] **Mobile app dependencies installed**

  ```bash
  cd d:\quarryforce\quarryforce_mobile
  flutter pub get
  # Should complete with "Got dependencies!"
  ```

- [ ] **Dart analyzer shows no errors**
  ```bash
  dart analyze lib/
  # Should show "No issues found!"
  ```

**Not ready?** → Go through [PHASE_4_1_FIRST_TEST_RUN_CHECKLIST.md](PHASE_4_1_FIRST_TEST_RUN_CHECKLIST.md) first (takes 20 min)

### Fast Track

```bash
# 1. Navigate to mobile app
cd d:\quarryforce\quarryforce_mobile

# 2. Ensure dependencies are fresh
flutter pub get

# 3. Launch app on emulator/device
flutter run

# 4. Wait for app to compile and launch (~30-60 seconds)
# You should see the Login Screen
```

**In the App:**

1. **Login Screen appears** ✓
2. Replace pre-filled email with: `john@quarry.com`
3. Tap "Login" button (no password needed - device binding handles auth)
4. **Device binding popup** appears with your Device UID
5. **Allow location permission** when prompted (choose "While Using App")
6. **Home screen shows** with your current location
7. Open admin dashboard: `http://localhost:3000/rep-locations`
8. **Your location appears on the map** within 30 seconds

✅ **All 8 steps work?** → Test successful! Proceed to [Test Scenarios](#test-scenarios) below

### Troubleshooting Quick Start (If Step 1-7 fail)

| Problem                        | Immediate Fix                                              |
| ------------------------------ | ---------------------------------------------------------- |
| `flutter: command not found`   | Add Flutter to PATH or use full path                       |
| `No devices found`             | Start emulator or connect device, then `flutter devices`   |
| `Dependency errors`            | Run `flutter clean && flutter pub get`                     |
| `Compilation errors`           | Check Dart analyzer: `dart analyze lib/`                   |
| `App crashes on launch`        | Check logs: `flutter logs`                                 |
| `Login fails / Invalid email`  | Use existing user: `john@quarry.com`                       |
| `No password field visible`    | Correct! Email-only login + device binding (no password)   |
| `Location won't update`        | Check location permission in settings                      |
| `Can't access admin dashboard` | Is admin dashboard running? Check `http://localhost:3000/` |

**Still stuck?** → See full [First Test Run Checklist](PHASE_4_1_FIRST_TEST_RUN_CHECKLIST.md)

---

## 📱 Setup: Device/Emulator Configuration

### Android Emulator

```bash
# List available devices
flutter devices

# Create new emulator (if needed)
flutter emulators --create --name "Pixel_5_API_30"

# Launch emulator
flutter emulators --launch "Pixel_5_API_30"

# Verify it's running
flutter devices
```

### iOS Simulator

```bash
# List available simulators
xcrun simctl list devices

# Launch specific simulator
xcrun simctl boot "iPhone 14"

# Verify it's running
flutter devices
```

### Real Device (Android)

```bash
# Enable USB debugging on device
# Settings > Developer Options > USB Debugging (ON)

# Connect via USB
# Run: flutter devices  # Should show your device

# Deploy app
flutter run -d <device_id>
```

### Real Device (iOS)

```bash
# Connect via USB/Wireless
# Xcode handles provisioning

# Deploy app
flutter run -d <device_id>
```

---

## 🏗️ Building the App

### Debug APK (Android)

```bash
cd quarryforce_mobile

# Build APK (fast, development)
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Install on device
flutter install
```

### Release APK (Android)

```bash
# Build optimized APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Sign APK (if needed for distribution)
# Requires keystore file - see deployment guide
```

### iOS App Bundle

```bash
# Build for iOS
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
# Can be opened in Xcode for further distribution setup
```

### Web (Testing in Browser)

```bash
# Build for web (if enabled)
flutter build web

# Run web locally
flutter run -d web-server
# Open: http://localhost:5000
```

---

## 🧪 Test Scenarios

### Test 1: First-Time Login (Device Binding)

**Duration:** 2-3 minutes  
**Expected:** Device UID generated and bound to user account

**Steps:**

1. Launch app: `flutter run -d chrome`
2. **Login Screen appears** with pre-filled email
3. Clear email field and enter: `john@quarry.com`
4. Tap "Login" button (no password - device binding is the auth factor)
5. Wait for authentication...
6. **Device binding dialog** appears showing:
   - Device UID (auto-generated UUID)
   - Device Type (Web, Android, iOS)
   - Confirmation to bind this device
7. **Tap "Allow" or "Confirm"** to bind device
8. **Location permission dialog** appears
9. Tap "While Using App" (or "Always" for background tracking)
10. **Home screen** shows current location with marker on map
11. **Location marker** appears on admin dashboard within 30 seconds

**Verification:**

- ✅ Email-only login (no password field)
- ✅ Device UID auto-generated and shown in popup
- ✅ Device binding prevents multi-device access
- ✅ App stores device UID securely
- ✅ Location appears in admin dashboard within 30 seconds
- ✅ Device binding log recorded in database

**Testing on Emulator:**

```bash
# Set mock location (Android)
# In emulator: Extended Controls > Location > Set location
# Latitude: 37.7749, Longitude: -122.4194 (San Francisco)

# Or use Chrome DevTools for web testing
```

---

### Test 2: Second Login (Same Device)

**Duration:** 1 minute  
**Expected:** Same device recognized, no new binding dialog

**Steps:**

1. Back out of app (kill process): `Ctrl+C` in terminal
2. Re-launch: `flutter run -d chrome`
3. See Login Screen again with pre-filled email
4. Enter: `john@quarry.com`
5. Tap "Login" button
6. **No device binding dialog** (device already recognized)
7. **Skips directly to home screen/map**
8. **Location tracking** resumes immediately

**Verification:**

- ✅ Same device UID recognized (stored locally)
- ✅ No device binding dialog shown
- ✅ No new device binding log entry created
- ✅ Instant authentication (same device = trusted)
- ✅ Location updates visible on dashboard

---

### Test 3: Different Device (Device Mismatch)

**Duration:** 2 minutes  
**Expected:** Login fails with device mismatch error

**Steps:**

1. **Clear device storage:**
   - Chrome: DevTools (F12) → Application → Storage → Clear all
   - Or use new Incognito window
2. **Login again with same email:** `john@quarry.com`
3. Tap "Login" button
4. **Error message appears:** "Device mismatch" or "Not authorized on this device"
5. **Login fails** and returns to login screen
6. Original device can still login (device binding is immutable)

**Verification:**

- ✅ Device mismatch detected by server
- ✅ Error logged with device info
- ✅ Unauthorized access prevented (device binding blocks it)
- ✅ Admin audit log updated with failed attempt
- ✅ Original device still works (binding is one-to-one)

---

### Test 4: Location Tracking

**Duration:** 3-5 minutes  
**Expected:** Continuous location updates every 30 seconds

**Steps:**

1. Login successfully (skip Tests 1-2)
2. Open app to Home screen showing location
3. Open admin dashboard in browser (different window)
4. **Rep Locations page** shows your location
5. Wait 30 seconds
6. Location marker should update
7. Move mock location in emulator:
   - Android: Extended Controls > Location > [change coordinates]
   - iOS: Simulator > Features > Location > Custom Location
8. Wait 30 seconds for next update
9. **New location appears** on dashboard
10. **Marker moves** on map
11. **Timestamp updates** to recent time

**Verification Checklist:**

- ✅ Location updates every 30 seconds (configurable)
- ✅ Accuracy displayed correctly
- ✅ Timestamp shows current time
- ✅ Dashboard polling updates location every 10 seconds
- ✅ Online indicator (green pulsing marker)
- ✅ Rep list shows "X seconds ago"

**Advanced Verification:**

```bash
# Check database for location_history records
mysql -u quarryforce -p quarryforce
SELECT * FROM location_history
WHERE rep_id = (SELECT id FROM users WHERE email='john@quarry.com')
ORDER BY timestamp DESC LIMIT 5;
```

---

### Test 5: Offline Behavior

**Duration:** 5 minutes  
**Expected:** Locations queue locally, sync when online

**Steps:**

1. Login and start tracking (Test 4)
2. **Disable network:**
   - Android: Settings > Network & Internet > Airplane Mode (ON)
   - iOS: Settings > Airplane Mode (ON)
   - Or disconnect WiFi
3. Move mock location several times (change coordinates 3-4 times)
4. Check app (should show "Offline" indicator)
5. **Wait 1-2 minutes** in offline mode
6. **Re-enable network:**
   - Turn off Airplane Mode
   - Reconnect WiFi
7. App should show "Syncing..." indicator briefly
8. **Check admin dashboard** - all missed locations should now appear

**Verification:**

- ✅ Offline icon displayed (red/gray indicator)
- ✅ Locations stored locally (SQLite)
- ✅ Queue syncs automatically when online
- ✅ No location data lost
- ✅ Dashboard shows all historical locations
- ✅ Database has all location_history records

**Database Check:**

```bash
# Verify locations in SQLite (on device)
# In Flutter code, this would be in app's documents directory

# Or check MySQL after sync
mysql -u quarryforce -p quarryforce
SELECT COUNT(*) as total_locations
FROM location_history
WHERE date(timestamp) = CURDATE();
```

---

### Test 6: Permission Handling

**Duration:** 2 minutes  
**Expected:** Location only works with proper permissions

**Steps - FIRST TIME:**

1. Launch app fresh (no data)
2. Tap Login
3. **Location permission dialog** appears
4. Choose: "While Using App" (recommended)
5. App continues normally
6. Location tracking works

**Steps - DENIED PERMISSION:**

1. Clear app data
2. Launch app again
3. At permission dialog, tap "Deny"
4. **Error message** appears: "Location permission required"
5. Try to access home screen - **blocked/error**
6. User must go back to Settings to grant permission manually

**Steps - PERMISSIONS SETTINGS:**

1. Go to Settings > Apps > QuarryForce > Permissions
2. See "Location" with current status
3. Tap "Location"
4. Toggle permission on/off
5. Return to app
6. Permission status updates accordingly

**Verification:**

- ✅ Permission dialog shown on first login
- ✅ App won't track without permission
- ✅ Settings changes honored immediately
- ✅ Error handling graceful
- ✅ User can grant permission anytime in Settings

---

### Test 7: Session Restoration

**Duration:** 2 minutes  
**Expected:** App remembers login across restarts

**Steps:**

1. Login successfully (Test 1)
2. **Kill the app** (close it completely)
3. **Relaunch** the app
4. **No login screen** - goes directly to home/map
5. Location tracking **immediately resumes**
6. Session is **still valid**

**Verification:**

- ✅ Token loaded from secure storage
- ✅ User data restored
- ✅ Location service initialized
- ✅ No re-authentication required
- ✅ User appears online on dashboard

**Force Logout Test:**

1. Tap "Logout" button (in app menu)
2. **Confirm logout**
3. **Login screen** appears
4. Kill and relaunch app
5. **Login screen still shows** (session cleared)

---

### Test 8: Error Scenarios

**Duration:** 3 minutes  
**Expected:** Graceful error handling

#### Scenario A: Invalid Email

1. Login with non-existent email: `nonexistent@quarry.com`
2. **Error banner** appears: "User not found" or "Invalid email"
3. User can retry with correct email
4. No crash, clean recovery

#### Scenario B: Network Error

1. Turn off WiFi
2. Try to login
3. **Connection error** message shown
4. User can retry when network returns

#### Scenario C: Server Error

1. Stop backend API server
2. Try to login
3. **Server unavailable** error shown gracefully
4. No crash
5. User can retry

#### Scenario D: Invalid Response

1. Mock a 500 error response
2. **Error displayed** without crashing
3. **Logging captured** for debugging

**All scenarios should:**

- ✅ Show user-friendly error message (red banner)
- ✅ Not crash the app
- ✅ Allow retry
- ✅ Log error for debugging
- ✅ Clear error message when fixed

---

## 🔍 Manual Inspection Testing

### Check Logs

```bash
# View real-time logs during testing
flutter logs

# Look for:
# [AuthService] Attempting login for:
# [AuthService] Login successful for:
# [DeviceService] Device UID generated:
# [LocationService] Location update:
```

### Check Secure Storage

```bash
# Android - Emulator shell
adb shell
cd /data/data/com.quarryforce.mobile/
# Files are encrypted in flutter_secure_storage

# iOS - Simulator (via Xcode)
# Keychain entries visible in Xcode debugger
```

### Check Database

```bash
# After login and location tracking:
mysql -u quarryforce -p quarryforce

# Check user device binding
SELECT id, email, device_uid, device_bound, last_login
FROM users WHERE email='john@quarry.com';

# Check live locations
SELECT * FROM live_locations;

# Check location history
SELECT * FROM location_history
WHERE rep_id = (SELECT id FROM users WHERE email='john@quarry.com')
ORDER BY timestamp DESC LIMIT 10;

# Check device binding log
SELECT user_id, device_uid, bind_status, device_model, ip, timestamp
FROM device_bind_log
ORDER BY timestamp DESC LIMIT 10;

# Check access logs
SELECT admin_id, rep_id, access_type, timestamp
FROM location_access_log
ORDER BY timestamp DESC LIMIT 5;
```

---

## 📊 Admin Dashboard Testing

### Verify Dashboard Features

1. **Open Admin Dashboard** in browser: `http://localhost:3000/rep-locations`
2. **Map displays** with markers
3. **Rep list** shows all logged-in reps
4. **Statistics cards:**
   - "Online": Should show count of active reps
   - "Offline": Reps not connected
   - "Total": All reps
   - "Coverage %": Percentage with location data
5. **Auto-refresh** toggle ON - updates every 10 seconds
6. **Markers animate:**
   - Green markers for online = pulsing animation
   - Gray markers for offline = static

### Test Dashboard Interactions

1. **Click marker on map** - popup appears with:
   - Rep name
   - Email
   - Phone
   - Current coordinates
   - Accuracy (meters)
   - Last update timestamp
2. **Click rep in list** - map centers on that rep
3. **Toggle auto-refresh OFF** - dashboard freezes
4. **Toggle ON** - dashboard resumes updates
5. **Wait 10+ seconds** - verify last update timestamp changes

### Dashboard Admin Features

```bash
# Check who accessed location data (audit trail)
mysql -u quarryforce -p quarryforce
SELECT * FROM location_access_log;
# Should show admin_id when accessing locations from dashboard
```

---

## 🎯 Integration Testing

### Full Flow Test (10 minutes)

1. **Start with clean state:**
   - Delete app data
   - Clear browser cache
   - Restart backend API

2. **Execute sequence:**
   - Rep login on mobile
   - Device binding occurs
   - Location tracking starts
   - Location appears on admin dashboard within 30 seconds
   - Admin clicks on rep for details
   - Rep moves (change mock location)
   - Admin dashboard updates in real-time
   - Rep logs out
   - Dashboard shows rep as offline
   - Rep logs back in
   - Location tracking resumes

3. **Verify at each step:**
   - ✅ No crashes
   - ✅ Data consistency
   - ✅ Correct timestamps
   - ✅ Proper permissions
   - ✅ Secure storage
   - ✅ Network handling

---

## 🔧 Debugging Tips

### Enable Verbose Logging

```bash
# Run with verbose output
flutter run -v

# Shows all network requests, state changes, errors
```

### Inspect Network Traffic

```bash
# Android - via Charles Proxy or Wireshark
# iOS - via Xcode Network Link Conditioner

# Or use Dio logging (already enabled in code)
# Check logs for all HTTP requests/responses
```

### Check Widget Tree

```bash
# During `flutter run`, type 's' to dump widget tree
# Type 'w' to show widget tree with visual layout
# Type 'L' to find layers
```

### Performance Testing

```bash
# Check memory usage
flutter run --profile

# Or use Observatory (Dart DevTools)
flutter pub global activate devtools
devtools

# Then in browser: http://localhost:9100
```

---

## ✅ Testing Checklist

### Pre-Deployment Testing

- [ ] Login works with valid credentials
- [ ] Device binding occurs on first login
- [ ] Same device recognized on second login
- [ ] Different device rejected with error
- [ ] Location tracking starts automatically
- [ ] Location updates every 30 seconds
- [ ] Admin dashboard shows location in real-time
- [ ] Offline mode queues locations locally
- [ ] Sync occurs automatically when online
- [ ] Permission dialogs appear and work correctly
- [ ] Session restored after app restart
- [ ] Logout clears all data
- [ ] Errors handled gracefully
- [ ] No sensitive data in logs
- [ ] Database records created correctly
- [ ] Audit logs capture all actions
- [ ] Performance acceptable (no lag)
- [ ] Works on Android and iOS

### Performance Benchmarks

- Login time: < 2 seconds
- Location update: < 5 seconds
- Dashboard load: < 2 seconds
- Map render: < 1 second
- No memory leaks after 10+ location updates

### Security Verification

- [ ] Token stored securely (not in SharedPreferences)
- [ ] Device UID cannot be spoofed
- [ ] Multi-device login prevented
- [ ] No plain-text passwords
- [ ] API calls use HTTPS (in production)
- [ ] Error messages don't reveal sensitive info
- [ ] No location data accessible without auth

---

## 📋 Test Data

### Sample Test Users (ensure these exist in database)

```sql
-- Test users that have email-only login (no password required)
-- Device binding handles one-time authentication
INSERT INTO users (name, email, password, role) VALUES
('John Doe', 'john@quarry.com', 'password123', 'rep'),
('Jane Smith', 'jane@quarry.com', 'password123', 'rep'),
('Mike Johnson', 'mike@quarry.com', 'password123', 'rep');
```

**For testing, use:**

- Email: `john@quarry.com`
- No password needed (device binding + email only)

### Sample Locations (for testing dashboard)

```sql
-- Mock location data (if needed for testing)
INSERT INTO live_locations (rep_id, latitude, longitude, accuracy, timestamp) VALUES
(1, 37.7749, -122.4194, 15, NOW()),
(2, 37.7849, -122.4094, 20, NOW());
```

---

## 🚨 Common Issues & Solutions

| Issue                         | Cause                         | Solution                                    |
| ----------------------------- | ----------------------------- | ------------------------------------------- |
| "Target of URI doesn't exist" | Missing pubspec.yaml packages | `flutter pub get`                           |
| App crashes on login          | API URL not set               | Check api_base_url in config                |
| Location not updating         | Permission not granted        | Ask for location permission in settings     |
| Emulator has no location      | Mock location not set         | Extended Controls > Location > Set location |
| "Failed to connect to API"    | Backend not running           | Start PHP server, verify URL                |
| Device binding fails          | UUID not generated            | Check flutter_secure_storage access         |
| Dashboard shows no reps       | Locations not syncing         | Verify network, check logs                  |
| Permission denied on iOS      | Provisioning profile issue    | Check Xcode signing settings                |

---

## 📞 Support Resources

**For Setup Issues:**
→ See PHASE_4_1_IMPLEMENTATION_GUIDE.md (Section 3: Flutter Setup)

**For API Issues:**
→ Test endpoints with curl or Postman first

**For Database Issues:**
→ Verify migration ran: `SHOW TABLES;` in MySQL

**For Deployment:**
→ See PHASE_4_1_IMPLEMENTATION_GUIDE.md (Deployment section)

---

## 🎓 Next Steps After Testing

Once all tests pass:

1. **Build Release APK/IPA**

   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

2. **Prepare for App Store/Play Store**
   - Create app listings
   - Set privacy policy
   - Create store screenshots

3. **Deploy to staging servers**
   - Test with real backend
   - Verify HTTPS/SSL

4. **Begin Phase 4.2**
   - Biometric authentication
   - Geofencing

---

**Status:** ✅ Ready to begin testing  
**Last Updated:** March 14, 2026  
**Next Review:** After Phase 4.1 testing complete
