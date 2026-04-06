@echo off
REM Quick launcher for emulator deployment

echo Starting emulator launcher...
set JAVA_HOME=C:\java17
cd /d D:\quarryforce\quarryforce_mobile

echo.
echo Checking for running emulator...
adb devices | findstr "emulator-"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo No emulator running. Start one in Android Studio first.
    pause
    exit /b 1
)

echo.
echo Deploying app to emulator...
flutter run

pause
