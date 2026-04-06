# 📱 Mobile App Testing Guide - Namecheap Production

Complete step-by-step guide to test QuarryForce mobile app against Namecheap production server.

---

## 📋 Prerequisites

- ✅ Flutter installed (`flutter --version`)
- ✅ Mobile app code in: `d:\quarryforce\quarryforce_mobile\`
- ✅ API URL updated to: `https://valviyal.com/qft/api` (already done)
- ✅ Production backend deployed on Namecheap
- ✅ Android emulator/device OR iOS simulator/device OR Chrome browser

---

## 🚀 Step 1: Verify API Connection (Before Building)

### Test 1.1: Health Check Endpoint

```powershell
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

(Invoke-WebRequest -Uri "https://valviyal.com/qft/api/test" `
  -Method GET).Content
```

**Expected Response:**

```json
{ "server": "Online", "database": "Connected", "version": "2.0.0" }
```

**If this fails:**

- ❌ Backend not responding
- ❌ Namecheap deployment incomplete
- ❌ Deploy the ZIP first before testing app

**If this works:**

- ✅ Continue to next step

---

### Test 1.2: Test Login Endpoint

```powershell
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$body = '{"email":"demo@quarryforce.local","device_uid":"test-device-123"}'

(Invoke-WebRequest -Uri "https://valviyal.com/qft/api/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body).Content
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Device registered successfully!",
  "user": {
    "id": 1,
    "name": "Demo Rep",
    "email": "demo@quarryforce.local",
    "role": "rep"
  }
}
```

**If this fails:**

- Stop and fix backend first (see troubleshooting)
- Do not proceed with app testing

**If this works:**

- ✅ Backend is ready for mobile app testing

---

## 📱 Step 2: Build Mobile App

### Option A: Test in Browser (Quickest - 5 minutes)

**Best for:** Quick testing without building APK/IPA

```powershell
cd d:\quarryforce\quarryforce_mobile

# Get dependencies
flutter pub get

# Run in Chrome browser
flutter run -d chrome
```

**What to expect:**

- Chrome window opens with app
- App loads login screen
- Can test login, navigation, features in real-time

---

### Option B: Build Android APK (10-15 minutes)

**Best for:** Testing on real Android device/emulator

```powershell
cd d:\quarryforce\quarryforce_mobile

# Get dependencies
flutter pub get

# Build APK (release - optimized)
flutter build apk --release
```

**Output:**

```
✓ Built build/app/outputs/flutter-apk/app-release.apk (41.2 MB)
```

**Installation:**

```powershell
# Install on connected Android device
flutter install

# OR install APK manually
# Download: build/app/outputs/flutter-apk/app-release.apk
# Open on device → Install
```

---

### Option C: Build for iOS (20 minutes, Mac required)

```powershell
cd d:\quarryforce\quarryforce_mobile

flutter pub get

