Write-Host "================================" -ForegroundColor Cyan
Write-Host "QuarryForce Mobile App Launcher" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`n[1/5] Stopping old PHP processes..." -ForegroundColor Yellow
taskkill /F /IM php.exe 2>$null | Out-Null
Start-Sleep -Milliseconds 500

Write-Host "[2/5] Starting PHP backend server on port 8000..." -ForegroundColor Yellow
$phpPath = "d:\xampp\php\php.exe"
$apiPath = "d:\quarryforce\qft-deployment"
Start-Process -FilePath $phpPath -ArgumentList "-S 0.0.0.0:8000" -WorkingDirectory $apiPath -WindowStyle Hidden -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "[3/5] Setting up ADB port forwarding..." -ForegroundColor Yellow
& adb forward tcp:8000 tcp:8000 2>&1
Start-Sleep -Milliseconds 500

Write-Host "[4/5] Checking device connection..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\java17"
& flutter devices 2>&1 | Select-String "moto g34"

Write-Host "[5/5] Launching Flutter app..." -ForegroundColor Yellow
cd "D:\quarryforce\quarryforce_mobile"
& flutter clean 2>&1
Write-Host "Starting app deployment..." -ForegroundColor Cyan
& flutter run -d ZA222LDXSB
