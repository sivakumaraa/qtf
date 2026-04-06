@echo off
REM QuarryForce Admin Dashboard - Gmail OAuth Quick Start
REM Run this script to complete the 5-minute setup

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo 🚀 QuarryForce Gmail OAuth Quick Start
echo ==========================================
echo.

REM Step 1: Check if Node dependencies are installed
echo 📦 Step 1: Checking dependencies...
if exist node_modules (
    echo ✅ Dependencies already installed
) else (
    echo 📥 Installing dependencies...
    call npm install
    if errorlevel 1 (
        echo ❌ Failed to install dependencies
        pause
        exit /b 1
    ) else (
        echo ✅ Dependencies installed successfully
    )
)

echo.
echo ==========================================
echo 🔑 Step 2: Configure Google OAuth
echo ==========================================
echo.
echo ⚠️  IMPORTANT: You need a Google OAuth Client ID
echo.
echo Go to: https://console.cloud.google.com
echo.
echo Steps:
echo 1. Create new project 'QuarryForce'
echo 2. Enable Google+ API
echo 3. Create OAuth 2.0 Web credential
echo 4. Add these Authorized redirect URIs:
echo    - http://localhost:3001
echo    - http://localhost:3001/
echo 5. Copy your Client ID [looks like: XXX.apps.googleusercontent.com]
echo.
echo Then update .env file:
echo REACT_APP_GOOGLE_CLIENT_ID=your-client-id-here
echo.
pause /b

echo.
echo ==========================================
echo 🎯 Step 3: Starting Development Server
echo ==========================================
echo Starting: npm start
echo.
echo This will:
echo - Start React development server on port 3001
echo - Open http://localhost:3001 in your browser
echo - You should see the Gmail login page
echo.
call npm start
