#!/bin/bash
# Enable Gatekeeper - App installation restrictions
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/3] Enabling Gatekeeper (App Store + identified developers only)..."
spctl --master-enable

echo "[2/3] Enabling app assessment..."
spctl --enable --label "Developer ID"

echo "[3/3] Verifying Gatekeeper status..."
spctl --status

echo "[OK] Gatekeeper Enabled"
echo "    Only apps from the App Store and identified developers can run."
