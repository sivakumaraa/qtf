# First Test Run Checklist

## Pre-Testing Setup & Verification

**Status:** Must complete ALL items before first test  
**Estimated Time:** 15-20 minutes setup  
**Date:** March 14, 2026

---

## ✅ Phase 0: Prerequisites (5 minutes)

### System Requirements

- [ ] Windows/Mac/Linux with 8GB+ RAM
- [ ] Flutter SDK 3.0+ installed
  ```bash
  flutter --version
  ```
- [ ] Dart SDK 3.0+ installed
  ```bash
  dart --version
  ```
- [ ] Git installed and configured
- [ ] IDE: VS Code or Android Studio

### Flutter Setup

- [ ] Flutter pub cache clean (if needed)
  ```bash
  flutter pub cache clean
  ```
- [ ] Flutter SDK up to date
  ```bash
  flutter upgrade
  ```
- [ ] Flutter doctor shows no errors
  ```bash
  flutter doctor
  ```
  All checks should be green (or at least not blocking)

---

## ✅ Phase 1: Backend Setup (5 minutes)

### Database

- [ ] MySQL running
  ```bash
  mysql --version
  ```
- [ ] `quarryforce` database exists
  ```bash
  mysql -u root -p -e "SHOW DATABASES LIKE 'quarryforce';"
  ```
- [ ] PHASE_4_LOCATION_MIGRATION.sql executed
  ```bash
  mysql -u quarryforce -p quarryforce < PHASE_4_LOCATION_MIGRATION.sql
  ```
- [ ] New tables created (verify)
  ```bash
  mysql -u quarryforce -p quarryforce -e "SHOW TABLES LIKE 'live%';"
  mysql -u quarryforce -p quarryforce -e "SHOW TABLES LIKE 'device%';"
  ```

### PHP API

- [ ] PHP server running (XAMPP/WAMP/Native)
  ```bash
  # Check if running on localhost:80 or 8080
  curl http://localhost/
  ```
- [ ] api_location.php uploaded to qft-deployment/
  ```bash
  # Verify file exists
  ls -la d:\xampp\htdocs\qft-deployment\api_location.php
  ```
- [ ] api_location.php is readable and executable
  ```bash
  # Test endpoint
  curl http://localhost/api_location.php?action=health_check
  ```
- [ ] JWT_SECRET environment variable set
  ```bash
  # For XAMPP, add to .htaccess or php.ini
  # SetEnv JWT_SECRET "your-secret-key-here"
  ```

### Test Data

- [ ] Test user exists in database
  ```bash
  mysql -u quarryforce -p quarryforce \
    -e "SELECT id, email, role FROM users WHERE email='test@example.com';"
  ```
- [ ] If not, create test user:
  ```bash
  mysql -u quarryforce -p quarryforce << EOF
  INSERT INTO users (name, email, password, role, is_active)
  VALUES ('Test Rep', 'test@example.com', SHA2('test123', 256), 'rep', 1);
  EOF
  ```

### Backend Verification

