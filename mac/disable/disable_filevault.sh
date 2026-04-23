#!/bin/bash
# Disable FileVault - Remove full-disk encryption
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[WARNING] Disabling FileVault will decrypt your entire disk!"
echo "          This process can take a long time."
read -p "Are you sure? (Y/N): " confirm
if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    exit 0
fi

echo "Disabling FileVault..."
fdesetup disable

echo "[OK] FileVault is being disabled."
echo "    Decryption will continue in the background."
echo "    Check progress with: fdesetup status"
