# 📱 Run Flutter App on Android Device via USB

Complete step-by-step guide to test QuarryForce on real Android phone via USB.

---

## ✅ Prerequisites

- ✅ Android phone
- ✅ USB cable
- ✅ Flutter installed
- ✅ Android SDK installed
- ✅ USB debugging enabled on phone (we'll verify)

---

## 🔧 Step 1: Enable USB Debugging on Phone

### On Android Phone:

1. **Open Settings** → Search for "Developer Options"

2. **If Developer Options don't exist:**
   - Go to: Settings → About Phone
   - Find "Build Number"
   - **Tap "Build Number" 7 times rapidly**
   - You'll see: "You are now a developer!"
   - Go back to Settings → Developer Options will now appear

3. **In Developer Options:**
   - Enable: **USB Debugging** (toggle ON)
   - Enable: **Install via USB** (toggle ON)
   - Enable: **File Transfer** mode (set to this in USB options)

4. **Keep phone screen ON** (prevent screen lock during install)

---

## 🖥️ Step 2: Connect Phone via USB

1. **Plug phone into computer** with USB cable
2. **On phone:** Allow USB debugging when prompted
   - You'll see: "Allow USB debugging from this computer?"
   - Tap: **Allow**
   - Check: **Always allow from this computer**

3. **Verify connection:**

```powershell
flutter devices
```

**Expected output:**

```
2 connected devices:

SM G950F (mobile)   • FA89.... • android • Android 10 (API 29)
Chrome              • chrome   • web-web • Chrome 120.0.0-dev
```

If you see your phone listed ✅ → Continue to Step 3

If NOT listed ❌ → See Troubleshooting section below

---

## 📦 Step 3: Install Flutter Dependencies

```powershell
cd d:\quarryforce\quarryforce_mobile

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get
```

**Wait for completion** (usually 1-2 minutes)

---

## ⚙️ Step 4: Build APK for Device (Optional)

**Option A: Direct install to device** (faster):

```powershell
# Just run - it will build and install directly
flutter run
```

**Option B: Build APK file first** (if you want to share the APK):

```powershell
flutter build apk --release
# Creates: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🚀 Step 5: Run App on Phone

### **Method 1: Direct Run (Recommended)**

```powershell
cd d:\quarryforce\quarryforce_mobile

# Run directly on device
flutter run
```

**What happens:**

1. Builds the app
2. Installs on your phone
3. Launches the app automatically
4. Shows debug logs in terminal

**Expected output:**

```
Launching lib/main.dart on SM G950F in debug mode...
...
✓ Built build/app/outputs/apk/debug/app-debug.apk
Installing and launching...
✓ Installed build/app/outputs/apk/debug/app-debug.apk
Launching....

Syncing files to device SM G950F...
```

Then app appears on your phone! 🎉

### **Method 2: Using ADB (Alternative)**

```powershell
# If flutter run doesn't work, try:
adb install build/app/outputs/flutter-apk/app-release.apk

# Then open app on phone manually
```

---

## ✅ Step 6: Test App on Phone

Once app launches on your phone:

### **Test 1: Login**

```
Email: demo@quarryforce.local
Tap: Login
Expected: Success → Dashboard loads
```

### **Test 2: Check GPS Permission**

- App will ask: "Allow location access?"
- Tap: "Allow" or "Allow only while using the app"

### **Test 3: Check In**

```
1. Tap: "Check In"
2. Tap: "Get Location"
3. Wait for GPS to acquire location
4. Tap: "Submit"
Expected: Location captured, check-in succeeds
```

### **Test 4: Submit Visit**

```
1. Tap: "Record Visit"
2. Select customer
3. Tap: "Submit Visit"
Expected: Success message
```

### **Test 5: Verify in Admin Dashboard**

```
Browser: https://valviyal.com/qft
Check "Visit History" → Should see your visit!
```

---

## 🔍 Troubleshooting

### Problem: "No Android device detected"

**Solution 1: Check cable**

```powershell
adb devices
```

Should show:

```
List of attached devices
FA89H7A6K7K0U        device
```

If empty ❌:

- Try different USB cable
- Try different USB port (USB 3.0 port)
- Reconnect phone

**Solution 2: Reinstall ADB drivers**

```powershell
# In Android Studio:
# Tools → SDK Manager → SDK Tools
# Uncheck and recheck "Android SDK Platform-Tools"
# Click "Apply"
```

**Solution 3: Restart ADB**

```powershell
adb kill-server
adb start-server
adb devices
```

---

### Problem: "USB Debugging not available"

**Solution:**

1. Go to Settings → About Phone
2. Tap "Build Number" 7 times
3. Developer Options will unlock in Settings
4. Enable "USB Debugging"

---

### Problem: "Debug app runs slow"

**Build Release version instead** (faster, optimized):

```powershell
flutter run --release
```

This builds optimized version and still installs on device.

---

### Problem: "App crashes on startup"

**Check logs:**

```powershell
flutter logs
```

Share the error message and I can help fix it.

---

### Problem: "Can't connect to production API"

**Check:**

1. Phone WiFi is ON and connected
2. Same network as your computer
3. API is responding: Test in browser on phone: `https://valviyal.com/qft/api/test`

---

## 📊 Testing Checklist

```
Phone setup:
  [ ] USB Debugging enabled
  [ ] USB cable connected
  [ ] "Allow" clicked on phone

Flutter:
  [ ] flutter devices shows phone
  [ ] flutter run completes without errors
  [ ] App appears on phone

App testing:
  [ ] Login works (demo@quarryforce.local)
  [ ] Permission requests handled
  [ ] Check in captures GPS
  [ ] Submit visit succeeds
  [ ] Data in admin dashboard

Troubleshooting:
  [ ] Check logs with: flutter logs
  [ ] Check API: https://valviyal.com/qft/api/test
  [ ] Verify WiFi connection
```

---

## 🎯 Quick Reference

| Command                 | Purpose                           |
| ----------------------- | --------------------------------- |
| `flutter devices`       | List connected devices            |
| `flutter run`           | Build and run on connected device |
| `flutter run --release` | Run optimized version             |
| `flutter logs`          | Show app debug logs               |
| `adb devices`           | List Android devices via ADB      |
| `adb logcat`            | Show device system logs           |

---

## ⏱️ Expected Times

| Task                  | Time       |
| --------------------- | ---------- |
| Enable USB debugging  | 2 min      |
| Verify connection     | 1 min      |
| First build & install | 5-10 min   |
| Subsequent runs       | 2-3 min    |
| **Total**             | **15 min** |

---

## 🚀 Complete Workflow

```powershell
# 1. Clean & setup
cd d:\quarryforce\quarryforce_mobile
flutter clean
flutter pub get

# 2. Verify device connected
flutter devices
# Should show your phone

# 3. Run app
flutter run
# App installs and launches on phone

# 4. Watch logs
flutter logs
# In another terminal to see what app is doing
```

---

## ✨ Once Testing Complete

After testing on device:

1. **Build release APK** (for sharing/distribution):

```powershell
flutter build apk --release
# Creates: build/app/outputs/flutter-apk/app-release.apk
```

2. **Share APK with team:**
   - Send file: `build/app/outputs/flutter-apk/app-release.apk`
   - They can install via: Email, Google Drive, etc.

3. **Upload to Google Play Store:**
   - Requires account and review process
   - Takes 24-48 hours for approval

---

**Ready? Step 1: Enable USB Debugging on your phone!** 📱

Come back with the output of `flutter devices` and I'll help troubleshoot if needed! 👇
