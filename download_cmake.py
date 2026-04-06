#!/usr/bin/env python3
"""Download and install CMake for Android NDK"""

import urllib.request
import os
import zipfile
import shutil
from pathlib import Path
import sys

def download_cmake():
    """Download CMake 3.22.1 for Windows"""
    
    sdk_root = r"C:\Users\sivak\AppData\Local\Android\Sdk"
    cmake_root = os.path.join(sdk_root, "cmake", "3.22.1")
    cmake_exe = os.path.join(cmake_root, "bin", "cmake.exe")
    
    # Skip if already installed
    if os.path.exists(cmake_exe):
        print(f"CMake already installed at {cmake_root}")
        return True
    
    print("Downloading CMake 3.22.1 for Windows...")
    
    # CMake download URL
    url = "https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-windows-x86_64.zip"
    zip_path = os.path.join(sdk_root, "cmake-3.22.1-windows-x86_64.zip")
    
    try:
        print(f"Downloading from: {url}")
        urllib.request.urlretrieve(url, zip_path, reporthook)
        
        print(f"\nExtracting to: {cmake_root}")
        os.makedirs(cmake_root, exist_ok=True)
        
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            # Extract all files
            zip_ref.extractall(sdk_root)
            
            # Find the extracted folder (cmake-3.22.1-windows-x86_64)
            extracted_path = os.path.join(sdk_root, "cmake-3.22.1-windows-x86_64")
            if os.path.exists(extracted_path):
                # Move contents of extracted folder to cmake/3.22.1
                for item in os.listdir(extracted_path):
                    src = os.path.join(extracted_path, item)
                    dst = os.path.join(cmake_root, item)
                    if os.path.exists(dst):
                        shutil.rmtree(dst)
                    shutil.move(src, dst)
                
                # Remove empty extracted folder
                os.rmdir(extracted_path)
        
        # Clean up zip
        os.remove(zip_path)
        
        print("CMake installation complete!")
        print(f"CMake location: {cmake_root}")
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        print("Failed to download CMake. Please download manually from:")
        print("  https://github.com/Kitware/CMake/releases/tag/v3.22.1")
        print("  OR use Android Studio SDK Manager to install CMake")
        return False

def reporthook(blocknum, blocksize, totalsize):
    """Progress indicator for downloads"""
    readsofar = blocknum * blocksize
    if totalsize > 0:
        percent = readsofar * 1e2 / totalsize
        s = f"\r{readsofar:,} / {totalsize:,} bytes ({percent:.0f}%)"
        sys.stderr.write(s)

if __name__ == "__main__":
    if download_cmake():
        print("\nCMake ready! You can now run: flutter run")
        sys.exit(0)
    else:
        sys.exit(1)
