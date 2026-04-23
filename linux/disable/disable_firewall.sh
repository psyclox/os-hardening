#!/bin/bash
# Disable Firewall Security - Disable UFW
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[WARNING] Disabling the firewall will expose all ports!"
read -p "Are you sure? (Y/N): " confirm
if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    exit 0
fi

echo "Disabling UFW..."
ufw disable

echo "[OK] Firewall Security Disabled"
ufw status
