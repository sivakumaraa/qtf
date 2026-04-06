@echo off
REM Force kill all Flutter processes
echo Killing Flutter processes...
taskkill /F /IM flutter.bat 2>nul
taskkill /F /IM java.exe 2>nul
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM gradle.exe 2>nul
timeout /t 3 /nobreak

REM Clear Flutter cache
echo Clearing Flutter cache...
cd /d D:\quarryforce\quarryforce_mobile
rmdir /s /q .dart_tool 2>nul
rmdir /s /q build 2>nul
del pubspec.lock 2>nul

REM Set Java home and clean
set JAVA_HOME=C:\java17
set PATH=C:\java17\bin;%PATH%

echo Running Flutter clean...
call flutter clean

echo Getting packages...
call flutter pub get

echo Analyzing code...
call flutter analyze

echo.
echo ========================================
echo RESET COMPLETE
echo ========================================
echo.
echo You can now run: flutter run -d HA1NHP6D
echo.
pause
