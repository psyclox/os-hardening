# Linux Security Hardening Scripts

This folder contains shell scripts to harden your Linux operating system's security. Compatible with Debian/Ubuntu, RHEL/CentOS/Fedora, and Arch-based distributions.

## Directory Structure

* `enable/`: Contains individual scripts to enable specific security features.
* `disable/`: Contains scripts to disable/revert those features (use with caution).
* `apply_all_security.sh`: Master script to enable all security measures.
* `remove_all_security.sh`: Master script to disable all security measures.

## ⚠️ Important Notes and Warnings

1. **Run as root**: ALL scripts must be run with `sudo` or as the root user.
2. **Reboot after applying**: Some kernel and network changes require a restart.
3. **SSH Warning**: The SSH hardening script disables password authentication. **Ensure you have SSH key access configured before running it**, or you may lock yourself out.
4. **Testing**: Test on a non-critical system first before deploying to production.
5. **Backups**: Scripts create backups of configuration files before modifying them.

## How to Use

```bash
# Make scripts executable
chmod +x enable/*.sh disable/*.sh apply_all_security.sh remove_all_security.sh

# Apply all hardening
sudo ./apply_all_security.sh

# Or apply individually
sudo ./enable/enable_firewall.sh
sudo ./enable/enable_ssh_security.sh

# Revert specific hardening
sudo ./disable/disable_firewall.sh
```

## Script Reference Table

| Script | What It Does | Risk Level |
|--------|-------------|------------|
| `enable_firewall.sh` | Installs & configures UFW (deny incoming, allow outgoing, allow SSH) | Low |
| `disable_firewall.sh` | Disables UFW entirely | High |
| `enable_ssh_security.sh` | Disables root login, password auth, limits attempts, disables X11 | Medium |
| `disable_ssh_security.sh` | Restores permissive SSH defaults | High |
| `enable_kernel_security.sh` | ASLR, disables IP forwarding, ICMP hardening, SYN cookies, core dump protection | Low |
| `disable_kernel_security.sh` | Removes kernel hardening sysctl rules | Medium |
| `enable_auth_security.sh` | Password complexity (12+ chars), account lockout (5 attempts), password aging | Low |
| `disable_auth_security.sh` | Restores default password/auth policies | Medium |
| `enable_network_security.sh` | Disables unused protocols (DCCP, SCTP, RDS, TIPC), hardens TCP/IP, disables unnecessary services | Low |
| `disable_network_security.sh` | Removes network hardening, re-enables services | Medium |
| `apply_all_security.sh` | Runs all enable scripts | Low |
| `remove_all_security.sh` | Runs all disable scripts | High |

## Supported Distributions

* **Debian/Ubuntu** (apt-get)
* **RHEL/CentOS/Fedora** (yum/dnf)
* **Arch Linux** (pacman)

Scripts auto-detect the package manager and adapt accordingly.

## 🛑 Emergency Recovery — When Disable Scripts Don't Work

If hardening has locked you out (especially SSH lockout or PAM account lockout) and you can't run the disable scripts, use the manual recovery methods below.

### Before You Start: Prevention Checklist

Always do these **before** applying hardening:

1. **Keep physical/console access** to the machine (KVM, IPMI, or direct keyboard/monitor)
2. **Set up SSH key-based auth first** before running `enable_ssh_security.sh` (it disables password login)
3. **Keep a Linux Live USB** ready (Ubuntu, Fedora, or any distro)
4. **Snapshot your VM** if running in a virtual environment

---

### Recovery Method 1: Single-User / Rescue Mode (Physical Access Required)

If the system boots but you're locked out (SSH/PAM lockout):

1. Reboot the machine
2. At the **GRUB menu**, press `e` to edit the boot entry
3. Find the line starting with `linux` and append `init=/bin/bash` or `single` at the end
4. Press `Ctrl+X` to boot into single-user mode
5. Remount the filesystem as read-write:

```bash
mount -o remount,rw /
```

6. Fix the issue:

```bash
# If locked out of SSH (password auth disabled but no key set up)
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# If locked out by PAM faillock (too many failed attempts)
faillock --user YOUR_USERNAME --reset

# If PAM configuration is broken
sed -i '/pam_faillock/d' /etc/pam.d/common-auth

# If UFW is blocking everything
ufw disable

# If password policy is too strict and you can't set a new password
# Temporarily relax pwquality
echo "minlen = 1" > /etc/security/pwquality.conf

# If kernel hardening broke networking
rm -f /etc/sysctl.d/99-hardening.conf
rm -f /etc/sysctl.d/99-hardening-network.conf
sysctl --system
```

7. Reboot:

```bash
exec /sbin/init
```

---

### Recovery Method 2: Live USB Boot (When System Won't Boot)

If the system won't boot or single-user mode fails:

1. Boot from a **Linux Live USB** (Ubuntu, Fedora, etc.)
2. Mount the installed system's root partition:

```bash
# Find the correct partition
lsblk
# Mount it (replace sdX1 with your actual partition)
sudo mount /dev/sdX1 /mnt
# If separate /boot partition exists
sudo mount /dev/sdX2 /mnt/boot
```

3. Chroot into the installed system:

```bash
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
sudo chroot /mnt
```

4. Now fix the issue using the same commands from Recovery Method 1

5. Exit and reboot:

```bash
exit
sudo umount -R /mnt
sudo reboot
```

---

### Recovery Method 3: Restore Config Backups

The enable scripts create timestamped backups before modifying config files. Locate and restore them:

```bash
# SSH config backups
ls -la /etc/ssh/sshd_config.bak.*
# Restore the most recent backup
cp /etc/ssh/sshd_config.bak.YYYYMMDDHHMMSS /etc/ssh/sshd_config
systemctl restart sshd

# Password quality config backups
ls -la /etc/security/pwquality.conf.bak.*
cp /etc/security/pwquality.conf.bak.YYYYMMDDHHMMSS /etc/security/pwquality.conf
```

---

### Recovery Method 4: Remove All Hardening Files Manually

Nuclear option — delete all config files that the hardening scripts created:

```bash
# Remove kernel hardening
rm -f /etc/sysctl.d/99-hardening.conf
rm -f /etc/sysctl.d/99-hardening-network.conf

# Remove network protocol blacklist
rm -f /etc/modprobe.d/hardening-network.conf

# Remove PAM lockout rules
sed -i '/pam_faillock/d' /etc/pam.d/common-auth

# Disable firewall
ufw disable

# Restore SSH defaults
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Reload all sysctl
sysctl --system
```

---

### Common Lockout Scenarios & Quick Fixes

| Problem | Cause | Quick Fix |
|---------|-------|-----------|
| Can't SSH into server | `enable_ssh_security` disabled password auth | Console access → `sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd` |
| Account locked after failed logins | `enable_auth_security` set PAM faillock (5 attempts) | Console → `faillock --user USERNAME --reset` |
| Can't set a simple password | `enable_auth_security` requires 12+ char passwords | Console → edit `/etc/security/pwquality.conf` → set `minlen = 1` |
| No network connectivity | `enable_kernel_security` disabled IP forwarding/redirects | Console → `rm /etc/sysctl.d/99-hardening.conf && sysctl --system` |
| Services (Avahi, CUPS, Bluetooth) missing | `enable_network_security` disabled them | Console → `systemctl enable --now SERVICE_NAME` |
| UFW blocking needed traffic | `enable_firewall` set deny-incoming policy | Console → `ufw allow PORT/tcp` or `ufw disable` |
