# Build Flutter web and create ZIP for Namecheap deployment
# This script automates the deployment of mobile app to /mobile route

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Flutter Web Build & Deploy Tool" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Flutter not found in PATH" -ForegroundColor Red
    Write-Host "Install Flutter from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Flutter found" -ForegroundColor Green
$flutterVersion = flutter --version | Select-Object -First 1
Write-Host "  Version: $flutterVersion" -ForegroundColor Gray
Write-Host ""

# Project path
$projectPath = "d:\quarryforce\quarryforce_mobile"
$buildPath = "$projectPath\build\web"
$zipPath = "d:\quarryforce\qft-mobile-web.zip"

# Check if pubspec.yaml exists
if (-not (Test-Path "$projectPath\pubspec.yaml")) {
    Write-Host "ERROR: pubspec.yaml not found at $projectPath" -ForegroundColor Red
    exit 1
}

Write-Host "[PROJECT] Project path: $projectPath" -ForegroundColor Gray
Write-Host ""

# Step 1: Clean
Write-Host "[1/4] Cleaning old build..." -ForegroundColor Yellow
Set-Location $projectPath
flutter clean
Write-Host "[OK] Flutter clean complete" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "[2/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "[OK] Dependencies resolved" -ForegroundColor Green
Write-Host ""

# Step 3: Build web
Write-Host "[3/4] Building Flutter web (this takes 2-5 minutes)..." -ForegroundColor Yellow
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter build failed" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Flutter web build complete" -ForegroundColor Green
Write-Host ""

# Verify build directory
if (-not (Test-Path "$buildPath\index.html")) {
    Write-Host "ERROR: index.html not found after build" -ForegroundColor Red
    Write-Host "Expected at: $buildPath\index.html" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Build verification passed" -ForegroundColor Green
Write-Host ""

# Step 4: Create ZIP
Write-Host "[4/4] Creating ZIP file..." -ForegroundColor Yellow
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Host "  (removed old ZIP)" -ForegroundColor Gray
}

Set-Location $buildPath
Compress-Archive -Path * -DestinationPath $zipPath -Force
Set-Location d:\quarryforce

if (-not (Test-Path $zipPath)) {
    Write-Host "ERROR: Failed to create ZIP file" -ForegroundColor Red
    exit 1
}

$zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
Write-Host "[OK] ZIP created successfully" -ForegroundColor Green
Write-Host "  File: $zipPath" -ForegroundColor Gray
Write-Host "  Size: $zipSize MB" -ForegroundColor Gray
Write-Host ""

# Summary
Write-Host "================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] BUILD COMPLETE!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[NEXT] Steps:" -ForegroundColor Yellow
Write-Host "  1. Login to cPanel: https://valviyal.com:2083" -ForegroundColor Gray
Write-Host "  2. Open File Manager -> public_html -> qft" -ForegroundColor Gray
Write-Host "  3. Create folder: mobile" -ForegroundColor Gray
Write-Host "  4. Upload ZIP: $zipPath" -ForegroundColor Gray
Write-Host "  5. Extract ZIP" -ForegroundColor Gray
Write-Host "  6. Test at: https://valviyal.com/qft/mobile" -ForegroundColor Gray
Write-Host ""
Write-Host "[CHECKLIST] Items:" -ForegroundColor Yellow
Write-Host "  [ ] ZIP uploaded to /public_html/qft/mobile/" -ForegroundColor Gray
Write-Host "  [ ] ZIP extracted" -ForegroundColor Gray
Write-Host "  [ ] https://valviyal.com/qft/mobile loads" -ForegroundColor Gray
Write-Host "  [ ] Login works" -ForegroundColor Gray
Write-Host "  [ ] Features accessible (checkin, visit, fuel)" -ForegroundColor Gray
Write-Host ""

# Copy helpful info to clipboard
$clipboardText = "ZIP file: qft-mobile-web.zip`nLocation: d:\quarryforce\qft-mobile-web.zip`nSize: $zipSize MB`nDeploy to: /public_html/qft/mobile/"
Set-Clipboard -Value $clipboardText
Write-Host "[CLIPBOARD] Deployment info copied to clipboard!" -ForegroundColor Cyan
