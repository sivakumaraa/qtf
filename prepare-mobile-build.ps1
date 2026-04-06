# QuarryForce Mobile Build Preparation Script
$ErrorActionPreference = "Stop"

$rootPath = Get-Location
$mobilePath = Join-Path $rootPath "quarryforce_mobile"
$backendPath = Join-Path $rootPath "qft-deployment"
$outputPath = Join-Path $rootPath "dist-mobile"

Write-Host "Checking prerequisites..."
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Flutter SDK not found."
    exit 1
}

Write-Host "Fetching Mobile API URL from database..."
$apiUrl = "http://10.0.2.2:8000/api"

# We run node inside the backend directory to access its node_modules
$fetchScript = @'
const mysql = require('mysql2/promise');
require('dotenv').config();
async function getUrl() {
    try {
        const c = await mysql.createConnection({
            host: process.env.DB_HOST || '127.0.0.1',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'quarryforce_db'
        });
        const [rows] = await c.execute('SELECT mobile_api_url FROM system_settings LIMIT 1');
        if (rows[0] && rows[0].mobile_api_url) {
            process.stdout.write(rows[0].mobile_api_url);
        }
        await c.end();
    } catch (e) {
        process.exit(1);
    }
}
getUrl();
'@
$tempScriptPath = Join-Path $backendPath "fetch_url_temp.js"
$fetchScript | Out-File -FilePath $tempScriptPath -Encoding utf8

try {
    Set-Location $backendPath
    $dbUrl = node fetch_url_temp.js
    Set-Location $rootPath
    
    if ($dbUrl) {
        $apiUrl = $dbUrl.Trim()
        Write-Host "Using API URL from database: $apiUrl"
    }
} catch {
    Write-Host "DB connection failed. Using fallback: $apiUrl"
    Set-Location $rootPath
} finally {
    if (Test-Path $tempScriptPath) { Remove-Item $tempScriptPath }
}

Write-Host "Building Flutter APK..."
Set-Location $mobilePath
flutter pub get
flutter build apk --release --dart-define=API_URL=$apiUrl

$apkPath = Join-Path $mobilePath "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "ERROR: APK build failed."
    exit 1
}

Set-Location $rootPath
if (Test-Path $outputPath) { Remove-Item $outputPath -Recurse -Force }
New-Item -ItemType Directory -Path $outputPath
Copy-Item $apkPath -Destination (Join-Path $outputPath "quarryforce-tracker.apk")

Write-Host "MOBILE BUILD COMPLETE!"
Write-Host "APK ready at: $outputPath/quarryforce-tracker.apk"
