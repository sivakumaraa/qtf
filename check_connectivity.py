#!/usr/bin/env python3
import socket
import sys

def check_port(host, port):
    """Check if a port is open"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex((host, port))
    sock.close()
    return result == 0

# Simple checks
print("=" * 50)
print("QuarryForce Connectivity Check")
print("=" * 50)

# Check backend
if check_port('127.0.0.1', 8000):
    print("✓ Backend: Listening on 127.0.0.1:8000")
else:
    print("✗ Backend: NOT listening on 127.0.0.1:8000")
    sys.exit(1)

print("\nSetup:")
print("- ADB Reverse: Must be set to tcp:8000 tcp:8000")
print("- Device: Must be connected via USB")
print("- App: Will use 127.0.0.1:8000/api (through reverse tunnel)")
print("\nReady for testing!")
