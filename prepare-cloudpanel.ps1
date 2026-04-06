# QuarryForce CloudPanel Deployment Preparation Script
# This script builds the React dashboard and packages the Node.js backend for VPS deployment.

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  QuarryForce - CloudPanel Preparation " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$rootPath = Get-Location
$adminPath = Join-Path $rootPath "admin-dashboard"
$backendPath = Join-Path $rootPath "qft-deployment"
$outputPath = Join-Path $rootPath "dist-cloudpanel"
$zipPath = Join-Path $rootPath "quarryforce-deploy.zip"

# 1. Prerequisite Checks
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js not found. Please install Node.js." -ForegroundColor Red
    exit 1
}
Write-Host "  [✓] Node.js: $(node -v)" -ForegroundColor Gray

# 2. Fetch Configuration from Database
Write-Host "[2/5] Fetching Production Config from database..." -ForegroundColor Yellow

# Use a temporary node script to fetch the values safely
$fetchScript = @'
const mysql = require('mysql2/promise');
require('dotenv').config({ path: 'qft-deployment/.env' });
async function getConfig() {
    try {
        const c = await mysql.createConnection({
            host: process.env.DB_HOST || '127.0.0.1',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'quarryforce_db'
        });
        const [rows] = await c.execute('SELECT production_url, backend_port, prod_db_host, prod_db_user, prod_db_pass, prod_db_name FROM system_settings LIMIT 1');
        if (rows[0]) {
            process.stdout.write(JSON.stringify(rows[0]));
        }
        await c.end();
    } catch (e) {
        process.exit(1);
    }
}
getConfig();
'@
$tempScriptPath = Join-Path $rootPath "fetch_config_temp.js"
$fetchScript | Out-File -FilePath $tempScriptPath -Encoding utf8

$config = @{
    production_url = "https://admin.quarryforce.pro";
    backend_port = 8000;
    prod_db_host = "127.0.0.1";
    prod_db_user = "root";
    prod_db_pass = "";
    prod_db_name = "quarryforce_db"
}

try {
    $dbConfigJson = node $tempScriptPath
    if ($dbConfigJson) {
        $dbConfig = $dbConfigJson | ConvertFrom-Json
        $config.production_url = $dbConfig.production_url
        $config.backend_port = $dbConfig.backend_port
        $config.prod_db_host = $dbConfig.prod_db_host
        $config.prod_db_user = $dbConfig.prod_db_user
        $config.prod_db_pass = $dbConfig.prod_db_pass
        $config.prod_db_name = $dbConfig.prod_db_name
        Write-Host "  [INFO] Configuration loaded from Dashboard Settings." -ForegroundColor Green
    }
} catch {
    Write-Host "  [WARN] Database connection failed. Using default placeholders." -ForegroundColor Yellow
} finally {
    if (Test-Path $tempScriptPath) { Remove-Item $tempScriptPath }
}

# 3. Build Admin Dashboard
Write-Host "[3/5] Building Admin Dashboard..." -ForegroundColor Yellow
Set-Location $adminPath

# Set the production URL for the React build
$env:REACT_APP_API_BASE_URL = "$($config.production_url)/api"
Write-Host "  API URL: $($env:REACT_APP_API_BASE_URL)" -ForegroundColor Gray

    Write-Host "  Running npm install..." -ForegroundColor Gray
    npm install --no-audit --no-fund

    Write-Host "  Running npm run build..." -ForegroundColor Gray
    npm run build

if (-not (Test-Path "build")) {
    Write-Host "ERROR: Dashboard build failed." -ForegroundColor Red
    exit 1
}
Write-Host "  [✓] Dashboard built successfully" -ForegroundColor Green

# 3. Create Deployment Package
Write-Host "[3/5] Creating deployment structure..." -ForegroundColor Yellow
Set-Location $rootPath

if (Test-Path $outputPath) { Remove-Item $outputPath -Recurse -Force }
New-Item -ItemType Directory -Path $outputPath | Out-Null
New-Item -ItemType Directory -Path (Join-Path $outputPath "public") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $outputPath "uploads") | Out-Null

# Copy Backend Files
Write-Host "  Copying backend files..." -ForegroundColor Gray
$backendFiles = @("index.js", "db.js", "package.json", "package-lock.json")
foreach ($file in $backendFiles) {
    if (Test-Path (Join-Path $backendPath $file)) {
        Copy-Item (Join-Path $backendPath $file) $outputPath
    }
}

# Generate Production .env
Write-Host "  Generating production .env from Database Settings..." -ForegroundColor Gray
$prodEnv = @"
PORT=$($config.backend_port)
DB_HOST=$($config.prod_db_host)
DB_USER=$($config.prod_db_user)
DB_PASSWORD=$($config.prod_db_pass)
DB_NAME=$($config.prod_db_name)
LOGGING_ENABLED=false
"@
$prodEnv | Out-File -FilePath (Join-Path $outputPath ".env") -Encoding utf8

# Copy React Build to public/admin
Write-Host "  Copying static assets..." -ForegroundColor Gray
New-Item -ItemType Directory -Path (Join-Path $outputPath "public/admin") | Out-Null
Copy-Item -Path (Join-Path $adminPath "build\*") -Destination (Join-Path $outputPath "public/admin") -Recurse -Force

# Create .htaccess for Nginx/CloudPanel (not used by Node directly but helpful for documentation)
Write-Host "  Generating Nginx config snippet..." -ForegroundColor Gray
$nginxConfig = @"
# CloudPanel Nginx vHost Configuration Snippet
# Place this in your VHost settings

location / {
    root /home/user/htdocs/domain.com/public/admin;
    index index.html;
    try_files `$uri `$uri/ /admin/index.html;
}

location /api {
    proxy_pass http://127.0.0.1:8000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade `$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host `$host;
    proxy_cache_bypass `$http_upgrade;
}
"@
$nginxConfig | Out-File -FilePath (Join-Path $outputPath "nginx-vhost.txt")

Write-Host "  [✓] Deployment folder ready at dist-cloudpanel/" -ForegroundColor Green

# 4. Create ZIP
Write-Host "[4/5] Creating ZIP archive..." -ForegroundColor Yellow
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $outputPath "*") -DestinationPath $zipPath
Write-Host "  [✓] ZIP created: $zipPath" -ForegroundColor Green

# 5. Summary
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  PREPARATION COMPLETE! " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  1. Upload '$zipPath' to CloudPanel" -ForegroundColor Gray
Write-Host "  2. Extract to your site root" -ForegroundColor Gray
Write-Host "  3. Run 'npm install' in the site root" -ForegroundColor Gray
Write-Host "  4. Start app with PM2: 'pm2 start index.js --name quarryforce'" -ForegroundColor Gray
Write-Host "  5. Configure Nginx proxy as per 'nginx-vhost.txt'" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
