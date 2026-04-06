@echo off
REM ============================================
REM  Android Emulator Setup - Simpler Version
REM ============================================

setlocal enabledelayedexpansion

cls
echo.
echo ================================================
echo  ANDROID EMULATOR SETUP
echo ================================================
echo.

cd /d D:\quarryforce
set SDK_PATH=C:\Android\Sdk

REM Check prerequisites
echo [CHECK 1] Verifying Android SDK...
if not exist "%SDK_PATH%" (
    echo ERROR: Android SDK not found at %SDK_PATH%
    echo.
    pause
    exit /b 1
)
echo OK: Android SDK found

echo.
echo [CHECK 2] Looking for system image...
if not exist "%SDK_PATH%\system-images" (
    echo ERROR: No system images found
    echo You need to download at least one system image
    echo.
    echo Quick fix - Download manually:
    echo 1. Go to: https://developer.android.com/studio/run/managing-avds
    echo 2. Or use SDK Manager
    echo.
    pause
    exit /b 1
)

REM Find an available system image
set FOUND_IMAGE=0
for /d %%A in (%SDK_PATH%\system-images\*) do (
    for /d %%B in (%%A\*) do (
        for /d %%C in (%%B\*) do (
            if "%%~nC"=="x86_64" (
                set FOUND_IMAGE=1
                set IMAGE_PATH=%%A\%%B\%%C
                echo OK: Found system image at %%A\%%B
            )
        )
    )
)

if %FOUND_IMAGE%==0 (
    echo ERROR: No suitable system image found
    echo.
    echo Action needed: Download system image first
    echo Please visit Android SDK Manager and download:
    echo - Android 13 (or later)
    echo - x86_64 architecture
    echo.
    pause
    exit /b 1
)

REM Find avdmanager
set AVD_MGR=
for /d %%d in (%SDK_PATH%\cmdline-tools\*) do (
    if exist "%%d\bin\avdmanager.bat" (
        set AVD_MGR=%%d\bin\avdmanager.bat
        goto found_avd
    )
)

:found_avd
if "%AVD_MGR%"=="" (
    echo ERROR: avdmanager not found
    exit /b 1
)

echo OK: Found avdmanager at %AVD_MGR%
echo.

REM Step 2: Check/install system images
echo [2] Checking system images...
if exist "%SDK_PATH%\system-images\android-33\x86_64" (
    echo OK: System image found (Android 13, x86_64)
    set SYS_IMG=android-33/x86_64
) else (
    echo Downloading system image (this may take 5-10 minutes)...
    echo.
    
    REM Use sdkmanager to install system image
    set SDK_MGR=%SDK_PATH%\cmdline-tools\latest\bin\sdkmanager.bat
    if exist "!SDK_MGR!" (
        call "!SDK_MGR!" "system-images;android-33;google_apis;x86_64" --sdk_root=%SDK_PATH%
        set SYS_IMG=android-33/google_apis/x86_64
    ) else (
        echo ERROR: sdkmanager not found
        exit /b 1
    )
)

echo.
echo [3] Creating emulator...
call "%AVD_MGR%" create avd -n quarry_emu -k "system-images;android-33;google_apis;x86_64" -d 5 -f

echo.
echo [4] Launching emulator...
start "" "%SDK_PATH%\emulator\emulator.exe" -avd quarry_emu -no-boot-anim -wipe-data

echo Waiting 60 seconds for emulator to boot...
timeout /t 60 /nobreak

echo.
echo [5] Deploying app...
set JAVA_HOME=C:\java17
cd /d D:\quarryforce\quarryforce_mobile
flutter run

echo.
echo Done!
pause
