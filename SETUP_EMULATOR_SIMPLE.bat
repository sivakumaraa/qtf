@echo off
REM Android Emulator Setup - Simple Version

cls
echo.
echo ========================================
echo ANDROID EMULATOR SETUP
echo ========================================
echo.

setlocal enabledelayedexpansion
cd /d D:\quarryforce

set SDK_PATH=C:\Android\Sdk

REM Step 1: Check SDK
echo [Step 1] Checking Android SDK...
if not exist "%SDK_PATH%" (
    echo ERROR: Android SDK not found at %SDK_PATH%
    echo.
    echo Please install Android SDK first, or the SDK isn't at that location
    echo.
    pause
    exit /b 1
)
echo  OK: SDK found at %SDK_PATH%
echo.

REM Step 2: Check system images
echo [Step 2] Checking system images...
if not exist "%SDK_PATH%\system-images" (
    goto no_images
)

REM Count available images
setlocal enabledelayedexpansion
set IMAGE_COUNT=0
for /f %%i in ('dir "%SDK_PATH%\system-images" /s /b /ad ^| find /c /v ""') do set IMAGE_COUNT=%%i

if %IMAGE_COUNT% lss 5 (
    goto no_images
)

echo  OK: Found system images
echo.

REM Step 3: Find cmdline-tools
echo [Step 3] Locating command line tools...
if not exist "%SDK_PATH%\cmdline-tools" (
    goto no_cmdline
)
if not exist "%SDK_PATH%\emulator" (
    goto no_emulator
)

echo  OK: Tools found
echo.

REM Step 4: Launch emulator
echo [Step 4] Launching emulator...
echo.
echo Please wait, this may take 30-60 seconds on first launch...
echo.

set JAVA_HOME=C:\java17
cd /d D:\quarryforce\quarryforce_mobile

echo Running: flutter run
echo.
call flutter run

goto end

:no_images
echo  MISSING: No system images found
echo.
echo ACTION REQUIRED:
echo  1. Download Android system image (~1GB)
echo  2. Open: C:\Android\Sdk (or SDK Manager)
echo  3. Download Android 13+ with x86_64 architecture
echo.
echo Or try using physical devices:
echo  - Run: D:\quarryforce\LAUNCH_DEVICES.bat
echo.
pause
exit /b 1

:no_cmdline
echo  MISSING: Command line tools not found
echo.
echo ACTION REQUIRED:
echo  1. Download from: https://developer.android.com/studio/command-line
echo  2. Extract to: C:\Android\Sdk
echo.
pause
exit /b 1

:no_emulator
echo  MISSING: Emulator tools not found
echo.
echo ACTION REQUIRED:
echo  1. Download Android emulator tools via SDK Manager
echo.
pause
exit /b 1

:end
echo.
echo Done!
pause
