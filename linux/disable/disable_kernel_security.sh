#!/bin/bash
# Disable Kernel Security - Remove hardening sysctl settings
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/3] Removing hardening sysctl configuration..."
rm -f /etc/sysctl.d/99-hardening.conf

echo "[2/3] Restoring default kernel settings..."
sysctl -w kernel.randomize_va_space=2
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.conf.all.accept_redirects=1
sysctl -w net.ipv4.conf.default.accept_redirects=1
sysctl -w net.ipv4.conf.all.send_redirects=1
sysctl -w net.ipv4.conf.default.send_redirects=1
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.conf.all.log_martians=0
sysctl -w kernel.dmesg_restrict=0
sysctl -w kernel.kptr_restrict=0
sysctl -w kernel.sysrq=1
sysctl -w fs.suid_dumpable=1

echo "[3/3] Reloading sysctl..."
sysctl --system >/dev/null 2>&1

echo "[OK] Kernel Security Disabled (defaults restored)"
