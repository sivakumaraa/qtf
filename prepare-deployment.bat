@echo off
REM QuarryForce Namecheap Stellar Deployment Preparation Script for Windows
REM Run this batch file to prepare your application for deployment

echo ==========================================
echo QuarryForce - Pre-Deployment Preparation
echo ==========================================
echo.

REM Check Node.js installation
echo Checking prerequisites...
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Node.js is installed
    node -v
) else (
    echo [ERROR] Node.js not found. Please install Node.js first.
    pause
    exit /b 1
)
echo.

REM Step 1: Clean old builds
echo Cleaning old builds...
if exist "admin-dashboard\build" (
    rmdir /s /q "admin-dashboard\build"
    echo [OK] Cleaned build directory
) else (
    echo [OK] No previous build found
)
echo.

REM Step 2: Install backend dependencies
echo Installing backend dependencies...
call npm install --production
if %ERRORLEVEL% EQU 0 (
    echo [OK] Backend dependencies installed
) else (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo.

REM Step 3: Build admin dashboard
echo Building admin dashboard...
echo Entering admin-dashboard directory...
cd admin-dashboard
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Cannot enter admin-dashboard directory
    pause
    exit /b 1
)

echo Installing dashboard dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install admin-dashboard dependencies
    cd ..
    pause
    exit /b 1
)

echo Running build...
call npm run build
if %ERRORLEVEL% EQU 0 (
    if exist "build" if exist "build\index.html" (
        echo [OK] Admin dashboard built successfully
    ) else (
        echo [ERROR] Build folder structure is incomplete
        cd ..
        pause
        exit /b 1
    )
) else (
    echo [ERROR] Build command failed
    cd ..
    pause
    exit /b 1
)
cd ..
echo.

REM Step 4: Create deployment package
echo Creating deployment package...
if exist "deployment" rmdir /s /q deployment
mkdir deployment
mkdir deployment\admin
mkdir deployment\uploads

echo Copying backend files (Node.js API)...
copy index.js deployment\ >nul
if %ERRORLEVEL% NEQ 0 echo [WARNING] Could not copy index.js
copy db.js deployment\ >nul
if %ERRORLEVEL% NEQ 0 echo [WARNING] Could not copy db.js
copy package.json deployment\ >nul
if %ERRORLEVEL% NEQ 0 echo [WARNING] Could not copy package.json
copy package-lock.json deployment\ >nul 2>&1
if %ERRORLEVEL% NEQ 0 echo [WARNING] Could not copy package-lock.json
echo [OK] Backend files copied to deployment root

echo Copying React dashboard build files...
if exist "admin-dashboard\build" (
    xcopy "admin-dashboard\build\*" "deployment\admin\" /E /I /Y >nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Admin dashboard copied to deployment\admin\
    ) else (
        echo [ERROR] Failed to copy admin dashboard
    )
) else (
    echo [ERROR] admin-dashboard\build does not exist. Build may have failed.
)

echo Copying uploads folder...
if exist "uploads" (
    xcopy "uploads\*" "deployment\uploads\" /E /I /Y >nul 2>&1
    echo [OK] Uploads folder copied
) else (
    echo [OK] No uploads folder to copy
)
echo.

REM Step 5: Create environment template
echo Creating .env template...
(
    echo NODE_ENV=production
    echo PORT=3000
    echo DB_HOST=localhost
    echo DB_USER=quarryforce_user
    echo DB_PASSWORD=your_db_password
    echo DB_NAME=quarryforce_db
    echo DB_PORT=3306
    echo API_URL=https://perspectivetechnology.in
    echo FRONTEND_URL=https://perspectivetechnology.in
) > deployment\.env.template
echo [OK] Created .env.template
echo.

REM Step 6: Create .htaccess for single-domain routing
echo Creating .htaccess for API and React routing...
(
    echo ^<IfModule mod_rewrite.c^>
    echo   RewriteEngine On
    echo   RewriteBase /
    echo   RewriteCond %%{REQUEST_URI} ^/api [NC]
    echo   RewriteRule ^(.*^)^$ - [L]
    echo   RewriteCond %%{REQUEST_FILENAME} !-f
    echo   RewriteCond %%{REQUEST_FILENAME} !-d
    echo   RewriteCond %%{REQUEST_URI} !^/admin [NC]
    echo   RewriteRule ^(.*^)^$ /admin/index.html [L]
    echo ^</IfModule^>
) > deployment\.htaccess
echo [OK] Created .htaccess
echo.

REM Display summary
echo ==========================================
echo Preparation Complete!
echo ==========================================
echo.
echo Verifying deployment folder...
if exist "deployment" (index.js" echo [OK] Backend files copied to root
    if exist "deployment\admin\index.html" (
        echo [OK] React dashboard copied to admin/
    ) else (
        echo [WARNING] React dashboard may not have copied correctly
    )
    if exist "deployment\.env.template" echo [OK] Environment template created
    if exist "deployment\.htaccess" echo [OK] Routing configuration created
) else (
    echo [ERROR] Deployment folder was not created!
)
echo.
echo Next steps:
echo 1. Open the 'deployment' folder
echo 2. Edit .env.template and save as .env with your database credentials
echo 3. Upload entire 'deployment' folder via FTP to /public_html/ on Namecheap
echo 4. In cPanel Node.js Selector: Root = /public_html (not /public_html/api)
echo 5. Create a .env file in deployment\api\ from .env.template with your credentials
echo 3. Upload entire 'deployment' folder via FTP to /public_html/ on Namecheap
echo 4. Follow NAMECHEAP_STELLAR_DEPLOYMENT.md for server configuration
echo.
echo Deployment folder structure:
dir deployment 2>nul || echo [ERROR] Deployment folder not found
echo.
echo Files ready for upload (first 20 files):
dir deployment /s /b 2>nul | find /v "" | more
echo.
pause
