@echo off
REM ==========================================
REM QuarryForce - Local Development Setup
REM ==========================================
REM Windows Batch version of the setup script

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo   QuarryForce Local Development Setup
echo ==========================================
echo.

REM Check prerequisites
echo Checking prerequisites...

where node >nul 2>nul
if errorlevel 1 (
    echo X Node.js not found - Please install from https://nodejs.org
    pause
    exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
    echo X npm not found - Please install Node.js
    pause
    exit /b 1
)

echo.
echo Prerequisites OK
echo.

REM Menu
echo =========================================
echo What would you like to do?
echo =========================================
echo 1) Install all dependencies
echo 2) Start Backend only ^(Port 3000^)
echo 3) Start Admin Dashboard only ^(Port 3001^)
echo 4) Start all services ^(Backend + Dashboard^)
echo 5) Rebuild Flutter Web
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto install_deps
if "%choice%"=="2" goto backend_only
if "%choice%"=="3" goto dashboard_only
if "%choice%"=="4" goto start_all
if "%choice%"=="5" goto flutter_web
goto invalid

:install_deps
echo.
echo Installing Backend dependencies...
cd /d d:\quarryforce\qft-deployment
if not exist node_modules (
    call npm install
    if errorlevel 1 goto error
) else (
    echo Backend dependencies already installed
)

echo.
echo Installing Admin Dashboard dependencies...
cd /d d:\quarryforce\admin-dashboard
if not exist node_modules (
    call npm install
    if errorlevel 1 goto error
) else (
    echo Dashboard dependencies already installed
)

echo.
echo Getting Flutter dependencies...
cd /d d:\quarryforce\quarryforce_mobile
call flutter pub get
if errorlevel 1 goto error

echo.
echo All dependencies installed!
pause
goto end

:backend_only
echo.
echo Starting Backend ^(Port 3000^)...
cd /d d:\quarryforce\qft-deployment
call npm start
goto end

:dashboard_only
echo.
echo Starting Admin Dashboard ^(Port 3001^)...
cd /d d:\quarryforce\admin-dashboard
call npm start
goto end

:start_all
echo.
echo Starting all services...
echo.
echo Opening Backend in new window...
start "QuarryForce Backend - Port 3000" cmd /k "cd /d d:\quarryforce\qft-deployment && npm start"

timeout /t 3 /nobreak

echo Opening Admin Dashboard in new window...
start "QuarryForce Admin Dashboard - Port 3001" cmd /k "cd /d d:\quarryforce\admin-dashboard && npm start"

echo.
echo Services started! Check the new windows.
echo.
echo Backend: http://localhost:3000
echo Dashboard: http://localhost:3001
echo.
pause
goto end

:flutter_web
echo.
echo Building Flutter Web...
cd /d d:\quarryforce\quarryforce_mobile
call flutter build web
if errorlevel 1 goto error

echo.
echo Starting Flutter Web Server...
call flutter run -d web-server
goto end

:invalid
echo Invalid choice
pause
goto end

:error
echo.
echo Error occurred! Check the output above.
pause
goto end

:end
echo.
echo Done!
