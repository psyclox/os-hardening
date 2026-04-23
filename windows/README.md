# Windows Security Hardening Scripts

This folder contains scripts to harden your Windows operating system's security, available in both **CMD (Batch)** and **PowerShell** formats.

## Directory Structure

```
win/
├── cmd/                              # Batch (.bat) scripts
│   ├── enable/                       # Enable core security features
│   ├── disable/                      # Disable core security features
│   ├── others/                       # Supplementary security scripts
│   │   ├── enable/                   # Enable supplementary features
│   │   ├── disable/                  # Disable supplementary features
│   │   ├── usb_protect/             # USB insertion lock monitor
│   │   ├── apply_others_security.bat
│   │   └── remove_others_security.bat
│   ├── apply_all_security.bat        # Master enable script
│   └── remove_all_security.bat       # Master disable script
└── powershell/                       # PowerShell (.ps1) scripts
    ├── enable/                       # Enable core security features
    ├── disable/                      # Disable core security features
    ├── others/                       # Supplementary security scripts
    │   ├── enable/
    │   ├── disable/
    │   ├── usb_protect/
    │   ├── apply_others_security.ps1
    │   └── remove_others_security.ps1
    ├── apply_all_security.ps1        # Master enable script
    └── remove_all_security.ps1       # Master disable script
```

## CMD vs PowerShell

Both `cmd/` and `powershell/` directories contain **identical functionality**. Choose based on your preference:

| Feature | CMD (Batch) | PowerShell |
|---------|-------------|------------|
| File extension | `.bat` | `.ps1` |
| Run method | Right-click → Run as Administrator | Run from elevated PowerShell terminal |
| Compatibility | All Windows versions | Windows 7+ with PowerShell 5.1+ |
| Style | Uses `reg.exe` and `netsh` | Uses native cmdlets (`Set-ItemProperty`, `Set-NetFirewallProfile`) |

## ⚠️ Important Notes and Warnings

1. **Run as Administrator**: ALL scripts must be run with elevated privileges.
2. **Reboot after applying**: Some changes require a system restart to take effect.
3. **Disable scripts**: These are NOT recommended for production environments. Disabling malware protection will put your system at critical risk!
4. **Testing**: Test on a non-critical device first before deploying widely.
5. **BitLocker**: Keep your BitLocker recovery key safe before making major changes.

## Core Script Reference Table

| Script Name | What It Does | Risk Level |
|-------------|-------------|------------|
| `enable_login_security` | CAD required, username shown | Low |
| `disable_login_security` | No CAD, username shown | Low |
| `enable_network_security` | Firewall, SMBv1 off, ports blocked | Low |
| `disable_network_security` | Restores default network settings | Medium |
| `enable_credential_security` | WDigest off, SEHOP on | Low |
| `disable_credential_security` | WDigest on (passwords in memory) | High |
| `enable_malware_protection` | Defender, ASR, PowerShell security | Low |
| `disable_malware_protection` | Disables all malware protection | Critical |
| `enable_office_security` | Macros and ActiveX disabled | Low |
| `disable_office_security` | Macros and ActiveX enabled | High |
| `apply_all_security` | Runs all enable scripts | Low |
| `remove_all_security` | Runs all disable scripts | High |

## Supplementary Scripts (`others/` directory)

| Script Name | What It Does | Risk Level |
|-------------|-------------|------------|
| `enable_privacy_security` | Disables Telemetry, Cortana, Ad ID | Low |
| `disable_privacy_security` | Restores telemetry defaults | Medium |
| `enable_update_security` | Disables P2P Windows Updates | Low |
| `disable_update_security` | Restores P2P updates | Low |
| `enable_lockscreen_security` | Disables camera/notifications on lock screen | Low |
| `disable_lockscreen_security` | Restores lock screen defaults | Low |
| `enable_autoplay_security` | Disables AutoPlay for all drives | Low |
| `disable_autoplay_security` | Restores AutoPlay | Medium |

## USB Protection

The `others/usb_protect/` folder includes a background monitor that automatically locks the workstation when a USB drive is inserted, requiring the system password to unlock.

**CMD**: Run `start_usb_monitor.bat` as Administrator.
**PowerShell**: Run `start_usb_monitor.ps1` from an elevated terminal.

## 🛑 Emergency Recovery — When Disable Scripts Don't Work

If hardening policies have locked you out or prevent running the disable scripts (e.g., PowerShell execution policy blocks `.ps1` files, firewall blocks everything, or the system becomes unresponsive), use the manual recovery methods below.

