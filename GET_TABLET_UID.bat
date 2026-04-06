@echo off
echo.
echo ========== CONNECTED DEVICES ==========
adb devices -l
echo.
echo ========== TO GET TABLET UID SPECIFICALLY ==========
echo Run one of these:
echo   adb devices  (shows all UIDs)
echo   adb -s ^<TABLET_UID^> shell getprop ro.product.model  (get model)
echo.
echo ========== DISCONNECT PHONE AND RUN AGAIN ==========
echo If both devices are connected, disconnect the phone (ZA222LDXSB)
echo Then run: adb shell getprop ro.serialno
