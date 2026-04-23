#!/bin/bash
# Remove ALL macOS Security Hardening (Restore Defaults)
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================================="
echo "   WARNING: Removing ALL macOS Security Hardening"
echo "   Your system will be less secure"
echo "=============================================="
read -p "Are you sure? (Y/N): " confirm
if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    exit 0
fi

bash "$SCRIPT_DIR/disable/disable_firewall.sh"
bash "$SCRIPT_DIR/disable/disable_filevault.sh"
bash "$SCRIPT_DIR/disable/disable_gatekeeper.sh"
bash "$SCRIPT_DIR/disable/disable_network_security.sh"
bash "$SCRIPT_DIR/disable/disable_privacy_security.sh"

echo "=============================================="
echo "   All macOS Security Measures Removed"
echo "   Default settings restored"
echo "=============================================="
