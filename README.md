# OS Hardening Toolkit

A comprehensive, cross-platform toolkit of security hardening scripts for **Windows**, **Linux**, and **macOS**. Each platform includes modular scripts to enable or disable specific security policies, with master scripts for bulk operations.

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
│   │   └── remove_all_security.bat
│   └── powershell/                    # PowerShell (.ps1) equivalents
│       ├── enable/
│       ├── disable/
│       ├── others/
│       ├── apply_all_security.ps1
│       └── remove_all_security.ps1
├── linux/                             # Linux hardening
│   ├── enable/                        # Security enable scripts
│   ├── disable/                       # Security disable scripts
│   ├── apply_all_security.sh
│   └── remove_all_security.sh
└── mac/                               # macOS hardening
    ├── enable/                        # Security enable scripts
    ├── disable/                       # Security disable scripts
    ├── apply_all_security.sh
    └── remove_all_security.sh
```

## Windows Hardening (`windows/`)

Available in both **CMD** and **PowerShell** formats with identical functionality.

### Core Hardening Areas

* **Login Security:** Enforces Ctrl+Alt+Delete (CAD) and hides the last logged-in user.
* **Network & Firewall Security:** Blocks dangerous ports (445, 3389), disables SMBv1, and configures Windows Firewall.
* **Credential Protection:** Hardens memory against credential dumping (disables WDigest, enables SEHOP).
* **Malware Protection:** Enforces Windows Defender, Attack Surface Reduction (ASR), and PowerShell script block logging.
* **Office Security:** Disables dangerous VBA Macros and ActiveX controls.

### Supplementary Hardening (`others/`)

* **Privacy:** Disables Telemetry, Advertising IDs, and Cortana tracking.
* **Windows Updates:** Disables P2P Update delivery optimization.
* **Lock Screen:** Prevents camera access and notifications while locked.
* **AutoPlay:** Disables AutoPlay to mitigate malicious USB infections.
* **USB Protection:** Background monitor that locks the workstation when a USB drive is inserted.

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
```

```powershell
# PowerShell - Run as Administrator
cd windows\powershell
.\apply_all_security.ps1
```

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

* **Windows:** Keep your BitLocker recovery key safe. Create a system restore point first.
* **Linux:** Ensure SSH key access is configured before hardening SSH (password auth gets disabled).
* **macOS:** Store the FileVault recovery key securely — losing it may result in permanent data loss.

## 🛑 Emergency Recovery — If Something Goes Wrong

Hardening scripts modify deep system settings. In rare cases, the changes may prevent normal system use **and** block the disable scripts from running (e.g., execution policy blocks scripts, SSH lockout, Gatekeeper blocks apps). Each platform README includes **detailed emergency recovery instructions** — read them before applying hardening.

### Quick Reference

| Platform | Recovery Entry Point | Where to Find Full Guide |
|----------|---------------------|--------------------------|
| **Windows** | Boot into **Safe Mode** (`Shift + Restart`) or **WinRE** (boot from USB → Repair) | [`windows/README.md`](windows/README.md#-emergency-recovery--when-disable-scripts-dont-work) |
| **Linux** | Boot into **Single-User Mode** (GRUB → append `init=/bin/bash`) or **Live USB** | [`linux/README.md`](linux/README.md#-emergency-recovery--when-disable-scripts-dont-work) |
| **macOS** | Boot into **Recovery Mode** (`⌘+R`) or **Internet Recovery** (`⌥+⌘+R`) | [`mac/README.md`](mac/README.md#-emergency-recovery--when-disable-scripts-dont-work) |

### General Prevention Tips (All Platforms)

1. **Always create a backup/snapshot** before applying hardening (System Restore, VM snapshot, Time Machine)
2. **Apply scripts one at a time** — don't run `apply_all_security` without first testing individual scripts
3. **Keep physical console access** or an alternative login method available
4. **Save recovery keys** (BitLocker, FileVault) in a secure, separate location
5. **Test on a non-production machine first** — never deploy untested hardening to a live server

## Contributing

Each platform directory contains its own `README.md` with detailed script references and usage instructions.

## License

This toolkit is provided as-is for educational and security hardening purposes. Use at your own risk.
