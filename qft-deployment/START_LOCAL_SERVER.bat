@echo off
echo Starting QuarryForce API Server on localhost...
echo ========================================

REM Check if PHP is available
where php >nul 2>nul
if errorlevel 1 (
    echo [ERROR] PHP not found in PATH
    echo Please install PHP or add it to your PATH environment variable
    echo Recommended: Install XAMPP or WampServer
    pause
    exit /b 1
)

REM Get PHP version
php --version

REM Navigate to deployment folder
cd /d "%~dp0"

REM Start PHP built-in server
echo.
echo Starting server on http://localhost:8000
echo Press Ctrl+C to stop the server
echo.
php -S localhost:8000

pause
