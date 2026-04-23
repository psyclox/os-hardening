#!/bin/bash
# Disable Firewall Security - Disable macOS Application Firewall
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[WARNING] Disabling the firewall will expose your Mac to network attacks!"
read -p "Are you sure? (Y/N): " confirm
if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    exit 0
fi

echo "[1/2] Disabling macOS Application Firewall..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off

echo "[2/2] Disabling Stealth Mode..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode off

echo "[OK] Firewall Security Disabled"
