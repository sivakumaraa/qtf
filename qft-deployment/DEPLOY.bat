@echo off
REM QuarryForce PHP Deployment Batch Script
REM Automates ZIP creation and uploads to Namecheap
REM Last Updated: March 5, 2026

cls
title QuarryForce Namecheap Deployment

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║     QuarryForce PHP Deployment to Namecheap               ║
echo ║     Status: Ready for Production                           ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Check if we're in the right directory
if not exist "api.php" (
    echo.
    echo ❌ ERROR: api.php not found!
    echo.
    echo This script must run from: d:\quarryforce\qft-deployment
    echo.
    echo Current directory: %CD%
    echo.
    pause
    exit /b 1
)

echo ✅ Verified: Running from correct directory
echo ✅ Found: api.php (router)
echo ✅ Found: index.php (entry point)
echo ✅ Found: config.php (configuration)
echo.

REM Show menu
echo Choose deployment option:
echo.
echo 1) Create ZIP file only (for manual upload)
echo 2) Create ZIP + Copy .env.template to .env
echo 3) Create ZIP + Show cPanel instructions
echo 4) Full deployment (all steps + open Namecheap cPanel)
echo 5) Exit
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto :CREATE_ZIP
if "%choice%"=="2" goto :ZIP_AND_ENV
if "%choice%"=="3" goto :ZIP_AND_INSTRUCTIONS
if "%choice%"=="4" goto :FULL_DEPLOY
if "%choice%"=="5" goto :EXIT
goto :INVALID

:INVALID
echo.
echo ❌ Invalid choice. Please select 1-5.
echo.
pause
cls
goto :EOF

:CREATE_ZIP
cls
echo.
echo ════════════════════════════════════════════════════════════
echo STEP 1: Creating ZIP file
echo ════════════════════════════════════════════════════════════
echo.

REM Check if PowerShell is available
powershell -NoProfile -Command "exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ PowerShell not found. Using alternative method...
    echo.
    goto :CREATE_ZIP_7Z
)

echo Creating qft-php-deploy.zip...
echo This includes all necessary files and excludes:
echo  - node_modules/ (too large)
echo  - .git/ (version control)
echo  - old Node.js files (index.js, db.js, package.json)
echo.

REM Create ZIP using PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$excludeList = @('node_modules', '.git', 'nodejs-backup', 'package.json', 'package-lock.json', 'index.js', 'db.js', '.gitignore'); ^
$files = @('api.php', 'index.php', 'config.php', 'Database.php', 'Logger.php', '.htaccess', '.env.template', 'admin', 'uploads', ^
'PHP_DEPLOYMENT_GUIDE.md', 'PHP_CONVERSION_COMPLETE.md', 'DEPLOYMENT_FOLDER_STRUCTURE.txt', 'BACKUP_AND_LOGGING_GUIDE.md', 'LOGGING_TEST_CHECKLIST.md', 'README.md'); ^
Compress-Archive -Path $files -DestinationPath 'qft-php-deploy.zip' -Force; ^
$zip = Get-Item 'qft-php-deploy.zip'; ^
write-host \"✅ ZIP Created: $($zip.FullName)\"; ^
write-host \"📦 Size: $([math]::Round($zip.Length / 1MB, 2)) MB\""

if %errorlevel% equ 0 (
    echo.
    echo ✅ ZIP file created successfully!
    
    REM Verify ZIP exists
    if exist "qft-php-deploy.zip" (
        for /f %%A in ('powershell -NoProfile -Command "Write-Host $((Get-Item 'qft-php-deploy.zip').Length / 1MB | Round -Precision 2)"') do set ZIP_SIZE=%%A
        echo ✅ File verified: qft-php-deploy.zip (%ZIP_SIZE% MB)
        echo.
        echo 📍 Location: %CD%\qft-php-deploy.zip
        echo.
        goto :ZIP_SUCCESS
    ) else (
        echo.
        echo ❌ ZIP file not created. Try alternative method...
        goto :CREATE_ZIP_7Z
    )
) else (
    echo.
    echo ⚠️  PowerShell method failed. Trying alternative...
    goto :CREATE_ZIP_7Z
)

goto :END_DEPLOY

:CREATE_ZIP_7Z
echo Attempting with Windows 7-Zip or tar...
setlocal enabledelayedexpansion

REM Try using tar (Windows 10+)
where tar >nul 2>&1
if %errorlevel% equ 0 (
    echo Using tar to create archive...
    tar -czf qft-php-deploy.zip api.php index.php config.php Database.php Logger.php .htaccess .env.template admin uploads *.md 2>nul
    if exist "qft-php-deploy.zip" (
        echo ✅ ZIP created with tar
        goto :ZIP_SUCCESS
    )
)

REM Last resort: Use Windows built-in zip (if available)
echo.
echo ⚠️  Unable to create ZIP automatically.
echo.
echo Please create ZIP manually:
echo 1. Select these files:
echo    - api.php, index.php, config.php, Database.php, Logger.php
echo    - .htaccess, .env.template
echo    - admin/, uploads/
echo    - All .md files
echo.
echo 2. Right-click → Send to → Compressed folder
echo 3. Rename to: qft-php-deploy.zip
echo.
pause
goto :END

:ZIP_SUCCESS
echo.
echo ════════════════════════════════════════════════════════════
echo 🎉 ZIP CREATION COMPLETE
echo ════════════════════════════════════════════════════════════
echo.
echo Next step: Upload qft-php-deploy.zip to Namecheap cPanel
echo Path: /public_html/qft/
echo.
echo See: PHP_DEPLOYMENT_GUIDE.md for detailed upload instructions
echo.
pause
goto :END

