@echo off
echo Connected Devices:
adb devices | find "device" | find /v "List"
