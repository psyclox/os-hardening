# OS Hardening Toolkit

A comprehensive, cross-platform toolkit of security hardening scripts for **Windows**, **Linux**, and **macOS**. Each platform includes modular scripts to enable or disable specific security policies, with master scripts for bulk operations.

> **Windows scripts are at Version 2.0** — Major security overhaul addressing Defender UI bypass, Firewall lockdown, username hiding, admin bypass, and more. See [`windows/README.md`](windows/README.md#whats-new-in-v2).

## Supported Platforms

| Platform | Directory | Script Format | Privilege Required |
|----------|-----------|--------------|-------------------|
| Windows | `windows/` | `.bat` (CMD) and `.ps1` (PowerShell) | Run as Administrator |
| Linux | `linux/` | `.sh` (Bash) | `sudo` / root |
| macOS | `mac/` | `.sh` (Bash) | `sudo` / root |

## Directory Structure

```
os-hardening/
├── windows/                           # Windows hardening
│   ├── cmd/                           # Batch (.bat) scripts
│   │   ├── enable/                    # Core security enable scripts
│   │   ├── disable/                   # Core security disable scripts
│   │   ├── others/                    # Supplementary scripts + USB monitor
│   │   ├── apply_all_security.bat
│   │   ├── remove_all_security.bat
│   │   ├── check_security_status.bat  # ★ NEW
│   │   ├── admin_emergency_unlock.bat # ★ NEW
│   │   └── admin_relock.bat           # ★ NEW
│   └── powershell/                    # PowerShell (.ps1) equivalents
│       ├── enable/
│       ├── disable/
│       ├── others/
│       ├── apply_all_security.ps1
│       ├── remove_all_security.ps1
│       ├── check_security_status.ps1  # ★ NEW
│       ├── admin_emergency_unlock.ps1 # ★ NEW
│       └── admin_relock.ps1           # ★ NEW
├── linux/                             # Linux hardening
│   ├── enable/
│   ├── disable/
│   ├── apply_all_security.sh
│   └── remove_all_security.sh
└── mac/                               # macOS hardening
    ├── enable/
    ├── disable/
    ├── apply_all_security.sh
    └── remove_all_security.sh
```

## Windows Hardening (`windows/`)

Available in both **CMD** and **PowerShell** formats with identical functionality.

### Core Hardening Areas (v2.0)

* **Login Security:** Enforces Ctrl+Alt+Delete (CAD) and **hides the last logged-in username** on the lock screen (employees type their password only — username is not shown to prevent information leakage).
* **Network & Firewall Security:** Blocks dangerous ports (445, 3389), disables SMBv1, LLMNR, NetBIOS. Firewall is **locked via Group Policy** — the toggle is greyed out in Windows Security UI so employees cannot turn it off.
* **Credential Protection:** Disables WDigest (no plaintext passwords in memory), enables SEHOP, and enables **LSA RunAsPPL** to block Mimikatz-style credential dumping tools.
* **Malware Protection:** Enforces Windows Defender with **Tamper Protection** (prevents employee UI tampering), **10 ASR rules** (email, USB, Office, JS/VBScript attack surface reduction), cloud protection, and PowerShell script block logging.
* **Office Security:** Disables VBA Macros and ActiveX via both HKCU **and HKLM Group Policy paths** (employees cannot override), covering Office 2013 and 2016/2019/365.

### New in v2.0

* **`check_security_status`** — Instantly see ✅/❌ status for every hardening setting
* **`admin_emergency_unlock`** — Password-protected (SHA-256 hash) bypass for the IT admin to run maintenance scripts safely. Every unlock/failure is logged.
* **`admin_relock`** — One-click re-hardening after admin work is complete
* **Audit logging** — Every script logs to `C:\ProgramData\OrgSecurity\security_log.txt`
* **USB monitor as Scheduled Task** — Now runs under SYSTEM, persists on reboot, unkillable by employees

### Supplementary Hardening (`others/`)

* **Privacy:** Disables Telemetry, Advertising IDs, and Cortana tracking.
* **Windows Updates:** Disables P2P Update delivery optimization.
* **Lock Screen:** Prevents camera access and notifications while locked.
* **AutoPlay:** Disables AutoPlay to mitigate malicious USB infections.
* **USB Protection:** Background monitor (SYSTEM Scheduled Task) that locks the workstation when a USB drive is inserted.

## Linux Hardening (`linux/`)

### Hardening Areas

* **Firewall (UFW):** Installs and configures UFW with deny-incoming/allow-outgoing policy.
* **SSH Security:** Disables root login, enforces key-based authentication, limits auth attempts.
* **Kernel Security:** Enables ASLR, disables IP forwarding, ICMP hardening, SYN cookies, restricts core dumps.
* **Authentication:** Enforces strong password policy (12+ chars), account lockout after 5 failed attempts, password aging.
* **Network Security:** Disables unused protocols (DCCP, SCTP, RDS, TIPC), hardens TCP/IP stack, disables unnecessary services.

### Supported Distributions

* Debian / Ubuntu (apt-get)
* RHEL / CentOS / Fedora (yum/dnf)
* Arch Linux (pacman)

## macOS Hardening (`mac/`)

### Hardening Areas

* **Firewall:** Enables macOS Application Firewall with stealth mode and logging.
* **FileVault:** Enables full-disk encryption.
* **Gatekeeper:** Enforces app verification (App Store + identified developers only).
* **Network Security:** Disables Bonjour advertising, captive portal, restricts AirDrop, disables Wake-on-LAN.
* **Privacy:** Disables analytics sharing, personalized ads, Siri data sharing, Safari search suggestions.

### Requirements

* macOS 10.14 (Mojave) or later

## How to Use

### Windows

```batch
:: CMD - Run as Administrator
cd windows\cmd
apply_all_security.bat

:: Then verify:
check_security_status.bat
```

```powershell
# PowerShell - Run as Administrator
cd windows\powershell
.\apply_all_security.ps1

# Then verify:
.\check_security_status.ps1
```

### Admin Maintenance (Windows)

```batch
:: When you need to run a script on a hardened machine:
cd windows\cmd
admin_emergency_unlock.bat    :: Enter your passphrase
:: ... do your work ...
admin_relock.bat              :: Re-apply hardening when done
```

> ⚠️ **Before deploying:** Change the default passphrase hash in `admin_emergency_unlock.bat/.ps1`. See [`windows/README.md`](windows/README.md#admin-emergency-unlock-for-the-creatoit-admin) for instructions.

### Linux

```bash
cd linux
chmod +x enable/*.sh disable/*.sh *.sh
sudo ./apply_all_security.sh
```

### macOS

```bash
cd mac
chmod +x enable/*.sh disable/*.sh *.sh
sudo ./apply_all_security.sh
```

## ⚠️ Warnings

> **CAUTION:** Always ensure you have proper backups before applying hardening policies. While all changes can be reverted using the provided `disable` scripts, exercise caution in production environments.

* **Windows:** Keep your BitLocker recovery key safe. Create a system restore point first. Change the admin unlock passphrase before deploying.
* **Linux:** Ensure SSH key access is configured before hardening SSH (password auth gets disabled).
* **macOS:** Store the FileVault recovery key securely — losing it may result in permanent data loss.

## Known Limitations

| Limitation | Platform | Impact |
|-----------|----------|--------|
| Group Policy Firewall lock requires Pro/Enterprise | Windows | Home edition users may still toggle firewall |
| Tamper Protection requires Security Center service | Windows | If SHSVC is stopped, TP can be bypassed |
| Registry changes can be removed from Safe Mode | Windows | Physical access = attacker can revert; mitigate with BitLocker |
| LSA RunAsPPL requires reboot to take effect | Windows | Credential protection only active after reboot |
| Office GP covers 15.0 and 16.0 only | Windows | Older Office installations not covered |

## 🛑 Emergency Recovery — If Something Goes Wrong

Hardening scripts modify deep system settings. In rare cases, the changes may prevent normal system use **and** block the disable scripts from running. Each platform README includes **detailed emergency recovery instructions**.

### Quick Reference

| Platform | First Try | Recovery Entry Point | Full Guide |
|----------|-----------|---------------------|----|
| **Windows** | `admin_emergency_unlock.bat` → or `emergency_nuke.bat` from USB | Boot into **Safe Mode** (`Shift+Power→Restart`) or **WinRE** | [`MANUAL_RECOVERY.md`](windows/MANUAL_RECOVERY.md) — copy-paste commands, no scripts needed |
| **Linux** | SSH from another machine | **Single-User Mode** (GRUB → append `init=/bin/bash`) or **Live USB** | [`linux/README.md`](linux/README.md#-emergency-recovery--when-disable-scripts-dont-work) |
| **macOS** | Another admin account | **Recovery Mode** (`⌘+R`) or **Internet Recovery** (`⌥+⌘+R`) | [`mac/README.md`](mac/README.md#-emergency-recovery--when-disable-scripts-dont-work) |

### General Prevention Tips (All Platforms)

1. **Always create a backup/snapshot** before applying hardening (System Restore, VM snapshot, Time Machine)
2. **Apply scripts one at a time** — don't run `apply_all_security` without first testing individual scripts
3. **Keep physical console access** or an alternative login method available
4. **Save recovery keys** (BitLocker, FileVault) in a secure, separate location
5. **Test on a non-production machine first** — never deploy untested hardening to a live machine
6. **Change the admin passphrase** (Windows) before deploying — the default is for testing only
7. **Run `check_security_status`** after every `apply_all_security` to verify settings took effect

## Contributing

Each platform directory contains its own `README.md` with detailed script references and usage instructions.

## License

This toolkit is provided as-is for educational and security hardening purposes. Use at your own risk.