flutter build ipa --release
```

**Output:**

```
✓ Built build/ios/iphoneos/Runner.app
```

**Installation:**

- Use Xcode to deploy to iPhone simulator or physical device
- Or use TestFlight for distribution

---

## ✅ Step 3: Test Login Flow

### Test 3.1: Launch App

**In Browser (Chrome):**

- Chrome window automatically opens
- App UI loads

**On Android/iOS Device:**

- Tap app icon to launch
- App loads login screen

**Expected:**

- Login screen visible
- Email field ready for input
- Loading spinner not visible

---

### Test 3.2: Login with Demo User

**Input:**

- Email: `demo@quarryforce.local`
- Device UID: (auto-generated or `test-device-123`)

**Steps:**

1. Tap email field
2. Type: `demo@quarryforce.local`
3. Tap "Login" button
4. Wait 3-5 seconds

**Expected:**

- ✅ Login succeeds
- ✅ Navigates to dashboard
- ✅ User info displays: "Demo Rep"
- ❌ No error messages

**If login fails:**

```
Error: "Invalid email or device"
```

**Solution:**

- Make sure demo user exists in database
- Try with valid email in your database
- Check API endpoint is responding (Test 1.2 above)

---

## 📍 Step 4: Test GPS/Location Features

### Test 4.1: Check-in Location

**In App:**

1. Tap hamburger menu (☰)
2. Tap "Check In"
3. Allow location permission when prompted
4. Tap "Get Location" button
5. Wait for GPS reading

**Expected:**

- ✅ Location captured (latitude, longitude)
- ✅ Accuracy shown
- ✅ "Check In" button becomes active
- ✅ Tap "Submit" → success message

**If location fails:**

```
Error: "Unable to get location"
```

**Solutions:**

- On emulator: Enable mock location in Android settings
- Allow app location permission: Settings → Apps → QuarryForce → Permissions → Location
- Check device GPS is enabled

---

## 📝 Step 5: Test Visit Submission

### Test 5.1: Create Visit

**In App:**

1. Tap "Record Visit"
2. Select customer (dropdown shows list from API)
3. Enter notes (optional): "Test visit from mobile"
4. Select purpose: Service, Direct Sale, etc.
5. Tap "Submit Visit"

**Expected:**

- ✅ Customer list loads from API
- ✅ Form submits successfully
- ✅ Success message: "Visit recorded"
- ✅ Visit appears in history

**Verify in Admin Dashboard:**

```
Browser: https://valviyal.com/qft
Dashboard → Customers → Check visit history
```

Should show your test visit in the list.

---

## ⛽ Step 6: Test Fuel Submission

### Test 6.1: Log Fuel Consumption

**In App:**

1. Tap "Log Fuel"
2. Enter quantity: `25` (liters)
3. Enter cost: `2500` (currency units)
4. Select type: "Regular" or "Diesel"
5. Enter odometer: `45000`
6. Tap "Submit"

**Expected:**

- ✅ Form validates data
- ✅ Success message
- ✅ Entry disappears from form
- ✅ Appears in fuel history

**Verify in Admin Dashboard:**

```
Browser: https://valviyal.com/qft
Dashboard → Fuel Log → Check latest entry
```

---

## 🔍 Step 7: Test Data Sync

### Test 7.1: Verify API Data in Dashboard

**In Browser (Admin Dashboard):**

```
1. Go to: https://valviyal.com/qft
2. Login (if required)
3. Navigate → "Customers" menu
4. Should show customers list from API

5. Navigate → "Fuel Log" menu
6. Should show fuel entries you submitted from mobile

7. Navigate → "Visit History" menu
8. Should show visits you recorded from mobile
```

**Expected:**

- ✅ All data submitted from app appears in dashboard
- ✅ Timestamps are correct
- ✅ Data integrity maintained

---

## ⚠️ Step 8: Test Error Scenarios

### Test 8.1: Network Disconnection

**Steps:**

1. Check in on mobile app
2. Turn off WiFi/cellular
3. Try to submit visit while offline
4. Turn connectivity back on
5. App should retry and sync

**Expected:**

- ✅ Offline queue saves data
- ✅ Syncs when connection restored
- ✅ No data loss

---

### Test 8.2: Invalid Login

**Steps:**

1. Clear app data (or reinstall)
2. Login with wrong email: `invalid@email.com`
3. Observe error message

**Expected:**

- ✅ Error message: "Invalid email or device"
- ✅ Stay on login screen
- ✅ Can retry

---

### Test 8.3: Timeout Handling

**Steps:**

1. Open app
2. Go to login
3. Fill email: `demo@quarryforce.local`
4. Turn off WiFi
5. Tap Login
6. Wait 30+ seconds

**Expected:**

- ✅ Timeout error message
- ✅ "Retry" button available
- ✅ App doesn't crash

---

## 📊 Step 9: Performance Testing

### Test 9.1: Response Time

**Measure login time:**

```
Start: Tap Login button
End: Dashboard fully loads
Target: < 3 seconds
```

**Measure list load time:**

```
Start: Open Customers list
End: All items visible
Target: < 2 seconds
```

**If slow:**

- Check network speed
- Check server response (test API directly)
- Check for large data payloads

---

### Test 9.2: Memory Usage

**On Android:**

1. Open Settings → Developer Options
2. Check memory usage
3. Monitor app memory while using
4. Should not exceed 150 MB in normal use

**On iOS:**

1. Xcode → Debug → View Memory Graph
2. Monitor during usage
3. Should not exceed 100 MB

---

## 🎯 Step 10: Complete Test Checklist

Print this checklist and verify all items:

```
✅ SETUP
  [ ] API Health Check passes (Test 1.1)
  [ ] Login endpoint responds (Test 1.2)
  [ ] App builds without errors (Step 2)

