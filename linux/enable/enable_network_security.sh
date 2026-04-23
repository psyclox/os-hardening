#!/bin/bash
# Enable Network Security - Disable unused protocols, harden TCP/IP stack
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/4] Disabling unused network protocols..."
MODPROBE_CONF="/etc/modprobe.d/hardening-network.conf"
cat > "$MODPROBE_CONF" << 'EOF'
# OS Hardening Toolkit - Disable unused network protocols
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
EOF

echo "[2/4] Disabling IPv6 (if not needed)..."
SYSCTL_NET="/etc/sysctl.d/99-hardening-network.conf"
cat > "$SYSCTL_NET" << 'EOF'
# OS Hardening Toolkit - Network Security Settings

# Disable IPv6 (uncomment if IPv6 is not needed)
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1

# Ignore ICMP echo requests (stealth mode)
# net.ipv4.icmp_echo_ignore_all = 1

# Protect against TCP TIME-WAIT assassination
net.ipv4.tcp_rfc1337 = 1

# Disable TCP timestamps (prevent uptime disclosure)
net.ipv4.tcp_timestamps = 0
EOF
sysctl -p "$SYSCTL_NET"

echo "[3/4] Disabling unnecessary services..."
for service in avahi-daemon cups bluetooth; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        systemctl stop "$service"
        systemctl disable "$service"
        echo "    Disabled: $service"
    fi
done

echo "[4/4] Restricting permissions on network configuration files..."
chmod 600 /etc/hosts.allow 2>/dev/null
chmod 600 /etc/hosts.deny 2>/dev/null

echo "[OK] Network Security Enabled"
