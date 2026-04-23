#!/bin/bash
# Enable Kernel Security - ASLR, sysctl hardening
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

SYSCTL_CONF="/etc/sysctl.d/99-hardening.conf"

echo "[1/6] Creating hardening sysctl configuration..."
cat > "$SYSCTL_CONF" << 'EOF'
# OS Hardening Toolkit - Kernel Security Settings

# Enable ASLR (Address Space Layout Randomization)
kernel.randomize_va_space = 2

# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Disable ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Enable TCP SYN cookies (prevent SYN flood attacks)
net.ipv4.tcp_syncookies = 1

# Disable IP source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Log martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore bogus ICMP error responses
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Enable reverse path filtering (prevent IP spoofing)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF

echo "[2/6] Applying sysctl settings..."
sysctl -p "$SYSCTL_CONF"

echo "[3/6] Disabling core dumps..."
echo "* hard core 0" >> /etc/security/limits.conf
echo "fs.suid_dumpable = 0" >> "$SYSCTL_CONF"
sysctl -w fs.suid_dumpable=0

echo "[4/6] Restricting dmesg access..."
echo "kernel.dmesg_restrict = 1" >> "$SYSCTL_CONF"
sysctl -w kernel.dmesg_restrict=1

echo "[5/6] Restricting kernel pointer exposure..."
echo "kernel.kptr_restrict = 2" >> "$SYSCTL_CONF"
sysctl -w kernel.kptr_restrict=2

echo "[6/6] Disabling magic SysRq key..."
echo "kernel.sysrq = 0" >> "$SYSCTL_CONF"
sysctl -w kernel.sysrq=0

echo "[OK] Kernel Security Enabled"
