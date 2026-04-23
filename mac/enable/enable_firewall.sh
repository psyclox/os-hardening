#!/bin/bash
# Enable Firewall Security - macOS Application Firewall + Stealth Mode
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/3] Enabling macOS Application Firewall..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

echo "[2/3] Enabling Stealth Mode (ignore ICMP/ping)..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

echo "[3/3] Enabling logging..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on

echo "[OK] Firewall Security Enabled"
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode
