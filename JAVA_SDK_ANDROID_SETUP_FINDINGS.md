# Java SDK & Android Setup - Configuration Findings

**Date:** March 25, 2026  
**Workspace:** d:\quarryforce

---

## 🔍 Summary of Findings

This document consolidates all Java SDK, Android SDK, NDK, and related configuration information found in the workspace.

---

## 📁 Key Configuration Files

### 1. **Local Properties** - [quarryforce_mobile/android/local.properties](quarryforce_mobile/android/local.properties)

```properties
sdk.dir=C:\\Users\\sivak\\AppData\\Local\\Android\\Sdk
flutter.sdk=D:\\flutter\\flutter
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1
```

**Key Findings:**

- Android SDK located at: `C:\Users\sivak\AppData\Local\Android\Sdk`
- Flutter SDK located at: `D:\flutter\flutter`
- Build mode is release
- Version 1.0.0, build code 1

---

### 2. **Gradle Properties** - [quarryforce_mobile/android/gradle.properties](quarryforce_mobile/android/gradle.properties)

```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError --enable-native-access=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED
android.useAndroidX=true
android.ndkVersion=27.0.12077973
android.buildToolsVersion=36.1.0
kotlin.incremental=false
cmake.dir=C:\\Users\\sivak\\AppData\\Local\\Android\\Sdk\\cmake
```

**Key Findings:**

- JVM configured with **8GB max heap** (indicates memory-intensive builds)
- Java module access enabled for native compilation
- **NDK Version: 27.0.12077973** (latest)
- **Build Tools Version: 36.1.0** (API Level 36)
- CMake configured at SDK location
- AndroidX enabled

---

### 3. **App Build Configuration** - [quarryforce_mobile/android/app/build.gradle.kts](quarryforce_mobile/android/app/build.gradle.kts)

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlinOptions {
    jvmTarget = JavaVersion.VERSION_17.toString()
}

buildToolsVersion = "36.1.0"
```

**Key Findings:**

- **Java Version: 17** (required for modern Android builds)
- **Kotlin JVM Target: 17**
- Build Tools: 36.1.0 (consistent across config)
- **IMPORTANT:** Java 17 is required, NOT Java 11/8

---

## 🔧 Android SDK Setup

### Current Installation

**Location:** `C:\Users\sivak\AppData\Local\Android\Sdk`  
**Status:** ✅ Installed

### Required Components

| Component       | Version       | Status     | Location                   |
| --------------- | ------------- | ---------- | -------------------------- |
| NDK             | 27.0.12077973 | ✅         | `sdk/ndk/27.0.12077973`    |
| SDK Build Tools | 36.1.0        | ✅         | `sdk/build-tools/36.1.0`   |
| CMake           | 3.22.1        | ✅         | `sdk/cmake/3.22.1`         |
| Platform SDK    | API 36+       | ✅         | `sdk/platforms/`           |
| Cmdline Tools   | Latest        | ⚠️ Missing | `sdk/cmdline-tools/latest` |

---

## ⚙️ Java Configuration

### Java Version Requirements

**Required:** Java 17 or higher

**Locations to check:**

- `JAVA_HOME` environment variable should point to Java 17+
- Android Studio bundled JBR: `D:\Program Files\Android\Android Studio\jbr\bin\java`

### JVM Arguments (from gradle.properties)

```
-Xmx8G                    # Max heap: 8GB
-XX:MaxMetaspaceSize=4G   # Metaspace: 4GB
-XX:ReservedCodeCacheSize=512m
-XX:+HeapDumpOnOutOfMemoryError
--enable-native-access=ALL-UNNAMED
--add-opens java.base/java.lang=ALL-UNNAMED
--add-opens java.base/java.util=ALL-UNNAMED
--add-opens java.base/java.io=ALL-UNNAMED
```

**Purpose:** These flags enable native compilation and interop, required for NDK and machine learning libraries.

---

## 📚 Documentation Files

### Android Emulator Setup - [PHASE_3_STATUS.md](PHASE_3_STATUS.md#-android-emulator-setup-guide)

**Status:** ⚠️ Android cmdline-tools missing (prevents automated emulator creation)

**Workaround:** Use Android Studio GUI:

1. Open Android Studio at `D:\Program Files\Android\Android Studio`
2. Go to **Tools → Device Manager**
3. Create new virtual device (Pixel 5 or 8 Pro)
4. Select API 36+
5. Name it "quarry_phone"

**Emulator Launch Command:**

```powershell
$env:ANDROID_SDK_ROOT="C:\Users\sivak\AppData\Local\Android\Sdk"
flutter emulators --launch quarry_phone
```

### Local Development Setup - [LOCAL_DEVELOPMENT_SETUP.md](LOCAL_DEVELOPMENT_SETUP.md)

Contains sections on:

- Flutter dependencies installation: `flutter pub get`
- Flutter web build: `flutter build web`
- Flutter web run: `flutter run -d web-server`
- Troubleshooting Flutter issues (lines 411-423)

### Phase 3 Status - [PHASE_3_STATUS.md](PHASE_3_STATUS.md)

**Known Issues:**

- ❌ Android cmdline-tools not installed
- ❌ Emulator creation fails without SDK components
- ✅ Recommendation: Use Android Studio installation

---

## 🛠️ Setup & Download Scripts

### 1. **download_ndk_auto.py** - Android NDK Auto-Downloader

**Purpose:** Automatically download NDK 27.0.12077973 from Google's CDN

**Installation Path:** `C:\Users\sivak\AppData\Local\Android\Sdk\ndk\27.0.12077973`

**Download URL:** `https://dl.google.com/android/repository/android-ndk-r27-windows.zip`

