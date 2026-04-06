@echo off
REM Genymotion Setup and Flutter Deployment Script
REM This script helps you set up Genymotion and deploy QuarryForce app

setlocal enabledelayedexpansion

echo.
echo ========================================
echo GENYMOTION SETUP FOR QUARRYFORCE
echo ========================================
echo.

REM Check if Genymotion is installed
set GENYMOTION_PATH=C:\Program Files\Genymobile\Genymotion\genymotion.exe

if not exist "%GENYMOTION_PATH%" (
    echo.
    echo [!] GENYMOTION NOT FOUND
    echo.
    echo Genymotion needs to be downloaded and installed first.
    echo.
    echo STEPS:
    echo 1. Go to: https://www.genymotion.com/download/
    echo 2. Create FREE account (or sign in)
    echo 3. Download "Genymotion for Windows"
    echo 4. Run the installer
    echo 5. Follow the wizard (accept defaults)
    echo 6. Re-run this script when done
    echo.
    pause
    exit /b 1
)

echo [OK] Genymotion found at:
echo  %GENYMOTION_PATH%
echo.

REM Check if Flutter is ready
set JAVA_HOME=C:\java17
set PATH=C:\java17\bin;%PATH%

cd /d D:\quarryforce\quarryforce_mobile
if errorlevel 1 (
    echo ERROR: Could not find Flutter project
    pause
    exit /b 1
)

echo [OK] Flutter project found
echo.

REM List available devices
echo ========================================
echo AVAILABLE GENYMOTION DEVICES
echo ========================================
echo.

REM Note: This is a placeholder - Genymotion CLI may vary
echo Starting Genymotion...
echo.
echo Once Genymotion opens:
echo 1. Click on an Android device (or create one)
echo 2. Click the "Start" button (play icon)
echo 3. Wait for it to boot (~30 seconds)
echo 4. Come back here and press a key
echo.
pause

echo.
echo ========================================
echo CHECKING FOR RUNNING EMULATOR
echo ========================================
echo.

REM Get list of connected devices
echo Checking ADB devices...
adb devices > %temp%\adb_devices.txt
type %temp%\adb_devices.txt

echo.
echo ========================================
echo DEPLOYING FLUTTER APP
echo ========================================
echo.

echo [Step 1] Reset build cache...
flutter clean

echo.
echo [Step 2] Getting packages...
flutter pub get

echo.
echo [Step 3] Building APK...
flutter build apk

if errorlevel 1 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

echo.
echo [Step 4] Deploying to emulator...
echo.
flutter run

echo.
echo ========================================
echo DEPLOYMENT COMPLETE
echo ========================================
echo.
echo Your app is now running in the emulator!
echo.

pause
