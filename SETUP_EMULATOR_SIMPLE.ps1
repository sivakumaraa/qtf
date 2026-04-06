Write-Host "Android Emulator Setup" -ForegroundColor Cyan
Write-Host ""

$sdkPath = "C:\Android\Sdk"
$emulatorName = "quarry_phone"
$avdHome = "$env:USERPROFILE\.android"

# Find AVD Manager
Write-Host "Step 1: Finding AVD Manager..." -ForegroundColor Yellow
$avdManager = "$sdkPath\cmdline-tools\latest\bin\avdmanager.bat"
if (-not (Test-Path $avdManager)) {
    Write-Host "Not at latest, searching..." -ForegroundColor Gray
    $dirs = Get-ChildItem "$sdkPath\cmdline-tools\" -Directory -ErrorAction SilentlyContinue
    foreach ($d in $dirs) {
        $test = "$($d.FullName)\bin\avdmanager.bat"
        if (Test-Path $test) {
            $avdManager = $test
            break
        }
    }
}

if (-not (Test-Path $avdManager)) {
    Write-Host "ERROR: AVD Manager not found" -ForegroundColor Red
    Write-Host "Please use Android Studio to create an emulator" -ForegroundColor Yellow
    exit 1
}
Write-Host "OK: Found AVD Manager" -ForegroundColor Green

# Check system images
Write-Host ""
Write-Host "Step 2: Checking system images..." -ForegroundColor Yellow
$sysImgPath = "$sdkPath\system-images"
$images = @()
Get-ChildItem $sysImgPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    Get-ChildItem $_.FullName -Directory | ForEach-Object {
        $images += "$($_.Parent.Name)/$($_.Name)"
    }
}

if ($images.Count -eq 0) {
    Write-Host "ERROR: No system images found" -ForegroundColor Red
    Write-Host "Please download system images via Android Studio SDK Manager" -ForegroundColor Yellow
    exit 1
}
Write-Host "OK: Found $($images.Count) system image(s)" -ForegroundColor Green

# Check if AVD exists
Write-Host ""
Write-Host "Step 3: Checking for existing emulator..." -ForegroundColor Yellow
$avdFile = "$avdHome\avd\$emulatorName.avd\config.ini"
$avdExists = Test-Path $avdFile

if ($avdExists) {
    Write-Host "OK: Emulator '$emulatorName' already exists" -ForegroundColor Green
} else {
    Write-Host "Creating new emulator..." -ForegroundColor Cyan
    $selectedImage = $images[0]
    Write-Host "Using: $selectedImage" -ForegroundColor Cyan
    & $avdManager create avd -n $emulatorName -k "system-images;$selectedImage" -d 5 -f 2>&1 | Out-Null
    if (Test-Path $avdFile) {
        Write-Host "OK: Emulator created" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Failed to create emulator" -ForegroundColor Red
        exit 1
    }
}

# Launch emulator
Write-Host ""
Write-Host "Step 4: Launching emulator..." -ForegroundColor Yellow
$emulator = "$sdkPath\emulator\emulator.exe"
Start-Process -FilePath $emulator -ArgumentList "-avd",$emulatorName,"-no-boot-anim" -WindowStyle Hidden

Write-Host "Waiting for emulator to boot (30-60 seconds)..." -ForegroundColor Gray
Start-Sleep 15

$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    $devices = adb devices 2>&1 | Select-String "emulator-"
    if ($devices) {
        $ready = $true
        break
    }
    Write-Host -NoNewline "."
    Start-Sleep 3
}

if ($ready) {
    Write-Host ""
    Write-Host "OK: Emulator is ready" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Note: Emulator may still be loading..." -ForegroundColor Yellow
}

# Deploy app
Write-Host ""
Write-Host "Step 5: Deploying app..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\java17"
cd "D:\quarryforce\quarryforce_mobile"

Write-Host "Running: flutter run" -ForegroundColor Cyan
flutter run

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
