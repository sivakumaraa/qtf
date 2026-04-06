#!/usr/bin/env python3
"""Download and setup Android NDK for the Flutter project."""

import os
import subprocess
import urllib.request
import zipfile
import shutil
from pathlib import Path

def download_ndk():
    """Download NDK version 27.0.12077973"""
    sdk_root = r"C:\Users\sivak\AppData\Local\Android\Sdk"
    ndk_dir = os.path.join(sdk_root, "ndk", "27.0.12077973")
    
    # Skip if already exists
    if os.path.exists(ndk_dir):
        print(f"NDK already exists at {ndk_dir}")
        return True
    
    # Create ndk directory
    os.makedirs(os.path.join(sdk_root, "ndk"), exist_ok=True)
    
    print("Using Android SDK Manager to download NDK...")
    try:
        # Try using sdkmanager with Java 11 compatibility
        cmd = [
            r"D:\Program Files\Android\Android Studio\jbr\bin\java",
            "-Dcom.android.sdklib.toolsdir=" + os.path.join(sdk_root, "cmdline-tools", "latest", "lib"),
            "-cp",
            os.path.join(sdk_root, "cmdline-tools", "latest", "lib", "*"),
            "com.android.sdklib.tool.sdkmanager.SdkManagerCli",
            "ndk;27.0.12077973"
        ]
        
        # Accept all licenses first
        print("Accepting Android SDK licenses...")
        subprocess.run(
            [r"D:\Program Files\Android\Android Studio\jbr\bin\java", 
             "-Dcom.android.sdklib.toolsdir=" + os.path.join(sdk_root, "cmdline-tools", "latest", "lib"),
             "-cp", os.path.join(sdk_root, "cmdline-tools", "latest", "lib", "*"),
             "com.android.sdklib.tool.sdkmanager.SdkManagerCli",
             "--licenses"],
            input=b"y\n" * 10,
            capture_output=True,
            timeout=60
        )
        
        print("Downloading NDK 27.0.12077973...")
        result = subprocess.run(cmd, capture_output=True, timeout=300)
        
        if result.returncode == 0:
            print("NDK downloaded successfully!")
            return True
        else:
            print(f"Error: {result.stderr.decode()}")
            return False
            
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    if download_ndk():
        print("\nNDK setup complete. You can now run: flutter run")
    else:
        print("\nFailed to download NDK. Please download manually using Android Studio.")
