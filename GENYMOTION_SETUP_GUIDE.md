# Genymotion Setup Guide for QuarryForce

## Step 1: Download & Install Genymotion (5 minutes)

1. **Go to:** https://www.genymotion.com/download/

2. **Create Account:**
   - Click "Sign Up" (FREE)
   - Complete registration
   - Verify email

3. **Download:**
   - Choose "Genymotion for Windows"
   - Download the installer (~400MB)

4. **Install:**
   - Run the .exe file
   - Follow wizard (accept defaults)
   - Installation takes ~5 minutes
   - You'll be prompted to install VirtualBox (do it)

5. **Launch:**
   - After install completes, Genymotion opens automatically
   - Sign in with your account

---

## Step 2: Create Virtual Device (3 minutes)

1. **In Genymotion window:**
   - Click "+" button (Add Device)
   - Select **"Google Pixel 4"** (or similar)
   - Choose **Android 12.0** or higher
   - Click "Install"

2. **Wait for download** (~10 minutes, one-time)
   - After first device, others are faster

3. **Device appears in list**

---

## Step 3: Start Emulator (30 seconds)

1. **Select your device** (e.g., "Google Pixel 4")
2. **Click "Start"** (green play button)
3. **Wait for Android to boot** (~30 seconds)
   - You'll see Android lock screen = ready!

---

## Step 4: Deploy QuarryForce App

**Then run this command in PowerShell:**

```powershell
$env:JAVA_HOME = "C:\java17"
cd "D:\quarryforce\quarryforce_mobile"
adb devices  # Should show emulator as "emulator-5554" or similar
flutter run
```

**What happens:**

- Flutter builds your app
- Installs .APK to emulator
- App launches automatically
- You see the login screen!

---

## Troubleshooting

### "Emulator not detected by ADB?"

```powershell
adb kill-server
adb start-server
adb devices  # Should list emulator now
```

### "App runs but can't reach backend?"

- Make sure PHP backend is running on your PC
- Emulator connects to host via special IP: `10.0.2.2:8000`
- You may need to update the app's API URL for emulator testing

### "Emulator won't start?"

- Check if VirtualBox is installed and running
- Restart Genymotion
- Restart your computer

---

## Next Steps

1. ✅ Install Genymotion
2. ✅ Create device
3. ✅ Start emulator
4. ✅ Run Flutter deploy command

**Total time: ~20-30 minutes** (mostly automatic downloads)

---

## For API Testing in Emulator

If the app can't reach your backend, use this special IP in emulator:

- **Instead of:** `http://127.0.0.1:8000/api`
- **Use:** `http://10.0.2.2:8000/api`

Then you may need to temporarily update constants.dart for emulator testing.
