@echo off
REM === QuarryForce Complete Startup Script ===
echo.
echo ====================================
echo QuarryForce Mobile App - Full Setup
echo ====================================
echo.

REM Step 1: Kill old processes
echo [1] Stopping old processes...
taskkill /F /IM php.exe >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1
timeout /t 1 /nobreak >nul

REM Step 2: Start PHP backend
echo [2] Starting PHP backend on 0.0.0.0:8000...
cd /d d:\quarryforce\qft-deployment
start "PHP Server" cmd /k "d:\xampp\php\php.exe -S 0.0.0.0:8000"
timeout /t 3 /nobreak >nul

REM Step 3: Setup ADB reverse tunneling
echo [3] Setting up ADB reverse tunnel (device ^> host)...
adb reverse tcp:8000 tcp:8000
adb reverse --list

REM Step 4: Verify backend is responding
echo.
echo [4] Testing backend connectivity...
curl.exe http://127.0.0.1:8000/api/test

REM Step 5: Check device
echo.
echo [5] Checking device connection...
flutter devices

REM Step 6: Launch Flutter app
echo.
echo [6] Launching Flutter app on device...
set JAVA_HOME=C:\java17
cd /d D:\quarryforce\quarryforce_mobile
flutter run -d ZA222LDXSB

pause
