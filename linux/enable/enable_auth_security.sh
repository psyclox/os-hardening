#!/bin/bash
# Enable Authentication Security - Password policy, account lockout
# Must be run as root (sudo)

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

echo "[1/5] Installing libpam-pwquality (if not present)..."
if command -v apt-get &>/dev/null; then
    apt-get install -y libpam-pwquality >/dev/null 2>&1
elif command -v yum &>/dev/null; then
    yum install -y pam_pwquality >/dev/null 2>&1
fi

echo "[2/5] Configuring password quality requirements..."
PWQUALITY_CONF="/etc/security/pwquality.conf"
if [ -f "$PWQUALITY_CONF" ]; then
    cp "$PWQUALITY_CONF" "$PWQUALITY_CONF.bak.$(date +%Y%m%d%H%M%S)"
fi
cat > "$PWQUALITY_CONF" << 'EOF'
# OS Hardening Toolkit - Password Quality Settings
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
maxrepeat = 3
reject_username
enforce_for_root
EOF

echo "[3/5] Configuring password aging policy..."
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

echo "[4/5] Configuring account lockout (5 failed attempts, 15 min lockout)..."
PAM_AUTH="/etc/pam.d/common-auth"
if [ -f "$PAM_AUTH" ]; then
    if ! grep -q "pam_faillock" "$PAM_AUTH"; then
        cp "$PAM_AUTH" "$PAM_AUTH.bak.$(date +%Y%m%d%H%M%S)"
        echo "auth required pam_faillock.so preauth silent deny=5 unlock_time=900" >> "$PAM_AUTH"
        echo "auth [default=die] pam_faillock.so authfail deny=5 unlock_time=900" >> "$PAM_AUTH"
    fi
fi

echo "[5/5] Setting default umask to 027..."
sed -i 's/^UMASK.*/UMASK           027/' /etc/login.defs

echo "[OK] Authentication Security Enabled"
echo "    Password policy: min 12 chars, requires upper/lower/digit/special"
echo "    Account lockout: 5 failed attempts = 15 min lockout"
echo "    Password aging: max 90 days, min 7 days, warn 14 days"
