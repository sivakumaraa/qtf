#!/usr/bin/env python3
"""Download Android NDK 27.0.12077973 from Google's CDN"""

import urllib.request
import os
import zipfile
from pathlib import Path
import sys

def download_ndk():
    """Download NDK 27.0.12077973 for Windows"""
    
    sdk_root = r"C:\Users\sivak\AppData\Local\Android\Sdk"
    ndk_root = os.path.join(sdk_root, "ndk", "27.0.12077973")
    
    # Skip if already fully installed
    clang_path = os.path.join(ndk_root, "toolchains", "llvm", "prebuilt", "windows-x86_64", "bin", "clang.exe")
    if os.path.exists(clang_path):
        print(f"NDK already installed at {ndk_root}")
        return True
    
    print("Downloading Android NDK 27.0.12077973...")
    
    # NDK download URL from Google
    url = "https://dl.google.com/android/repository/android-ndk-r27-windows.zip"
    zip_path = os.path.join(sdk_root, "android-ndk-r27-windows.zip")
    
    try:
        print(f"Downloading from: {url}")
        urllib.request.urlretrieve(url, zip_path, reporthook)
        
        print(f"\nExtracting to: {ndk_root}")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            # Extract all files
            zip_ref.extractall(sdk_root)
            
            # Rename to correct version folder
            extracted_path = os.path.join(sdk_root, "android-ndk-r27")
            if os.path.exists(extracted_path):
                ndk_version_path = os.path.join(sdk_root, "ndk", "27.0.12077973")
                os.makedirs(os.path.dirname(ndk_version_path), exist_ok=True)
                
                # Move extracted NDK to correct location
                if os.path.exists(ndk_version_path):
                    import shutil
                    shutil.rmtree(ndk_version_path)
                os.rename(extracted_path, ndk_version_path)
        
        # Clean up zip
        os.remove(zip_path)
        
        print("NDK installation complete!")
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        print("Failed to download NDK. Please download manually from:")
        print("  https://developer.android.com/ndk/downloads")
        return False

def reporthook(blocknum, blocksize, totalsize):
    """Progress indicator for downloads"""
    readsofar = blocknum * blocksize
    if totalsize > 0:
        percent = readsofar * 1e2 / totalsize
        s = f"\r{readsofar:,} / {totalsize:,} bytes ({percent:.0f}%)"
        sys.stderr.write(s)

if __name__ == "__main__":
    if download_ndk():
        print("\nNDK ready! You can now run: flutter run")
        sys.exit(0)
    else:
        sys.exit(1)
