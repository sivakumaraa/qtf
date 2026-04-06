# ==========================================
# QuarryForce - Local Development Setup
# ==========================================
# This script sets up and runs all components locally:
# - Backend (Node.js) - Port 3000
# - Admin Dashboard (React) - Port 3001  
# - Flutter Web App - Port 3002
# - Database (MySQL/XAMPP)

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "🚀 QuarryForce Local Development Setup" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "📋 Checking Prerequisites..." -ForegroundColor Yellow

$missingTools = @()

# Check Node.js
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js not found" -ForegroundColor Red
    $missingTools += "Node.js"
} else {
    $nodeVersion = node --version
    Write-Host "✅ Node.js $nodeVersion found" -ForegroundColor Green
}

# Check npm
if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ npm not found" -ForegroundColor Red
    $missingTools += "npm"
} else {
    $npmVersion = npm --version
    Write-Host "✅ npm $npmVersion found" -ForegroundColor Green
}

# Check Flutter
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️  Flutter not found (optional for web-only development)" -ForegroundColor Yellow
} else {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-Host "✅ Flutter found" -ForegroundColor Green
}

# Check MySQL/XAMPP
Write-Host "`nℹ️  Database Setup:" -ForegroundColor Cyan
Write-Host "   - Ensure XAMPP is running with MySQL started" -ForegroundColor Gray
Write-Host "   - Or use your existing MySQL/MariaDB installation" -ForegroundColor Gray

if ($missingTools.Count -gt 0) {
    Write-Host "`n❌ Missing required tools:" -ForegroundColor Red
    foreach ($tool in $missingTools) {
        Write-Host "   - $tool" -ForegroundColor Red
    }
    Write-Host "`nPlease install the missing tools and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ All prerequisites met!" -ForegroundColor Green

# Setup menu
Write-Host "`n===========================================" -ForegroundColor Cyan
Write-Host "🎯 What would you like to do?" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "1) Install all dependencies (first time only)"
Write-Host "2) Start all services (Backend + Dashboard + Optional Flutter)"
Write-Host "3) Start Backend only (Port 3000)"
Write-Host "4) Start Admin Dashboard only (Port 3001)"
Write-Host "5) Build & Run Flutter Web (Port 3002)"
Write-Host "6) Open local URLs in browser"
Write-Host "7) Full setup: Install + Start everything"
Write-Host ""

$choice = Read-Host "Enter your choice (1-7)"

function InstallDependencies {
    Write-Host "`n📦 Installing Dependencies..." -ForegroundColor Cyan
    
    # Backend dependencies
    Write-Host "`n🔧 Installing Backend dependencies..." -ForegroundColor Yellow
    Set-Location "d:\quarryforce\qft-deployment"
    
    if (!(Test-Path "node_modules")) {
        Write-Host "   Running: npm install" -ForegroundColor Gray
        npm install
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Backend dependencies installed" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Backend installation failed" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "   ✅ Backend dependencies already installed" -ForegroundColor Green
    }
    
    # Admin Dashboard dependencies
    Write-Host "`n🔧 Installing Admin Dashboard dependencies..." -ForegroundColor Yellow
    Set-Location "d:\quarryforce\admin-dashboard"
    
    if (!(Test-Path "node_modules")) {
        Write-Host "   Running: npm install" -ForegroundColor Gray
        npm install
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Dashboard dependencies installed" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Dashboard installation failed" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "   ✅ Dashboard dependencies already installed" -ForegroundColor Green
    }
    
    # Flutter dependencies
    Write-Host "`n🔧 Getting Flutter dependencies..." -ForegroundColor Yellow
    Set-Location "d:\quarryforce\quarryforce_mobile"
    
    Write-Host "   Running: flutter pub get" -ForegroundColor Gray
    flutter pub get
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Flutter dependencies installed" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Flutter setup failed" -ForegroundColor Red
        return $false
    }
    
    Write-Host "`n✅ All dependencies installed successfully!" -ForegroundColor Green
    return $true
}

function StartAll {
    Write-Host "`n🚀 Starting all services..." -ForegroundColor Cyan
    Write-Host "This will open multiple terminals for each service." -ForegroundColor Yellow
    Write-Host ""
    
    # Start Backend
    Write-Host "1️⃣  Starting Backend (Port 3000)..." -ForegroundColor Green
    Start-Process powershell -ArgumentList "-NoExit -Command {Set-Location 'd:\quarryforce\qft-deployment'; npm start}"
    
    Start-Sleep -Seconds 2
    
    # Start Admin Dashboard
    Write-Host "2️⃣  Starting Admin Dashboard (Port 3001)..." -ForegroundColor Green
    Start-Process powershell -ArgumentList "-NoExit -Command {Set-Location 'd:\quarryforce\admin-dashboard'; npm start}"
    
    Start-Sleep -Seconds 3
    
    # Optional: Start Flutter
    $flutterChoice = Read-Host "`nStart Flutter Web app as well? (y/n)"
    if ($flutterChoice -eq 'y' -or $flutterChoice -eq 'Y') {
        Write-Host "3️⃣  Starting Flutter Web..." -ForegroundColor Green
        Start-Process powershell -ArgumentList "-NoExit -Command {Set-Location 'd:\quarryforce\quarryforce_mobile'; flutter run -d web-server}"
    }
    
    Write-Host "`n✅ All services started!" -ForegroundColor Green
    Write-Host "`n📍 Access points:" -ForegroundColor Cyan
    Write-Host "   Backend API: http://localhost:3000" -ForegroundColor Gray
    Write-Host "   Admin Dashboard: http://localhost:3001" -ForegroundColor Gray
    Write-Host "   Mobile Web: http://localhost:3002" -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

function StartBackendOnly {
    Write-Host "`n🚀 Starting Backend (Port 3000)..." -ForegroundColor Cyan
    Set-Location "d:\quarryforce\qft-deployment"
    npm start
}

function StartDashboardOnly {
    Write-Host "`n🚀 Starting Admin Dashboard (Port 3001)..." -ForegroundColor Cyan
    Set-Location "d:\quarryforce\admin-dashboard"
    npm start
}

function BuildFlutterWeb {
    Write-Host "`n🚀 Building and Running Flutter Web..." -ForegroundColor Cyan
    Set-Location "d:\quarryforce\quarryforce_mobile"
    
    Write-Host "Building Flutter web app..." -ForegroundColor Yellow
    flutter build web
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Build successful! Running web server..." -ForegroundColor Green
        flutter run -d web-server
    } else {
        Write-Host "❌ Build failed" -ForegroundColor Red
    }
}

function OpenBrowser {
    Write-Host "`n🌐 Opening local applications in browser..." -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    
    Start-Process "http://localhost:3000"
    Start-Sleep -Seconds 1
    
    Start-Process "http://localhost:3001"
    Start-Sleep -Seconds 1
    
    Write-Host "✅ Opening URLs..." -ForegroundColor Green
}

# Execute based on choice
switch ($choice) {
    "1" {
        InstallDependencies
    }
    "2" {
        StartAll
    }
    "3" {
        StartBackendOnly
    }
    "4" {
        StartDashboardOnly
    }
    "5" {
        BuildFlutterWeb
    }
    "6" {
        OpenBrowser
    }
    "7" {
        Write-Host "`n🔄 Running full setup..." -ForegroundColor Cyan
        if (InstallDependencies) {
            Write-Host "`n⏳ Waiting 3 seconds before starting services..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
            StartAll
        }
    }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n✨ Done!" -ForegroundColor Green
