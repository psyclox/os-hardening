#!/bin/bash
# Apply ALL Linux Security Hardening
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================================="
echo "   Applying ALL Linux Security Hardening"
echo "=============================================="

bash "$SCRIPT_DIR/enable/enable_firewall.sh"
bash "$SCRIPT_DIR/enable/enable_ssh_security.sh"
bash "$SCRIPT_DIR/enable/enable_kernel_security.sh"
bash "$SCRIPT_DIR/enable/enable_auth_security.sh"
bash "$SCRIPT_DIR/enable/enable_network_security.sh"

echo "=============================================="
echo "   All Linux Security Measures Applied"
echo "   Reboot recommended"
echo "=============================================="
