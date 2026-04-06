@echo off
REM QuarryForce Local Development Startup Script
REM Uses XAMPP for PHP and MySQL
REM Starts PHP backend and React admin dashboard

echo.
echo ====================================================
echo   QuarryForce Local Development Environment
echo   Using XAMPP
echo ====================================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if npm is installed (needed for React admin-dashboard)
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: npm is not installed or not in PATH
    echo npm is required for React admin-dashboard
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Set XAMPP path (adjust if installed in different location)
set XAMPP_PATH=D:\xampp
set PHP_PATH=%XAMPP_PATH%\php
set MYSQL_PATH=%XAMPP_PATH%\mysql

REM Check if XAMPP PHP exists
if not exist "%PHP_PATH%\php.exe" (
    echo ERROR: PHP not found at %PHP_PATH%
    echo Please ensure XAMPP is properly installed at: %XAMPP_PATH%
    pause
    exit /b 1
)

echo [✓] npm and XAMPP PHP are available
echo.

set ROOT_DIR=%~dp0

REM Install admin dashboard dependencies
if not exist "%ROOT_DIR%admin-dashboard\node_modules" (
    echo [1/3] Installing admin-dashboard dependencies...
    cd /d "%ROOT_DIR%admin-dashboard"
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to install admin-dashboard dependencies
        pause
        exit /b 1
    )
    echo [✓] Admin dashboard dependencies installed
    echo.
)

echo [2/3] Checking PHP backend configuration...
if not exist "%ROOT_DIR%qft-deployment\.env" (
    echo Creating default .env file...
    (
        echo DB_HOST=localhost
        echo DB_USER=root
        echo DB_PASS=
        echo DB_NAME=quarryforce_db
    ) > "%ROOT_DIR%qft-deployment\.env"
    echo [✓] Created .env with default XAMPP settings
    echo Note: Update .env if you have MySQL password set
)
echo.

echo [3/3] Starting development servers...
echo.
echo ====================================================
echo   Starting Node.js Backend Server (Port 8000)
echo ====================================================
echo Backend: http://localhost:8000
echo API: http://localhost:8000/api/
echo Make sure MySQL is running in XAMPP!
echo.

REM Start Node.js backend server
start "QuarryForce Node.js Backend" cmd /k "cd /d %ROOT_DIR%qft-deployment && node index.js"

REM Wait for backend to start
timeout /t 2 /nobreak

echo.
echo ====================================================
echo   Starting Admin Dashboard (React)
echo ====================================================
echo Dashboard: http://localhost:3000
echo.

REM Start React development server
start "QuarryForce Admin Dashboard" cmd /k "cd /d %ROOT_DIR%admin-dashboard && npm start"

echo.
echo ====================================================
echo   Development Environment Started!
echo ====================================================
echo.
echo Node.js Backend (Port 8000):
echo   - URL: http://localhost:8000
echo   - API Root: GET http://localhost:8000/api/
echo   - Admin APIs: http://localhost:8000/api/admin/...
echo.
echo Admin Dashboard (Port 3000):
echo   - URL: http://localhost:3000
echo   - React Dev Server with auto-reload
echo.
echo XAMPP Configuration:
echo   - PHP: %PHP_PATH%
echo   - Database: Update credentials in qft-deployment\.env
echo   - MySQL: Ensure MySQL service is running in XAMPP Control Panel
echo.
echo Important:
echo   - Open XAMPP Control Panel and START the MySQL service
echo   - Database credentials in .env must match XAMPP MySQL setup
echo.
echo Logs will appear in the respective console windows.
echo Close a console window to stop that service.
echo.
pause


