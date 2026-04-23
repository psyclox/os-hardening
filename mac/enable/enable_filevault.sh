#!/bin/bash
# Enable FileVault - Full-disk encryption
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/2] Checking FileVault status..."
FV_STATUS=$(fdesetup status)
echo "    Current status: $FV_STATUS"

if echo "$FV_STATUS" | grep -q "On"; then
    echo "[OK] FileVault is already enabled"
    exit 0
fi

echo "[2/2] Enabling FileVault..."
echo "    NOTE: This will prompt for user credentials and generate a recovery key."
echo "    IMPORTANT: Store the recovery key securely - you will need it if you forget your password!"
echo ""
fdesetup enable

echo "[OK] FileVault Enabled"
echo "    A reboot may be required to complete encryption."
echo "    You can check progress with: fdesetup status"
