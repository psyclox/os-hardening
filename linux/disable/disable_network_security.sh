#!/bin/bash
# Disable Network Security - Remove network hardening
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/3] Removing network protocol blacklist..."
rm -f /etc/modprobe.d/hardening-network.conf

echo "[2/3] Removing network sysctl hardening..."
rm -f /etc/sysctl.d/99-hardening-network.conf
sysctl --system >/dev/null 2>&1

echo "[3/3] Re-enabling disabled services..."
for service in avahi-daemon cups bluetooth; do
    if systemctl list-unit-files | grep -q "$service"; then
        systemctl enable "$service" 2>/dev/null
        systemctl start "$service" 2>/dev/null
        echo "    Re-enabled: $service"
    fi
done

echo "[OK] Network Security Disabled (defaults restored)"