- [ ] Backend responds to login request (test with curl)
  ```bash
  curl -X POST http://localhost/api_location.php?action=login \
    -d "email=test@example.com&password=test123&device_uid=test-device&device_model=Test" \
    -H "Content-Type: application/x-www-form-urlencoded"
  ```
  Expected response: `{"success":false,"message":"Invalid email or password"}` or similar
  (First login might fail if user not created, which is OK - we're just checking API responds)

---

## ✅ Phase 2: Mobile Setup (5 minutes)

### Flutter Project

- [ ] Workspace open: `d:\quarryforce\quarryforce_mobile`
- [ ] pubspec.yaml looks correct
  ```bash
  cat quarryforce_mobile/pubspec.yaml | head -20
  ```
- [ ] Dependencies installed
  ```bash
  cd quarryforce_mobile
  flutter pub get
  ```
  Should show "Got dependencies!" with no errors
- [ ] No Dart analyzer errors
  ```bash
  dart analyze lib/services/
  ```
  Should show "No issues found!"

### Device/Emulator Setup

- [ ] At least one target available
  ```bash
  flutter devices
  ```
  Should list at least one emulator or physical device

**CHOOSE ONE:**

### Option A: Android Emulator

- [ ] Android Emulator available
  ```bash
  flutter emulators
  ```
- [ ] Emulator can be launched
  ```bash
  flutter emulators --launch Pixel_5_API_30
  ```
  (Or whatever your emulator is named)
- [ ] Emulator boots successfully (wait 1-2 minutes)
- [ ] Android SDK 21+ (for location permissions)

### Option B: iOS Simulator

- [ ] Xcode installed and updated
  ```bash
  xcode-select --print-path
  ```
- [ ] iOS Simulator available
  ```bash
  xcrun simctl list devices
  ```
- [ ] Simulator can be launched
  ```bash
  xcrun simctl boot "iPhone 14"
  ```

### Option C: Real Android Device

- [ ] Device connected via USB
  ```bash
  adb devices
  ```
  Should show device in list
- [ ] USB Debugging enabled on device
      Settings > Developer Options > USB Debugging (ON)
- [ ] Device appears in `flutter devices`

### Option D: Real iOS Device

- [ ] Device connected via USB/Wireless
- [ ] Xcode recognizes device
- [ ] Device appears in Xcode device selector

---

## ✅ Phase 3: Configuration (2 minutes)

### API Configuration

- [ ] Correct API base URL in code
  ```bash
  grep -r "baseUrl\|api_base_url" quarryforce_mobile/lib/
  # Should show: http://localhost/api_location.php or similar
  ```
- [ ] Or update main.dart:
  ```dart
  // In main.dart or app initialization
  authService.initialize('http://localhost');
  // Note: Update localhost to your actual IP if testing on real device
  ```

### Logging Configuration

- [ ] Logger package installed
  ```bash
  grep "logger:" quarryforce_mobile/pubspec.lock
  # Should show logger version (2.6.2+)
  ```
- [ ] No analyzer warnings for logger
  ```bash
  dart analyze lib/services/ | grep -i logger
  # Should be empty (no errors related to logger)
  ```

---

## ✅ Phase 4: Quick Smoke Test (3 minutes)

### Launch App

- [ ] Run Flutter app
  ```bash
  flutter run
  ```
  Should see:
  - Compiling... logs
  - Build successful message
  - App appears on device/emulator
  - No crash errors

### See Login Screen

- [ ] Login screen displays
  - QuarryForce logo or branding
  - Email input field
  - Password input field
  - Login button
- [ ] No obvious UI issues
  - Text is readable
  - Buttons are tappable
  - Layout is not broken

### Check Console Logs

- [ ] No red error messages in console
  ```bash
  # In the terminal running: flutter run
  # Should see: [INFO] messages but NO [ERROR] messages
  ```

---

## ✅ Phase 5: Database Structure Verification (2 minutes)

### Verify All Tables Exist

```bash
mysql -u quarryforce -p quarryforce << EOF
-- Check all new tables from Phase 4.1 migration
SHOW TABLES;
EOF
```

Should see:

- [ ] `live_locations` table
- [ ] `location_history` table
- [ ] `device_bind_log` table
- [ ] `location_access_log` table
- [ ] `users` table (modified with device_uid, device_bound columns)

### Verify Table Structure

```bash
# OPTION 1: Using DESC command (fastest)
mysql -u quarryforce -p quarryforce -e "DESC live_locations;"

# OPTION 2: Using SHOW CREATE TABLE (shows full definition)
# Run in MySQL CLI directly (not with -e flag):
mysql -u quarryforce -p quarryforce
# Then type: SHOW CREATE TABLE live_locations\G
# Press Enter

# OPTION 3: Using INFORMATION_SCHEMA (for batch scripts)
mysql -u quarryforce -p quarryforce -e \
  "SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='live_locations' AND TABLE_SCHEMA='quarryforce';"

# Any option above should show these columns:
# - id (INT, Primary Key)
# - rep_id (INT, Foreign Key to users)
# - latitude (DECIMAL)
# - longitude (DECIMAL)
# - accuracy (INT)
# - timestamp (DATETIME)
# - synced (TINYINT)
```

**Note:** The `\G` terminator only works in interactive MySQL CLI mode. For batch/scripting use `-e` with regular semicolon instead.

---

## ⚠️ Common Pre-Test Issues

| Issue                        | Check                  | Solution                               |
| ---------------------------- | ---------------------- | -------------------------------------- |
| `flutter: command not found` | Is Flutter in PATH?    | Add Flutter to system PATH             |
| `No devices found`           | Run `flutter devices`  | Start emulator or connect device       |
| Analyzer errors              | Run `dart analyze`     | Run `flutter pub get` again            |
| API won't connect            | Is PHP server running? | Start XAMPP/WAMP or local PHP server   |
| Database missing tables      | Run migration          | Execute PHASE_4_LOCATION_MIGRATION.sql |
| Login always fails           | Wrong credentials?     | Create test user with INSERT query     |
| Location permission denied   | Not requested?         | Rebuild app after pubspec changes      |

---

## 🎯 Ready to Test?

### Final Checklist (5 items)

Before running the FIRST actual test:

- [ ] All 5 phases above are 100% complete
- [ ] Database shows test user created
- [ ] PHP API responds (curl test worked)
- [ ] Flutter app runs without crashes
- [ ] Emulator/device ready with mock location settings

### Start First Test

Once all items checked, proceed to:

**→ Read:** [PHASE_4_1_MOBILE_TESTING_GUIDE.md](../PHASE_4_1_MOBILE_TESTING_GUIDE.md)  
**→ Run:** Test 1 - First-Time Login (Device Binding)

---

## 📊 What Gets Tested in First Run

| Component           | Test                     | Expected Result          |
| ------------------- | ------------------------ | ------------------------ |
| Login Screen        | Displays                 | ✅ No UI broken          |
| Authentication      | `test@example.com` login | ✅ HTTP 200 response     |
| Device Binding      | First login              | ✅ UUID generated        |
| Secure Storage      | Token saved              | ✅ Token readable by app |
| Location Permission | Dialog                   | ✅ User can grant/deny   |
| Location Service    | GPS read                 | ✅ Gets coordinates      |
| Database Insert     | Location saved           | ✅ Row in live_locations |
| Admin Dashboard     | View locations           | ✅ Rep appears on map    |

---

## 🆘 If Something Fails

### Immediate Actions

1. **Check logs:** `flutter logs` in terminal
2. **Check database:** Verify migration ran
3. **Check API:** Test curl request manually
4. **Check device:** Verify location permissions
5. **Read guide:** See [PHASE_4_1_IMPLEMENTATION_GUIDE.md](../PHASE_4_1_IMPLEMENTATION_GUIDE.md) troubleshooting

### Report Issue

If you need help, save:

- `flutter doctor` output
- `flutter logs` output
- MySQL query results
- API curl response
- Error message screenshot

---

**Status:** ✅ Checklist Ready  
**Created:** March 14, 2026  
**Approved For:** Phase 4.1 Testing

🚀 **Ready to begin testing!**
