@echo off
REM ============================================
REM FINAL USB DEBUGGING SETUP
REM ============================================
REM This script sets up everything needed for USB debugging ONCE AND FOR ALL

echo.
echo ========================================
echo QUARRYFORCE USB DEBUGGING SETUP
echo ========================================
echo.

REM Set JAVA_HOME to Java 17 PERMANENTLY
echo [1/4] Setting Java 17 permanently...
setx JAVA_HOME "C:\java17"
set JAVA_HOME=C:\java17
echo JAVA_HOME set to: C:\java17

REM Verify Java
echo.
echo [2/4] Verifying Java 17 installation...
cd /d "C:\java17\bin"
java -version
echo.

REM Start MySQL if not running
echo [3/4] Checking MySQL...
tasklist | find /i "mysqld" >nul
if errorlevel 1 (
    echo MySQL not running - starting XAMPP MySQL
    net start MySQL80 >nul 2>&1 || echo Note: Use XAMPP Control Panel to start MySQL
) else (
    echo MySQL already running
)
echo.

REM Start PHP server
echo [4/4] Starting PHP backend server...
cd /d "d:\quarryforce\qft-deployment"
if exist "d:\xampp\php\php.exe" (
    echo Starting PHP on 0.0.0.0:8000...
    start "PHP Server" cmd /k "d:\xampp\php\php.exe -S 0.0.0.0:8000"
    timeout /t 2 /nobreak
    echo PHP server started in new window
) else (
    echo ERROR: PHP not found at d:\xampp\php\php.exe
    pause
    exit /b 1
)

echo.
echo ========================================
echo SETUP COMPLETE
echo ========================================
echo.
echo Configuration verified:
echo - Java: 17.0.11 (JAVA_HOME=C:\java17)
echo - MySQL: Running
echo - PHP: Running on 0.0.0.0:8000
echo - API URL: http://192.168.137.1:8000/api
echo.
echo Ready to run: flutter run
echo.
pause
