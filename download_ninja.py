#!/usr/bin/env python3
"""Download and install Ninja for CMake"""

import urllib.request
import os
import zipfile
import shutil
from pathlib import Path
import sys

def download_ninja():
    """Download Ninja for Windows (needed by CMake)"""
    
    cmake_root = r"C:\Users\sivak\AppData\Local\Android\Sdk\cmake\3.22.1"
    ninja_bin = os.path.join(cmake_root, "bin", "ninja.exe")
    
    # Skip if already installed
    if os.path.exists(ninja_bin):
        print(f"Ninja already installed at {ninja_bin}")
        return True
    
    print("Downloading Ninja for Windows...")
    
    # Ninja download URL - version 1.11.1
    url = "https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-win.zip"
    zip_path = os.path.join(cmake_root, "ninja-win.zip")
    bin_dir = os.path.join(cmake_root, "bin")
    
    try:
        print(f"Downloading from: {url}")
        urllib.request.urlretrieve(url, zip_path, reporthook)
        
        print(f"\nExtracting to: {bin_dir}")
        os.makedirs(bin_dir, exist_ok=True)
        
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            # Extract all files to bin directory
            zip_ref.extractall(bin_dir)
        
        # Clean up zip
        os.remove(zip_path)
        
        print("Ninja installation complete!")
        print(f"Ninja location: {ninja_bin}")
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        print("Failed to download Ninja. Please download manually from:")
        print("  https://github.com/ninja-build/ninja/releases/tag/v1.11.1")
        return False

def reporthook(blocknum, blocksize, totalsize):
    """Progress indicator for downloads"""
    readsofar = blocknum * blocksize
    if totalsize > 0:
        percent = readsofar * 1e2 / totalsize
        s = f"\r{readsofar:,} / {totalsize:,} bytes ({percent:.0f}%)"
        sys.stderr.write(s)

if __name__ == "__main__":
    if download_ninja():
        print("\nNinja ready! You can now run: flutter run")
        sys.exit(0)
    else:
        sys.exit(1)