**Configuration Detected:**

- Extracts to: `sdk/ndk/27.0.12077973`
- Includes clang toolchain for Windows x86_64

### 2. **download_cmake.py** - CMake Downloader

**Purpose:** Download CMake 3.22.1 for C++ build support

**Installation Path:** `C:\Users\sivak\AppData\Local\Android\Sdk\cmake\3.22.1`

### 3. **fix_all_sdk_versions.ps1** - SDK Version Fixer

**Purpose:** Updates all pub cache plugin build.gradle files to support SDK version 36

```powershell
# Fixes compileSdkVersion to 36
# Fixes targetSdkVersion to 36
# Processes all plugins in pub cache
```

---

## 📋 Dart/Flutter Log Analysis - [c:\Users\sivak\AppData\Local\Temp\log-c314.txt](c:\Users\sivak\AppData\Local\Temp\log-c314.txt)

### Environment Status

```
Dart (3.10.4): D:\flutter\flutter\bin\cache\dart-sdk
Flutter (3.38.5): D:\flutter\flutter
Supported platforms: web, android, ios, windows
```

### PATH Configuration

Key entries:

- Flutter: `D:\flutter\flutter\bin`
- Dart SDK: `D:\flutter\flutter\bin\cache\dart-sdk`
- Python: `C:\Users\sivak\AppData\Local\Python\bin`
- npm: `C:\Users\sivak\AppData\Roaming\npm`

### Supported Platforms for Project

```json
{
  "web": true,
  "android": true,
  "ios": true,
  "windows": true,
  "linux": false,
  "macos": false
}
```

---

## 🚀 PowerShell Setup Scripts

### [START_LOCAL_DEVELOPMENT.ps1](START_LOCAL_DEVELOPMENT.ps1)

**Functions:**

1. Install all dependencies (npm packages, flutter pub)
2. Start all services (Backend, Dashboard, Flutter)
3. Individual service startup options
4. Backend: Node.js on port 3000
5. Dashboard: React on port 3001
6. Flutter Web: Port 3002

