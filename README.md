# OS Hardening Toolkit

This repository contains tools and scripts for hardening the security of operating systems. 

Currently, the toolkit includes a comprehensive suite of security scripts for **Windows**.

## Windows Hardening (`win/`)

The Windows section (`win/`) provides modular batch scripts designed to improve the security posture of Windows machines by applying proven system and registry policies.

### Core Hardening Areas

* **Login Security:** Enforces Ctrl+Alt+Delete (CAD) and hides the last logged-in user.
* **Network & Firewall Security:** Blocks dangerous ports (445, 3389), disables SMBv1, and configures Windows Firewall safely.
* **Credential Protection:** Hardens memory against credential dumping (disables WDigest plaintext passwords, enables SEHOP).
* **Malware Protection:** Strongly enforces Windows Defender rules, Attack Surface Reduction (ASR), and PowerShell scriptblock logging.
* **Office Security:** Disables dangerous VBA Macros and ActiveX controls.

### Supplementary Hardening (`win/others/`)

* **Privacy Features:** Disables Telemetry, Advertising IDs, and Cortana tracking.
* **Windows Updates:** Disables P2P Update delivery optimization.
* **Lock Screen Safety:** Prevents camera access and notifications while locked.
* **AutoPlay:** Disables AutoPlay to mitigate malicious USB infections.

### USB Protection Daemon (`win/usb_protect/`)

A background PowerShell/WMI monitor that instantly locks the target workstation whenever a removable USB drive is inserted, effectively enforcing system authentication before any data access can occur.

## How to Use

1. Navigate to the `win/` folder.
2. Review the scripts and `README.md` inside.
3. Run any `.bat` script as **Administrator** to apply or remove policies.
4. You can use the master scripts (`apply_all_security.bat` or `apply_others_security.bat`) to apply groups of settings automatically.

> **Caution:** Always ensure you have a backup of your BitLocker recovery key and a system restore point prepared before applying comprehensive hardening policies. Reversing security rules can be done using the provided `disable` scripts, but caution is recommended in production environments.
