#!/bin/bash
# Enable SSH Security - Harden SSH daemon configuration
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="$SSHD_CONFIG.bak.$(date +%Y%m%d%H%M%S)"

echo "[1/6] Backing up sshd_config..."
cp "$SSHD_CONFIG" "$BACKUP"
echo "    Backup saved to: $BACKUP"

echo "[2/6] Disabling root login..."
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"

echo "[3/6] Disabling password authentication (key-based only)..."
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"

echo "[4/6] Disabling empty passwords..."
sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSHD_CONFIG"

echo "[5/6] Setting max authentication attempts to 3..."
sed -i 's/^#\?MaxAuthTries.*/MaxAuthTries 3/' "$SSHD_CONFIG"

echo "[6/6] Disabling X11 forwarding..."
sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' "$SSHD_CONFIG"

echo "Restarting SSH daemon..."
if command -v systemctl &>/dev/null; then
    systemctl restart sshd
else
    service ssh restart
fi

echo "[OK] SSH Security Enabled"
echo "    WARNING: Ensure you have SSH key access before disconnecting!"