### Before You Start: Prevention Checklist

Always do these **before** applying hardening:

1. **Create a System Restore Point**: `Win + S` → type `Create a restore point` → click `Create...`
2. **Export your current registry**: Open `regedit` → `File` → `Export` → save as `backup.reg`
3. **Note your BitLocker recovery key**: `Win + S` → `Manage BitLocker` → `Back up your recovery key`
4. **Keep a bootable Windows USB** ready (create via [Media Creation Tool](https://www.microsoft.com/software-download/windows10))

---

### Recovery Method 1: Safe Mode (Most Common Fix)

If Windows boots but scripts won't run or policies block execution:

1. Hold `Shift` and click `Restart` from the Start menu
2. Go to **Troubleshoot → Advanced Options → Startup Settings → Restart**
3. Press `4` or `F4` for **Safe Mode** (or `5`/`F5` for Safe Mode with Networking)
4. In Safe Mode, most Group Policy and registry restrictions are relaxed:

```batch
:: Fix PowerShell execution policy
powershell -Command "Set-ExecutionPolicy Unrestricted -Force"

:: Revert firewall to defaults
netsh advfirewall reset

:: Re-enable SMBv1 (if network access is needed)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 1 /f

:: Re-enable WDigest (if login is affected)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f

:: Disable Ctrl+Alt+Del requirement (if stuck at login)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f

:: Restore Windows Defender defaults
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f
```

5. Reboot normally

---

### Recovery Method 2: Windows Recovery Environment (WinRE)

If Windows won't boot at all or Safe Mode fails:

1. Boot from a **Windows installation USB/DVD**
2. Click **Repair your computer** → **Troubleshoot** → **Command Prompt**
3. The registry hives are offline. Load them manually:

```batch
:: Load the SYSTEM hive from the installed Windows
reg load HKLM\OFFLINE_SYSTEM C:\Windows\System32\config\SYSTEM

:: Fix firewall-related registry keys
reg add "HKLM\OFFLINE_SYSTEM\ControlSet001\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 1 /f

:: Remove credential hardening
reg add "HKLM\OFFLINE_SYSTEM\ControlSet001\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f

:: Unload when done
reg unload HKLM\OFFLINE_SYSTEM
```

4. Type `exit` and reboot

---

### Recovery Method 3: System Restore

If you created a restore point before hardening:

1. Boot into **Safe Mode** or **WinRE** (see above)
2. Go to **Troubleshoot → Advanced Options → System Restore**
3. Select the restore point created before applying hardening
4. This reverts all registry and system policy changes

---

### Recovery Method 4: Manual Registry Fix (Last Resort)

If nothing else works, manually delete all policy keys that hardening scripts created:

```batch
:: Run these from Safe Mode or WinRE Command Prompt

:: Remove ALL custom Group Policy registry entries
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /f

:: Reset firewall
netsh advfirewall reset

:: Reset Defender
powershell -Command "Remove-MpPreference -AttackSurfaceReductionRules_Ids (Get-MpPreference).AttackSurfaceReductionRules_Ids -ErrorAction SilentlyContinue"

:: Reset execution policy
powershell -Command "Set-ExecutionPolicy Unrestricted -Force"
```

---

### Common Lockout Scenarios & Quick Fixes

| Problem | Cause | Quick Fix |
|---------|-------|-----------|
| Can't run `.ps1` scripts | `enable_malware_protection` set execution policy to `RemoteSigned` | Safe Mode → `Set-ExecutionPolicy Unrestricted -Force` |
| Can't access network shares | `enable_network_security` blocked port 445 / disabled SMBv1 | Safe Mode → `netsh advfirewall reset` |
| RDP not working | `enable_network_security` blocked port 3389 | Safe Mode → `netsh advfirewall firewall delete rule name="Block_RDP_3389"` |
| Stuck at Ctrl+Alt+Del screen | `enable_login_security` enforced CAD | Safe Mode → `reg add "HKLM\...\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f` |
| Windows Defender blocking everything | `enable_malware_protection` ASR rules too aggressive | Safe Mode → `reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f` |
| USB monitor keeps locking PC | `usb_protect` running in background | Task Manager → End `powershell.exe` running `usb_lock_monitor.ps1` |
| Office macros won't run (needed for work) | `enable_office_security` disabled VBA | Run `disable_office_security` script or manually set `VBAWarnings` to `1` in registry |
