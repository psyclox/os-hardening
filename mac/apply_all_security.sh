#!/bin/bash
# Apply ALL macOS Security Hardening
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================================="
echo "   Applying ALL macOS Security Hardening"
echo "=============================================="

bash "$SCRIPT_DIR/enable/enable_firewall.sh"
bash "$SCRIPT_DIR/enable/enable_filevault.sh"
bash "$SCRIPT_DIR/enable/enable_gatekeeper.sh"
bash "$SCRIPT_DIR/enable/enable_network_security.sh"
bash "$SCRIPT_DIR/enable/enable_privacy_security.sh"

echo "=============================================="
echo "   All macOS Security Measures Applied"
echo "   Reboot recommended"
echo "=============================================="
