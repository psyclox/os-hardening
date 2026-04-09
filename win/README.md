# Windows Security Hardening Scripts

This folder contains scripts to harden your Windows operating system's security.

## Directory Structure

* `enable/`: Contains individual scripts to enable specific core security features.
* `disable/`: Contains scripts to disable those features (use with caution).
* `others/`: Contains supplementary security scripts segmented by function (Privacy, Updates, Lock Screen, AutoPlay).
* `usb_protect/`: Contains a background monitor script that automatically locks the workstation when a USB drive is inserted, effectively requiring the system password.
* `apply_all_security.bat`: Master script to enable all core security measures.
* `remove_all_security.bat`: Master script to disable all core security measures.

## ⚠️ Important Notes and Warnings

1. **Run as Administrator**: ALL scripts must be run as Administrator. Right-click the `.bat` file and select "Run as administrator".
2. **Reboot after applying**: Some changes require a system restart to take effect.
3. **Disable scripts**: These are NOT recommended for production/live environments. Disabling malware protection will put your system at critical risk!
4. **Testing**: Test on a non-critical device first before deploying widely.
5. **BitLocker**: Keep your BitLocker recovery key safe before making major changes, as security policies might trigger BitLocker recovery in some edge cases.

## Core Script Reference Table

| Script Name | What It Does | Risk Level |
| ----------- | ------------ | ---------- |
| `enable_login_security.bat` | CAD required, username shown | Low |
| `disable_login_security.bat` | No CAD, username shown | Low |
| `enable_network_security.bat` | Firewall, SMBv1 off, ports blocked | Low |
| `disable_network_security.bat` | Restores default network settings | Medium |
| `enable_credential_security.bat` | WDigest off, SEHOP on | Low |
| `disable_credential_security.bat` | WDigest on (passwords in memory) | High |
| `enable_malware_protection.bat` | Defender, ASR, PowerShell security | Low |
| `disable_malware_protection.bat` | Disables all malware protection | Critical |
| `enable_office_security.bat` | Macros and ActiveX disabled | Low |
| `disable_office_security.bat` | Macros and ActiveX enabled | High |
| `apply_all_security.bat` | Runs all enable scripts | Low |
| `remove_all_security.bat` | Runs all disable scripts | High |

## Supplementary Scripts (`others/` directory)

The `others` directory contains additional, specialized scripts for:
1. **Privacy Security:** Disables Telemetry, Cortana, and Ad ID tracking.
2. **Update Security:** Disables Peer-to-Peer Windows Updates (Delivery Optimization).
3. **Lock Screen Security:** Disables camera and app notifications on the lock screen.
4. **AutoPlay Security:** Disables AutoPlay for all drives to prevent malicious auto-execution.

Each segment has its own `enable` and `disable` scripts, alongside master `apply_others_security.bat` and `remove_others_security.bat` scripts inside the `others` folder. Check `others/README.md` for more details.

## USB Protection

The `usb_protect` folder includes a script that runs in the background. When a new USB drive is connected, it automatically locks the Windows workstation (`Win+L`). You must then enter your system password to unlock and access the system.
Run `start_usb_monitor.bat` as Administrator to start monitoring.
