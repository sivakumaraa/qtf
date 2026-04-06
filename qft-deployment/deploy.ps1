# QuarryForce PHP Deployment Script
# Automated ZIP creation for Namecheap deployment

param(
    [ValidateSet('zip','env','deploy')]
    [string]$Action = 'zip',
    [switch]$OpenCPanel
)

function Show-Header {
    Clear-Host
    Write-Host "[===== QuarryForce PHP Deployment to Namecheap =====]" -ForegroundColor Cyan
    Write-Host "[      Status: Ready for Production               ]" -ForegroundColor Cyan
    Write-Host ""
}

function Test-Environment {
    Write-Host "Checking environment..." -ForegroundColor Yellow
    
    if (-not (Test-Path "api.php")) {
        Write-Host "[ERROR] api.php not found!" -ForegroundColor Red
        Write-Host "Script must run from: d:\quarryforce\qft-deployment" -ForegroundColor Red
        Write-Host "Current directory: $PWD" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Running from correct directory" -ForegroundColor Green
    Write-Host "[OK] Found: api.php (router)" -ForegroundColor Green
    Write-Host "[OK] Found: index.php (entry point)" -ForegroundColor Green
    Write-Host "[OK] Found: config.php (configuration)" -ForegroundColor Green
    Write-Host ""
}

function Create-ZipFile {
    param([bool]$Verbose = $true)
    
    Show-Header
    Write-Host "[==== STEP 1: Creating ZIP file ====]" -ForegroundColor Cyan
    Write-Host ""
    
    Test-Environment
    
    if (Test-Path "qft-php-deploy.zip") {
        Write-Host "[WARN] Existing ZIP found. Overwriting..." -ForegroundColor Yellow
        Remove-Item "qft-php-deploy.zip" -Force
    }
    
    Write-Host "Creating qft-php-deploy.zip..." -ForegroundColor Yellow
    Write-Host "Including: api.php, index.php, config.php, Database.php, Logger.php, admin/, uploads/, docs" -ForegroundColor White
    Write-Host "Excluding: node_modules/, .git/, old Node.js files" -ForegroundColor Gray
    Write-Host ""
    
    $filesToInclude = @(
        'api.php',
        'index.php',
        'config.php',
        'Database.php',
        'Logger.php',
        '.htaccess',
        '.env.template',
        'admin',
        'uploads',
        'PHP_DEPLOYMENT_GUIDE.md',
        'PHP_CONVERSION_COMPLETE.md',
        'DEPLOYMENT_FOLDER_STRUCTURE.txt',
        'BACKUP_AND_LOGGING_GUIDE.md',
        'LOGGING_TEST_CHECKLIST.md',
        'README.md'
    )
    
    try {
        Compress-Archive -Path $filesToInclude -DestinationPath 'qft-php-deploy.zip' -Force -CompressionLevel Fastest
        
        $zipInfo = Get-Item 'qft-php-deploy.zip'
        $sizeInMB = [math]::Round($zipInfo.Length / 1MB, 2)
        
        Write-Host "[SUCCESS] ZIP Created!" -ForegroundColor Green
        Write-Host "File: qft-php-deploy.zip" -ForegroundColor Green
        Write-Host "Size: $sizeInMB MB" -ForegroundColor Green
        Write-Host "Path: $(Get-Location)\qft-php-deploy.zip" -ForegroundColor Green
        Write-Host ""
        
        return $true
    }
    catch {
        Write-Host "[ERROR] Failed to create ZIP file" -ForegroundColor Red
        Write-Host "Details: $_" -ForegroundColor Red
        return $false
    }
}

function Create-EnvFile {
    Write-Host ""
    Write-Host "[==== STEP 2: Creating .env File ====]" -ForegroundColor Cyan
    Write-Host ""
    
    if (Test-Path ".env") {
        Write-Host "[WARN] .env file already exists!" -ForegroundColor Yellow
        $overwrite = Read-Host "Overwrite? (Y/N)"
        if ($overwrite -notmatch '^[Yy]') {
            Write-Host "Skipping .env creation." -ForegroundColor Yellow
            return
        }
    }
    
    if (-not (Test-Path ".env.template")) {
        Write-Host "[ERROR] .env.template not found" -ForegroundColor Red
        return
    }
    
    Copy-Item ".env.template" ".env" -Force
    Write-Host "[OK] .env file created from template" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Edit .env with database credentials:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Open: .env (in this folder)" -ForegroundColor White
    Write-Host "2. Update these values:" -ForegroundColor White
    Write-Host "   - DB_USER=your_mysql_username" -ForegroundColor Gray
    Write-Host "   - DB_PASSWORD=your_mysql_password" -ForegroundColor Gray
    Write-Host "   - DB_NAME=your_database_name" -ForegroundColor Gray
    Write-Host "3. Get credentials from: cPanel > MySQL Databases" -ForegroundColor White
    Write-Host "4. Save the file" -ForegroundColor White
    Write-Host ""
    
    Read-Host "Press Enter to open .env for editing"
    notepad ".env"
}

function Show-DeploymentInstructions {
    Clear-Host
    Write-Host "[==== Uploading to Namecheap - Step by Step ====]" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[1] Login to cPanel" -ForegroundColor Yellow
    Write-Host "URL: https://cpanel.valviyal.com" -ForegroundColor White
    Write-Host "Username: (your cPanel username)" -ForegroundColor White
    Write-Host "Password: (your cPanel password)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[2] Open File Manager" -ForegroundColor Yellow
    Write-Host "1. cPanel Home > File Manager" -ForegroundColor White
    Write-Host "2. Navigate to: /public_html/qft/" -ForegroundColor White
    Write-Host "3. Create 'qft' folder if it doesn't exist" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[3] Upload ZIP File" -ForegroundColor Yellow
    Write-Host "1. Click 'Upload' button" -ForegroundColor White
    Write-Host "2. Select: qft-php-deploy.zip" -ForegroundColor White
    Write-Host "   From: $(Get-Location)\qft-php-deploy.zip" -ForegroundColor Cyan
    Write-Host "3. Wait for upload complete" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[4] Extract ZIP" -ForegroundColor Yellow
    Write-Host "1. Right-click qft-php-deploy.zip" -ForegroundColor White
    Write-Host "2. Click 'Extract'" -ForegroundColor White
    Write-Host "3. Click 'Extract Files'" -ForegroundColor White
    Write-Host "4. Wait 5-10 seconds" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[5] Create .env on Server" -ForegroundColor Yellow
    Write-Host "1. Click 'Create New' > 'File'" -ForegroundColor White
    Write-Host "2. Name: .env (include the dot!)" -ForegroundColor White
    Write-Host "3. Click 'Create File'" -ForegroundColor White
    Write-Host "4. Click 'Edit' icon" -ForegroundColor White
    Write-Host "5. Paste and update:" -ForegroundColor White
    Write-Host ""
    Write-Host "   NODE_ENV=production" -ForegroundColor Gray
    Write-Host "   DB_HOST=localhost" -ForegroundColor Gray
    Write-Host "   DB_USER=YOUR_USERNAME" -ForegroundColor Cyan
    Write-Host "   DB_PASSWORD=YOUR_PASSWORD" -ForegroundColor Cyan
    Write-Host "   DB_NAME=YOUR_DATABASE" -ForegroundColor Cyan
    Write-Host "   DB_PORT=3306" -ForegroundColor Gray
    Write-Host "   API_URL=https://valviyal.com/qft" -ForegroundColor Gray
    Write-Host "   FRONTEND_URL=https://valviyal.com/qft" -ForegroundColor Gray
    Write-Host "   LOGGING_ENABLED=true" -ForegroundColor Gray
    Write-Host "   LOG_LEVEL=INFO" -ForegroundColor Gray
    Write-Host ""
    Write-Host "6. Get credentials from: cPanel > MySQL Databases" -ForegroundColor White
    Write-Host "7. Click 'Save Changes'" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[6] Set Folder Permissions" -ForegroundColor Yellow
    Write-Host "1. Right-click 'logs' folder > 'Change Permissions'" -ForegroundColor White
    Write-Host "2. Set to: 755 > Click 'Change'" -ForegroundColor White
    Write-Host "3. Right-click 'uploads' folder > 'Change Permissions'" -ForegroundColor White
    Write-Host "4. Set to: 755 > Click 'Change'" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[7] Test Your Deployment" -ForegroundColor Yellow
    Write-Host "1. Open: https://valviyal.com/qft" -ForegroundColor Cyan
    Write-Host "   (Should show QuarryForce dashboard)" -ForegroundColor White
    Write-Host "2. Open: https://valviyal.com/qft/api/test" -ForegroundColor Cyan
    Write-Host "   (Should return JSON with server status)" -ForegroundColor White
    Write-Host "3. Check logs: File Manager > logs/app.log" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[==== DEPLOYMENT COMPLETE! ====]" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Header
    Write-Host "Choose deployment action:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1) Create ZIP only" -ForegroundColor White
    Write-Host "  2) Create ZIP + Setup .env" -ForegroundColor White
    Write-Host "  3) Create ZIP + Show cPanel instructions" -ForegroundColor White
    Write-Host "  4) Full deployment (everything + open cPanel)" -ForegroundColor White
    Write-Host "  5) Exit" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter choice (1-5)"
    return $choice
}

# Main execution
if ($Action -eq "zip") {
    Show-Header
    Test-Environment
    Create-ZipFile
    Write-Host "To run more steps:" -ForegroundColor Yellow
    Write-Host "  deploy.ps1 -Action env    (Create .env)" -ForegroundColor Gray
    Write-Host "  deploy.ps1 -Action deploy (Full deploy)" -ForegroundColor Gray
    Write-Host ""
}
elseif ($Action -eq "env") {
    Show-Header
    Create-EnvFile
}
elseif ($Action -eq "deploy") {
    Create-ZipFile | Out-Null
    Create-EnvFile
    Show-DeploymentInstructions
    
    if ($OpenCPanel) {
        Write-Host "Opening Namecheap cPanel..." -ForegroundColor Yellow
        Start-Process "https://cpanel.valviyal.com"
    }
    
    Write-Host "Press any key to continue..."
    pause
}
else {
    # Show menu
    do {
        $choice = Show-Menu
        
        switch ($choice) {
            "1" {
                Create-ZipFile
                pause
            }
            "2" {
                Create-ZipFile | Out-Null
                Create-EnvFile
                pause
            }
            "3" {
                Create-ZipFile | Out-Null
                Show-DeploymentInstructions
                Read-Host "Press Enter when ready"
            }
            "4" {
                Create-ZipFile | Out-Null
                Create-EnvFile
                Show-DeploymentInstructions
                Write-Host "Opening Namecheap cPanel..." -ForegroundColor Yellow
                Start-Process "https://cpanel.valviyal.com"
                pause
            }
            "5" {
                Write-Host "Exiting..." -ForegroundColor Yellow
                exit 0
            }
            default {
                Write-Host "Invalid choice!" -ForegroundColor Red
                pause
                Clear-Host
            }
        }
    } while ($choice -ne "5")
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Write-Host ""