### [build-and-deploy-flutter-web.ps1](build-and-deploy-flutter-web.ps1)

**Steps:**

1. Verify Flutter installation
2. Clean build directory
3. Get dependencies via `flutter pub get`
4. Build web with `flutter build web --release`
5. Create ZIP for deployment

---

## 🔗 Environment Variables Reference

**Should be set:**

```powershell
# Android SDK
$env:ANDROID_SDK_ROOT="C:\Users\sivak\AppData\Local\Android\Sdk"

# Flutter
$env:FLUTTER_ROOT="D:\flutter\flutter"

# Java (for gradle)
$env:JAVA_HOME="<Java 17 installation path>"
```

---

## ⚠️ Known Issues & Solutions

### Issue 1: Android cmdline-tools Missing

**Symptom:** Cannot create emulator via command line  
**Solution:** Use Android Studio GUI (Device Manager)  
**File:** [PHASE_3_STATUS.md - Line 119](PHASE_3_STATUS.md#-android-emulator-setup-guide)

### Issue 2: Java Version Incompatibility

**Symptom:** Gradle build fails with Java version error  
**Solution:** Ensure Java 17+ is installed and JAVA_HOME is set  
**Config:** [build.gradle.kts - Line 11](quarryforce_mobile/android/app/build.gradle.kts#L11)

### Issue 3: Insufficient Heap Memory

**Symptom:** OutOfMemoryError during build  
**Solution:** Already configured with 8GB - check system memory  
**Config:** [gradle.properties - Line 1](quarryforce_mobile/android/gradle.properties#L1)

### Issue 4: Native Access Module Errors

**Symptom:** Java module access warnings during build  
**Solution:** JVM args already include native access flags  
**Config:** [gradle.properties](quarryforce_mobile/android/gradle.properties#L1)

---

## 📊 Build Configuration Summary

| Setting         | Value                    | Source            |
| --------------- | ------------------------ | ----------------- |
| Android SDK     | 36.1.0                   | gradle.properties |
| NDK Version     | 27.0.12077973            | gradle.properties |
| Java Version    | 17                       | build.gradle.kts  |
| Kotlin JVM      | 17                       | build.gradle.kts  |
| Max Heap        | 8GB                      | gradle.properties |
| CMake Version   | 3.22.1                   | gradle.properties |
| Flutter Channel | Stable                   | local.properties  |
| Min SDK         | flutter.minSdkVersion    | build.gradle.kts  |
| Target SDK      | flutter.targetSdkVersion | build.gradle.kts  |

---

## 🔗 Related Documentation

- **Android Setup:** [PHASE_2a_CORE_SETUP_COMPLETE.md](PHASE_2a_CORE_SETUP_COMPLETE.md)
- **Flutter Mobile Plan:** [PHASE_2_MOBILE_APP_PLAN.md](PHASE_2_MOBILE_APP_PLAN.md)
- **Emulator Guide:** [PHASE_3_STATUS.md](PHASE_3_STATUS.md)
- **Testing Guide:** [PHASE_4_1_FIRST_TEST_RUN_CHECKLIST.md](PHASE_4_1_FIRST_TEST_RUN_CHECKLIST.md)
- **Local Dev Setup:** [LOCAL_DEVELOPMENT_SETUP.md](LOCAL_DEVELOPMENT_SETUP.md)

---

## 🎯 Quick Reference

**For Android Development:**

```powershell
# Set up environment
$env:ANDROID_SDK_ROOT="C:\Users\sivak\AppData\Local\Android\Sdk"

# Get Flutter dependencies
flutter pub get

# List available devices
flutter devices

# Run on Android emulator
flutter run
```

**For Building APK:**

```powershell
cd D:\quarryforce\quarryforce_mobile
flutter build apk --release
```

**For Web:**

```powershell
flutter build web --release
```

---

**Generated:** March 25, 2026  
**Workspace:** d:\quarryforce