:ZIP_AND_ENV
call :CREATE_ZIP
if %errorlevel% neq 0 goto :END

cls
echo.
echo ════════════════════════════════════════════════════════════
echo STEP 2: Creating .env file
echo ════════════════════════════════════════════════════════════
echo.

if exist ".env" (
    echo ⚠️  .env file already exists!
    echo.
    set /p overwrite="Overwrite existing .env? (Y/N): "
    if /i not "!overwrite!"=="Y" (
        echo Skipping .env creation.
        goto :ENV_DONE
    )
)

REM Copy template to .env
copy /Y ".env.template" ".env" >nul
if %errorlevel% equ 0 (
    echo ✅ .env file created from template
    echo.
    echo IMPORTANT: Edit .env with your database credentials:
    echo.
    echo 1. Open: .env (in this folder)
    echo 2. Update these values:
    echo    - DB_USER=your_mysql_username
    echo    - DB_PASSWORD=your_mysql_password
    echo    - DB_NAME=your_database_name
    echo.
    echo 3. Get credentials from: cPanel → MySQL Databases
    echo.
    echo 4. Save the file
    echo.
    echo ✅ Then upload everything to Namecheap!
    echo.
) else (
    echo ❌ Failed to create .env
)

:ENV_DONE
pause
goto :END

:ZIP_AND_INSTRUCTIONS
call :CREATE_ZIP
if %errorlevel% neq 0 goto :END

cls
echo.
echo ════════════════════════════════════════════════════════════
echo UPLOADING TO NAMECHEAP (MANUAL STEPS)
echo ════════════════════════════════════════════════════════════
echo.
echo Step 1: Login to cPanel
echo ─────────────────────────
echo URL: https://cpanel.valviyal.com
echo Username: (your cPanel username)
echo Password: (your cPanel password)
echo.
echo.
echo Step 2: Open File Manager
echo ─────────────────────────
echo 1. cPanel Home → File Manager
echo 2. Navigate to: /public_html/qft/
echo 3. (Create 'qft' folder if it doesn't exist)
echo.
echo.
echo Step 3: Upload ZIP File
echo ─────────────────────────
echo 1. Click "Upload" button
echo 2. Select: qft-php-deploy.zip
echo    Location: %CD%\qft-php-deploy.zip
echo 3. Upload begins automatically
echo 4. Wait until "Transfer complete"
echo.
echo.
echo Step 4: Extract ZIP
echo ─────────────────────────
echo 1. Right-click qft-php-deploy.zip
echo 2. Click "Extract"
echo 3. Dialog appears → Click "Extract Files"
echo 4. Wait 5-10 seconds
echo 5. Files are now in /public_html/qft/
echo.
echo.
echo Step 5: Create .env on Server
echo ─────────────────────────
echo 1. In File Manager, click "Create New" → "File"
echo 2. Name: .env (with the dot!)
echo 3. Click "Create File"
echo 4. Click "Edit" (pencil icon)
echo 5. Paste this template and update values:
echo.
echo ──────────────────────────────
echo NODE_ENV=production
echo DB_HOST=localhost
echo DB_USER=YOUR_USERNAME_HERE
echo DB_PASSWORD=YOUR_PASSWORD_HERE
echo DB_NAME=YOUR_DATABASE_HERE
echo DB_PORT=3306
echo API_URL=https://valviyal.com/qft
echo FRONTEND_URL=https://valviyal.com/qft
echo LOGGING_ENABLED=true
echo LOG_LEVEL=INFO
echo ──────────────────────────────
echo.
echo 6. Get credentials from: cPanel → MySQL Databases
echo 7. Click "Save Changes"
echo.
echo.
echo Step 6: Set Permissions
echo ─────────────────────────
echo 1. Right-click "logs" folder → "Change Permissions"
echo 2. Set to: 755 → Click "Change"
echo 3. Right-click "uploads" folder → "Change Permissions"
echo 4. Set to: 755 → Click "Change"
echo.
echo.
echo Step 7: Test Your Deployment
echo ─────────────────────────────
echo 1. Open: https://valviyal.com/qft
echo    (Should show QuarryForce dashboard)
echo.
echo 2. Open: https://valviyal.com/qft/api/test
echo    (Should return: {"server":"Online","database":"Connected"})
echo.
echo 3. Check logs:
echo    File Manager → logs/app.log → should have entries
echo.
echo.
echo ════════════════════════════════════════════════════════════
echo 🎉 DEPLOYMENT COMPLETE!
echo ════════════════════════════════════════════════════════════
echo.
pause
goto :END

:FULL_DEPLOY
call :CREATE_ZIP
if %errorlevel% neq 0 goto :END

cls
call :ZIP_AND_ENV

cls
call :ZIP_AND_INSTRUCTIONS

REM Optional: Open cPanel
echo.
echo Opening Namecheap cPanel in browser...
start https://cpanel.valviyal.com

goto :END

:EXIT
echo.
echo Exiting deployment script.
echo.
goto :END

:END
cls
echo.
echo ════════════════════════════════════════════════════════════
echo Deployment Script Closed
echo ════════════════════════════════════════════════════════════
echo.
echo For detailed instructions, see: PHP_DEPLOYMENT_GUIDE.md
echo For troubleshooting, see: DEPLOY_NOW.md
echo.
pause
exit /b 0
