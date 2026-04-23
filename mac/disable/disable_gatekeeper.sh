#!/bin/bash
# Disable Gatekeeper - Allow apps from anywhere
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[WARNING] Disabling Gatekeeper allows unsigned/malicious apps to run!"
read -p "Are you sure? (Y/N): " confirm
if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    exit 0
fi

echo "Disabling Gatekeeper..."
spctl --master-disable

echo "[OK] Gatekeeper Disabled"
echo "    WARNING: Apps from any source can now run without verification!"
spctl --status
