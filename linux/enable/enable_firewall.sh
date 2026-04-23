#!/bin/bash
# Enable Firewall Security - UFW configuration
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/4] Installing UFW (if not present)..."
if command -v apt-get &>/dev/null; then
    apt-get install -y ufw >/dev/null 2>&1
elif command -v yum &>/dev/null; then
    yum install -y ufw >/dev/null 2>&1
elif command -v pacman &>/dev/null; then
    pacman -S --noconfirm ufw >/dev/null 2>&1
fi

echo "[2/4] Setting default policies (deny incoming, allow outgoing)..."
ufw default deny incoming
ufw default allow outgoing

echo "[3/4] Allowing SSH (port 22)..."
ufw allow ssh

echo "[4/4] Enabling UFW..."
echo "y" | ufw enable

echo "[OK] Firewall Security Enabled"
echo "    Current status:"
ufw status verbose
