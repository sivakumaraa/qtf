@echo off
REM Quick NDK setup script for Flutter testing
REM This downloads NDK 27.0.12077973 for Android development

cd /d D:\quarryforce\quarryforce_mobile

REM Try running flutter run with a built-in retry for NDK
echo Attempting to build Flutter mobile app...
echo Note: If NDK is still required, please download it from:
echo   https://developer.android.com/ndk/downloads
echo   OR use Android Studio's SDK Manager to install NDK

flutter run -v 2>&1 | more

pause
