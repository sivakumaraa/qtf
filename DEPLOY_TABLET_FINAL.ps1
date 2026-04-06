# TABLET DEPLOYMENT - COMPREHENSIVE SCRIPT
Write-Host "=" * 60 -ForegroundColor Green
Write-Host "QUARRYFORCE TABLET DEPLOYMENT" -ForegroundColor Green
Write-Host "=" * 60
Write-Host ""

$timestamp = Get-Date -Format "MMdd_HHmmss"
$logFile = "D:\quarryforce\deployment_$timestamp.log"

function LogMessage {
    param([string]$Message, [string]$Color = "Gray")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Host $line -ForegroundColor $Color
    Add-Content $logFile -Value $line
}

LogMessage "Starting deployment...`n" "Green"

# ========== STEP 1: Environment Setup ==========
LogMessage "[STEP 1] Setting environment variables..."
$env:JAVA_HOME = "C:\java17"
LogMessage "JAVA_HOME = $env:JAVA_HOME" "Yellow"

# ========== STEP 2: Stop all background processes ==========
LogMessage "[STEP 2] Stopping background processes..." "Yellow"
try {
    Get-Process flutter, dart, java, php -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    LogMessage "✓ Processes stopped" "Green"
}
catch {
    LogMessage "Note: No processes to stop" "Gray"
}

# ========== STEP 3: Verify tablet is connected ==========
LogMessage "[STEP 3] Verifying tablet connection..." "Yellow"
$devices = adb devices | Select-String "HA1NHP6D"
if ($devices) {
    LogMessage "✓ Tablet detected: HA1NHP6D" "Green"
}
else {
    LogMessage "✗ ERROR: Tablet not detected!" "Red"
    Exit 1
}

# ========== STEP 4: Setup ADB reverse tunnel ==========
LogMessage "[STEP 4] Configuring ADB reverse tunnel..." "Yellow"
adb reverse --remove-all 2>&1 | ForEach-Object { LogMessage $_ }
Start-Sleep -Milliseconds 200
adb -s HA1NHP6D reverse tcp:8000 tcp:8000 2>&1 | ForEach-Object { LogMessage $_ }
LogMessage "✓ ADB tunnel configured" "Green"

# ========== STEP 5: Verify ADB tunnel ==========
LogMessage "[STEP 5] Checking tunnel status..." "Yellow"
$tunnelStatus = adb reverse --list
LogMessage "Tunnels: $tunnelStatus" "Yellow"

# ========== STEP 6: Start PHP backend ==========
LogMessage "[STEP 6] Starting PHP backend on port 8000..." "Yellow"
cd "d:\quarryforce\qft-deployment"

# Start PHP and capture PID
$phpProcess = Start-Process -FilePath "d:\xampp\php\php.exe" -ArgumentList "-S 0.0.0.0:8000" -PassThru -NoNewWindow
LogMessage "✓ PHP started (PID: $($phpProcess.Id))" "Green"
Start-Sleep -Seconds 2

# Verify PHP is listening
LogMessage "[STEP 7] Testing PHP backend..." "Yellow"
try {
    $testResponse = curl -s http://127.0.0.1:8000/api/test 2>&1
    LogMessage "Backend response: $testResponse" "Yellow"
}
catch {
    LogMessage "⚠️  Could not curl backend (may be normal)" "Gray"
}

# ========== STEP 8: Deploy Flutter app ==========
LogMessage "[STEP 8] Deploying Flutter app to tablet..." "Yellow"
cd "D:\quarryforce\quarryforce_mobile"
$deployOutput = flutter run -d HA1NHP6D 2>&1
$deployOutput | ForEach-Object { LogMessage $_ "Cyan" }

LogMessage "`n" "Gray"
LogMessage "=" * 60 "Green"
LogMessage "DEPLOYMENT COMPLETE" "Green"
LogMessage "Check your tablet screen now!" "Yellow"
LogMessage "Full log saved to: $logFile" "Gray"
LogMessage "=" * 60 "Green"
