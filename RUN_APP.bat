#!/bin/bash
# QuarryForce Mobile App - Complete One-Time Setup
# Run this once before each development session

echo "===================================="
echo "QuarryForce - Setup & Launch"
echo "===================================="

# Step 1: Backend setup
echo ""
echo "[1] Backend: Starting PHP on 0.0.0.0:8000..."
cd /d d:\quarryforce\qft-deployment
taskkill /F /IM php.exe >nul 2>&1
start "QuarryForce API Backend" cmd /k "d:\xampp\php\php.exe -S 0.0.0.0:8000"
timeout /t 3 /nobreak >nul
echo "✓ Backend started (check for new PHP window)"

# Step 2: ADB setup
echo ""
echo "[2] ADB: Setting up reverse tunnel..."
adb reverse tcp:8000 tcp:8000
echo "✓ Reverse tunnel: tcp:8000 (device) → tcp:8000 (host)"

# Step 3: Verify device
echo ""
echo "[3] Device check..."
adb devices | find "ZA222LDXSB" >nul
if errorlevel 1 (
    echo "✗ Device not found!"
    exit /b 1
) else (
    echo "✓ Device connected: Moto G34 5G"
)

# Step 4: Launch app
echo ""
echo "[4] Launching app..."
set JAVA_HOME=C:\java17
cd /d D:\quarryforce\quarryforce_mobile
flutter run -d ZA222LDXSB

echo ""
echo "===================================="
echo "App is running!"
echo "Login: rajesh (no password)"
echo "===================================="
