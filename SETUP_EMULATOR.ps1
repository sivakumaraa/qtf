Write-Host "Android Emulator Auto-Setup" -ForegroundColor Cyan
Write-Host "(No Android Studio Needed)" -ForegroundColor Cyan
Write-Host ""

$sdkPath = "C:\Android\Sdk"
$avdHome = "$env:USERPROFILE\.android"
$emulatorName = "quarry_emu"

# Step 1: Check System Images
Write-Host "[Step 1/4] Checking system images..." -ForegroundColor Yellow
$sysImgPath = "$sdkPath\system-images"
$images = @()

if (Test-Path $sysImgPath) {
    Get-ChildItem $sysImgPath -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*x86*" } | ForEach-Object {
        $images += $_.Parent.Name + "/" + $_.Name
    }
}

if (-not $avdManager) {
    Write-Host "  ✗ AVD Manager not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "MANUAL SETUP REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Open: $sdkPath\emulator\emulator-gui.exe" -ForegroundColor Cyan
    Write-Host "   OR use Android Studio Device Manager" -ForegroundColor Cyan
    Write-Host "2. Create new AVD with:" -ForegroundColor Cyan
    Write-Host "   - Device: Pixel 5" -ForegroundColor Cyan
    Write-Host "   - API Level: 33 (Android 13) or higher" -ForegroundColor Cyan
    Write-Host "   - Name: quarry_phone" -ForegroundColor Cyan
    Write-Host "3. Once created, run: flutter run" -ForegroundColor Cyan
    exit 1
}

# Step 2: Check system images
Write-Host ""
Write-Host "[Step 2/5] Checking available system images..." -ForegroundColor Yellow
$sysImgPath = "$sdkPath\system-images"
if (-not (Test-Path $sysImgPath)) {
    Write-Host "  ✗ No system images found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Download images via Android Studio or SDK Manager:" -ForegroundColor Yellow
    Write-Host "  1. open Android Studio" -ForegroundColor Cyan
    Write-Host "  2. Tools → SDK Manager" -ForegroundColor Cyan
    Write-Host "  3. Install system image (Android 13+, x86_64)" -ForegroundColor Cyan
    exit 1
}

$images = @()
Get-ChildItem $sysImgPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    Get-ChildItem $_.FullName -Directory | ForEach-Object {
        $images += "$($_.Parent.Name)/$($_.Name)"
        Write-Host "  ✓ $($_.Parent.Name)/$($_.Name)" -ForegroundColor Green
    }
}

if ($images.Count -eq 0) {
    Write-Host "  ✗ No system images available" -ForegroundColor Red
    exit 1
}

# Step 3: Check if emulator already exists
Write-Host ""
Write-Host "[Step 3/5] Checking for existing emulator '$emulatorName'..." -ForegroundColor Yellow
$avdFile = "$avdHome\avd\$emulatorName.avd\config.ini"
if (Test-Path $avdFile) {
    Write-Host "  ✓ Emulator '$emulatorName' already exists" -ForegroundColor Green
}
else {
    Write-Host "  ℹ Creating new emulator..." -ForegroundColor Cyan
    
    # Use first available image
    $selectedImage = $images[0]
    Write-Host "    Using system image: $selectedImage" -ForegroundColor Cyan
    
    # Parse image path
    $parts = $selectedImage -split '/'
    $apiLevel = $parts[0]
    $abi = $parts[1]
    
    # Create AVD
    Write-Host "    Running: avdmanager create avd -n $emulatorName -k 'system-images;$selectedImage'" -ForegroundColor Gray
    & $avdManager create avd -n $emulatorName -k "system-images;$selectedImage" -f 2>&1 | Out-Null
    
    if (Test-Path $avdFile) {
        Write-Host "  ✓ Emulator created successfully" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Failed to create emulator" -ForegroundColor Red
        exit 1
    }
}

# Step 4: Launch emulator
Write-Host ""
Write-Host "[Step 4/5] Starting emulator '$emulatorName'..." -ForegroundColor Yellow
Write-Host "  (This takes 30-60 seconds on first launch)" -ForegroundColor Cyan

$emulator = "$sdkPath\emulator\emulator.exe"
Start-Process -FilePath $emulator -ArgumentList "-avd", $emulatorName, "-no-boot-anim" -WindowStyle Hidden

# Wait for boot
Write-Host "    Waiting for emulator to boot..." -ForegroundColor Gray
Start-Sleep 10

# Check if device is ready
$maxWait = 120
$elapsed = 0
$deviceReady = $false

while ($elapsed -lt $maxWait) {
    $devices = (adb devices 2>&1 | Select-String "emulator")
    if ($devices) {
        $deviceReady = $true
        Write-Host "  ✓ Emulator online" -ForegroundColor Green
        Start-Sleep 5
        break
    }
    Write-Host -NoNewline "."
    Start-Sleep 5
    $elapsed += 5
}

if (-not $deviceReady) {
    Write-Host "  ⚠ Emulator may still be loading..." -ForegroundColor Yellow
}

# Step 5: Deploy app
Write-Host ""
Write-Host "[Step 5/5] Deploying QuarryForce app..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\java17"
cd "D:\quarryforce\quarryforce_mobile"

Write-Host "  Running: flutter run" -ForegroundColor Cyan
flutter run

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✓ SETUP COMPLETE                    ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
