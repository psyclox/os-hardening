#!/bin/bash
# Disable SSH Security - Restore default SSH settings
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"

echo "[1/5] Restoring SSH defaults..."
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"

echo "[2/5] Enabling password authentication..."
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"

echo "[3/5] Allowing empty passwords (default)..."
sed -i 's/^PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSHD_CONFIG"

echo "[4/5] Restoring max auth tries to default (6)..."
sed -i 's/^MaxAuthTries.*/MaxAuthTries 6/' "$SSHD_CONFIG"

echo "[5/5] Enabling X11 forwarding..."
sed -i 's/^X11Forwarding.*/X11Forwarding yes/' "$SSHD_CONFIG"

echo "Restarting SSH daemon..."
if command -v systemctl &>/dev/null; then
    systemctl restart sshd
else
    service ssh restart
fi

echo "[OK] SSH Security Disabled (defaults restored)"
echo "[WARNING] Root login and password authentication are now enabled!"
