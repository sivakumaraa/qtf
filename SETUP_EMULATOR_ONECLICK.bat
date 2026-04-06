@echo off
REM One-Click Android Emulator Setup
REM Downloads ~1.5GB (system image) + tools

setlocal enabledelayedexpansion
cd /d D:\quarryforce

echo.
echo ANDROID EMULATOR - One-Click Setup
echo (Downloads and installs everything needed)
echo.
echo This will:
echo - Download cmdline-tools (~300MB)
echo - Create an Android Virtual Device
echo - Launch emulator
echo - Deploy app
echo.
echo Total time: 10-20 minutes (mostly download)
echo.
pause

REM Step 1: Download cmdline-tools if needed
set SDK_PATH=C:\Android\Sdk
if not exist "%SDK_PATH%\cmdline-tools\latest\bin\avdmanager.bat" (
    echo.
    echo [1] Downloading Android Command Line Tools...
    echo (This is ~300MB, may take 2-5 minutes)
    echo.
    
    powershell -Command ^
        "$progressPreference = 'SilentlyContinue'; " ^
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; " ^
        "$url = 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip'; " ^
        "$file = 'C:\cmdline-tools.zip'; " ^
        "Write-Host 'Downloading...'; " ^
        "(New-Object System.Net.WebClient).DownloadFile($url, $file); " ^
        "Write-Host 'Downloaded. Extracting...'; " ^
        "Add-Type -AssemblyName System.IO.Compression.FileSystem; " ^
        "[System.IO.Compression.ZipFile]::ExtractToDirectory($file, $env:SDK_PATH); " ^
        "ren '%SDK_PATH%\cmdline-tools' cmdline-tools-tmp; " ^
        "mkdir '%SDK_PATH%\cmdline-tools\latest'; " ^
        "move '%SDK_PATH%\cmdline-tools-tmp\*' '%SDK_PATH%\cmdline-tools\latest'; " ^
        "rmdir '%SDK_PATH%\cmdline-tools-tmp'; " ^
        "del $file; " ^
        "Write-Host 'Done!'"
)

echo OK: cmdline-tools ready
echo.

REM Step 2: Create emulator using Flutter
echo [2] Creating Android Virtual Device...
set JAVA_HOME=C:\java17
cd /d D:\quarryforce\quarryforce_mobile

REM Use flutter to create and launch
echo.
echo Flutter will now create and launch the emulator...
echo (This takes 5-10 minutes on first run)
echo.
flutter emulate --launch android_default

echo.
echo Setup complete!
pause