✅ LOGIN
  [ ] Login with demo@quarryforce.local works (Test 3.2)
  [ ] Dashboard loads after login
  [ ] User name displays correctly

✅ LOCATION
  [ ] Request location permission works (Test 4.1)
  [ ] GPS location captured
  [ ] Check-in submits successfully

✅ VISITS
  [ ] Customer dropdown shows data (Test 5.1)
  [ ] Visit form submits successfully
  [ ] Visit appears in admin dashboard

✅ FUEL
  [ ] Fuel form accepts input (Test 6.1)
  [ ] Submission succeeds
  [ ] Data appears in admin dashboard

✅ DATA SYNC
  [ ] Mobile data visible in dashboard (Test 7.1)
  [ ] Timestamps correct
  [ ] No missing data

✅ ERROR HANDLING
  [ ] Offline queue works (Test 8.1)
  [ ] Invalid login shows error (Test 8.2)
  [ ] Timeout handled gracefully (Test 8.3)

✅ PERFORMANCE
  [ ] Login < 3 seconds (Test 9.1)
  [ ] Lists load < 2 seconds
  [ ] Memory usage normal (Test 9.2)
```

---

## 🔧 Troubleshooting

### Problem: "Cannot connect to server"

**Causes:**

- API URL wrong in code
- Server not responding
- SSL certificate issue
- WiFi not connected

**Solutions:**

1. Verify: `https://valviyal.com/qft/api/test` in browser
2. Check mobile WiFi is connected
3. On Android emulator: Use `10.0.2.2` for localhost
4. Check app has internet permission in `AndroidManifest.xml`

---

### Problem: "Login fails but API works"

**Causes:**

- Demo user doesn't exist in database
- Device binding issue
- Incorrect credentials

**Solutions:**

1. Verify user exists: `SELECT * FROM users WHERE email='demo@quarryforce.local';`
2. Try with different email if available
3. Check database connection in admin panel

---

### Problem: "Location permission denied"

**Solutions:**

- On Android: Settings → Apps → QuarryForce → Permissions → Location → Allow
- On iOS: Settings → QuarryForce → Location → Always
- On emulator: Enable mock location: Settings → Developer Options → Mock Location

---

### Problem: "App crashes on startup"

**Solutions:**

```powershell
# Check for errors
flutter logs

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome    # or your device
```

---

### Problem: "Data not syncing to admin dashboard"

**Causes:**

- API endpoint not receiving data
- Server-side error logging

**Solutions:**

1. Check server logs: Namecheap cPanel → File Manager → `/logs/app.log`
2. Manual test: Submit visit via API directly
3. Verify database insert working

---

## 📞 Performance Benchmarks

**Expected times (on production):**

| Operation         | Time                |
| ----------------- | ------------------- |
| Login             | 2-3s                |
| Load customers    | 1-2s                |
| Load fuel history | 1-2s                |
| Submit visit      | 1-2s                |
| Submit fuel       | 1-2s                |
| Check-in          | 3-5s (includes GPS) |

If significantly slower, check:

- Server CPU/memory usage
- Database query performance
- Network latency

---

## ✅ When All Tests Pass

**Congratulations!** Your system is production-ready:

1. ✅ Backend API working
2. ✅ Mobile app connects successfully
3. ✅ Data submits and syncs
4. ✅ Admin dashboard shows all data
5. ✅ Error handling works
6. ✅ Performance acceptable

**Next steps:**

1. Build final release APK/IPA
2. Submit to Google Play Store / App Store
3. Publish admin dashboard
4. Train users
5. Launch! 🚀

---

## 📝 Test Report Template

**Date:** March 5, 2026  
**App Version:** 1.0.0  
**Backend:** Namecheap (PHP)  
**Tester:** [Your name]

### Results

- [ ] All tests passed
- [ ] Some tests failed (list below)
- [ ] Critical issues found (list below)

### Issues Found

```
1. [Describe issue]
   - Expected: [What should happen]
   - Actual: [What happened]
   - Severity: Critical/High/Medium/Low
```

### Notes

```
[Any additional observations]
```

---

**Start from Step 1 and work through all steps systematically.**
Each step builds on the previous one. Don't skip ahead!

Good luck! 🎉
