@echo off
setlocal enabledelayedexpansion

REM QuarryForce Mobile - Manual Installation Script
REM This script builds and installs the app directly to the connected tablet

echo.
echo ========================================
echo QuarryForce Tablet Installation
echo ========================================
echo.

REM Set Java environment
set JAVA_HOME=C:\java17
set PATH=C:\java17\bin;%PATH%

cd /d D:\quarryforce\quarryforce_mobile

REM Step 1: Verify tablet
echo [1/4] Checking tablet connection...
adb devices | findstr HA1NHP6D > nul
if errorlevel 1 (
    echo ERROR: Tablet HA1NHP6D not found!
    pause
    exit /b 1
)
echo OK - Tablet detected

REM Step 2: Clean
echo.
echo [2/4] Cleaning previous build...
call flutter clean
if errorlevel 1 (
    echo ERROR: Clean failed
    pause
    exit /b 1
)
echo OK

REM Step 3: Build APK
echo.
echo [3/4] Building APK (this will take 1-3 minutes)...
call flutter build apk
if errorlevel 1 (
    echo ERROR: Build failed
    pause
    exit /b 1
)
echo OK - APK built

REM Step 4: Install APK
echo.
echo [4/4] Installing APK to tablet...
set APK_PATH=D:\quarryforce\quarryforce_mobile\build\app\outputs\flutter-apk\app-release.apk
if not exist "!APK_PATH!" (
    REM Try debug APK
    set APK_PATH=D:\quarryforce\quarryforce_mobile\build\app\outputs\flutter-apk\app-debug.apk
)

if not exist "!APK_PATH!" (
    echo ERROR: APK not found at !APK_PATH!
    pause
    exit /b 1
)

echo Installing: !APK_PATH!
adb -s HA1NHP6D install -r "!APK_PATH!"
if errorlevel 1 (
    echo ERROR: Installation failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo.
echo The app should now be on your tablet.
echo Check the tablet screen now!
echo.
pause
