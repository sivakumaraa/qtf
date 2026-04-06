@echo off
REM ============================================
REM  QuarryForce - Complete Setup & Launch
REM ============================================

echo.
echo ╔═══════════════════════════════════════════════╗
echo ║  QUARRYFORCE SETUP & LAUNCH SCRIPT            ║
echo ║  Runs on: Phone (ZA222LDXSB) + Tablet        ║
echo ╚═══════════════════════════════════════════════╝
echo.

REM Set Java home
set JAVA_HOME=C:\java17

REM Step 1: Kill stuck processes
echo [1/5] Cleaning up processes...
taskkill /F /IM php.exe >nul 2>&1
taskkill /F /IM flutter.exe >nul 2>&1
taskkill /F /IM dart.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Step 2: Start PHP backend
echo [2/5] Starting PHP backend...
cd /d d:\quarryforce\qft-deployment
start "" d:\xampp\php\php.exe -S 0.0.0.0:8000
timeout /t 3 /nobreak >nul

REM Step 3: Test backend
echo [3/5] Testing backend...
for /f %%i in ('curl -s http://127.0.0.1:8000/api/test 2^>nul') do (
    echo %%i | findstr /I "Online" >nul
    if !errorlevel! equ 0 (
        echo   ✓ Backend online
    ) else (
        echo   ⚠ Backend may need more time
    )
)

REM Step 4: Setup ADB tunnels
echo [4/5] Setting up ADB tunnels...
adb reverse --remove-all >nul 2>&1
timeout /t 1 /nobreak >nul
adb -s ZA222LDXSB reverse tcp:8000 tcp:8000 >nul 2>&1
adb -s HA1NHP6D reverse tcp:8000 tcp:8000 >nul 2>&1
echo   ✓ Tunnels configured

REM Step 5: Deploy app
echo [5/5] Deploying app...
cd /d D:\quarryforce\quarryforce_mobile
echo   Which device?
echo   [1] Phone (faster)
echo   [2] Tablet
echo   [3] Both
set /p choice="Choose [1-3]: "

if "%choice%"=="1" (
    flutter run -d ZA222LDXSB
) else if "%choice%"=="2" (
    flutter run -d HA1NHP6D
) else (
    echo Deploying to phone first...
    flutter run -d ZA222LDXSB
)

echo.
echo ✓ Done!
pause
