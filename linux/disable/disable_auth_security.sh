#!/bin/bash
# Disable Authentication Security - Restore default password/auth settings
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[WARNING] This will weaken password and authentication policies!"
read -p "Are you sure? (Y/N): " confirm
if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
    exit 0
fi

echo "[1/3] Restoring default password quality settings..."
PWQUALITY_CONF="/etc/security/pwquality.conf"
if [ -f "$PWQUALITY_CONF.bak."* ] 2>/dev/null; then
    LATEST_BACKUP=$(ls -t "$PWQUALITY_CONF.bak."* 2>/dev/null | head -1)
    if [ -n "$LATEST_BACKUP" ]; then
        cp "$LATEST_BACKUP" "$PWQUALITY_CONF"
        echo "    Restored from backup: $LATEST_BACKUP"
    fi
else
    cat > "$PWQUALITY_CONF" << 'EOF'
# Default password quality settings
minlen = 8
EOF
fi

echo "[2/3] Restoring default password aging..."
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   99999/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   0/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

echo "[3/3] Removing account lockout configuration..."
PAM_AUTH="/etc/pam.d/common-auth"
if [ -f "$PAM_AUTH" ]; then
    sed -i '/pam_faillock/d' "$PAM_AUTH"
fi

echo "[OK] Authentication Security Disabled (defaults restored)"
