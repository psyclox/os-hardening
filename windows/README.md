# Windows Security Hardening Scripts

This folder contains scripts to harden your Windows operating system's security for **organisation/office environments** where employees should not be able to modify security settings. Available in both **CMD (Batch)** and **PowerShell** formats. All scripts **auto-exit** after completion — no manual key press required.

> **Version 2.1** — Added four new user-friendly entry-point scripts (`turn on security`, `turn off security`, `ironclad security`, `disable security`) and auto-exit on all scripts. See [What's New in v2.1](#whats-new-in-v21) below.

> 🆘 **Locked out or can't run scripts?** → See **[MANUAL_RECOVERY.md](MANUAL_RECOVERY.md)** — complete guide with pure copy-paste commands, lock screen bypass, Safe Mode steps, and a USB emergency recovery script.

---

## Directory Structure

```
windows/
├── cmd/                                  # Batch (.bat) scripts
│   ├── enable/                           # Enable core security features
│   ├── disable/                          # Disable core security features
│   ├── others/                           # Supplementary security scripts
│   │   ├── enable/                       # Enable supplementary features
│   │   ├── disable/                      # Disable supplementary features
│   │   ├── usb_protect/                  # USB insertion lock monitor
│   │   ├── apply_others_security.bat
│   │   └── remove_others_security.bat
│   ├── apply_all_security.bat            # Master enable script
│   ├── remove_all_security.bat           # Master disable script
│   ├── turn on security.bat              # ★ v2.1: Friendly alias — enables all core security
│   ├── turn off security.bat             # ★ v2.1: Friendly alias — disables all core security
│   ├── ironclad security.bat             # ★ v2.1: Maximum lockdown (core + others + USB monitor)
│   ├── disable security.bat              # ★ v2.1: Wipe ALL security layers (requires DISABLE)
│   ├── check_security_status.bat         # Verify all settings
│   ├── admin_emergency_unlock.bat        # Admin bypass (password protected)
│   ├── admin_relock.bat                  # Instant re-hardening after admin work
│   └── emergency_nuke.bat               # USB recovery — removes all hardening without any script deps
└── powershell/                           # PowerShell (.ps1) scripts
    ├── enable/
    ├── disable/
    ├── others/
    ├── apply_all_security.ps1
    ├── remove_all_security.ps1
    ├── check_security_status.ps1         # Verify all settings
    ├── admin_emergency_unlock.ps1        # Admin bypass (password protected)
    └── admin_relock.ps1                  # Instant re-hardening
MANUAL_RECOVERY.md                       # Complete manual undo guide (no scripts needed)
```

---

## ⚠️ Important Notes and Warnings

1. **Run as Administrator**: ALL scripts must be run with elevated privileges.
2. **Reboot after applying**: Some changes (LSA RunAsPPL, Tamper Protection) require a system restart.
3. **Disable scripts require CONFIRM**: You must type the word `CONFIRM` (not just Y) to run any disable script.
4. **Verify after applying**: Always run `check_security_status` after `apply_all_security` to confirm all settings took effect.
5. **BitLocker**: Keep your BitLocker recovery key safe before making major changes.
6. **Windows Home limitation**: Group Policy Firewall lock and some Tamper Protection features may not fully work on Windows Home. Use Windows Pro or Enterprise for full enforcement.
7. **Keep MANUAL_RECOVERY.md printed**: Store a printed copy of [MANUAL_RECOVERY.md](MANUAL_RECOVERY.md) and `emergency_nuke.bat` on a USB stick as a physical recovery key.

---

## How the Scripts Work — Logical Chain

Understanding this prevents panic if something breaks:

```
.ps1 scripts ──→ blocked by RemoteSigned policy (set by enable_malware_protection)
.bat scripts ──→ NEVER blocked (cmd.exe has no execution policy)
                  └─→ use "powershell -ExecutionPolicy Bypass -Command ..." inline
                       └─→ always bypasses system policy for that specific call

Tamper Protection ──→ must be disabled BEFORE any Defender registry changes work
                       └─→ admin_emergency_unlock disables it temporarily
                       └─→ OR: Windows Security UI → toggle off manually
                       └─→ OR: Safe Mode (TP is partially relaxed)

Lock screen ──→ Power icon → hold SHIFT → Restart = Safe Mode (no password needed)
```

**The rule:** If `.ps1` scripts fail → use `.bat` versions. If `.bat` fails → use `emergency_nuke.bat` or the manual commands from [MANUAL_RECOVERY.md](MANUAL_RECOVERY.md).

---

## What's New in v2

| Issue Fixed | v1 Behavior | v2 Fix |
|-------------|-------------|--------|
| **Defender UI bypass** | Real-time Protection toggle accessible in Windows Security | Tamper Protection enabled + Group Policy Firewall lock applied — toggle is now greyed out |
| **Firewall UI bypass** | Firewall toggle still clickable by employees | GP registry paths for all 3 profiles now grey out the toggle |
| **Username display** | `dontdisplaylastusername` inconsistently set | Now consistently set to `0` (show username) — employees can see their own login name on the lock screen (by design) |
| **Confirmation bug** | `!confirm!` never evaluated (delayed expansion missing) | All confirm prompts now require typing `CONFIRM` |
| **Office HKCU-only** | Employees could override macro settings in their own profile | Added HKLM Group Policy paths — user cannot override |
| **5 ASR rules** | Only basic ASR coverage | Extended to 10 rules covering email, USB, API, JS/VBScript attacks |
| **No admin bypass** | Creator locked out of their own scripts | New `admin_emergency_unlock` with password-protected SHA-256 auth |
| **USB monitor killable** | Ran as foreground PS process — any user could close it | Now registered as SYSTEM Scheduled Task — survives reboots, unkillable |
| **No audit log** | No record of when scripts ran | Every script logs to `C:\ProgramData\OrgSecurity\security_log.txt` |
| **No status check** | No way to verify what's actually active | New `check_security_status` shows ✅/❌ for every setting |

## What's New in v2.1

| Addition | Description |
|----------|-------------|
| **`turn on security.bat`** | Friendly one-click alias for `apply_all_security` — enables all 5 core security modules |
| **`turn off security.bat`** | Friendly one-click alias for `remove_all_security` — disables all core security (CONFIRM required) |
| **`ironclad security.bat`** | Maximum lockdown in 3 phases: core security → supplementary (privacy, update, lockscreen, autoplay) → USB monitor |
| **`disable security.bat`** | Full security wipe in 3 phases: removes core + others + stops USB monitor task (DISABLE required) |
| **Auto-exit** | All `.bat` and `.ps1` scripts now exit automatically — no `pause` or `Read-Host` prompt at the end |

---

## CMD vs PowerShell

Both `cmd/` and `powershell/` directories contain **identical functionality**. Choose based on your preference:

| Feature | CMD (Batch) | PowerShell |
|---------|-------------|------------|
| File extension | `.bat` | `.ps1` |
| Run method | Right-click → Run as Administrator | Run from elevated PowerShell terminal |
| Compatibility | All Windows versions | Windows 7+ with PowerShell 5.1+ |
| Admin unlock passphrase | SHA-256 via certutil | SHA-256 via `[System.Security.Cryptography.SHA256]` |

---

## Core Script Reference Table

### Entry-Point Scripts (v2.1)

| Script Name | What It Does | Risk Level |
|-------------|-------------|------------|
| `turn on security` | Enables all 5 core security modules | Low |
| `turn off security` | Disables all 5 core modules (requires `CONFIRM`) | High |
| `ironclad security` | Full 3-phase lockdown: core + others + USB monitor | Low |
| `disable security` | Full 3-phase security wipe: core + others + USB monitor (requires `DISABLE`) | Critical |

### Core Scripts

| Script Name | What It Does | Risk Level |
|-------------|-------------|------------|
| `enable_login_security` | CAD required, username **shown** on lockscreen (by design) | Low |
| `disable_login_security` | No CAD, username shown | Low |
| `enable_network_security` | Firewall (GP locked), SMBv1 off, ports blocked | Low |
| `disable_network_security` | Restores default network settings, removes GP locks | Medium |
| `enable_credential_security` | WDigest off, SEHOP on, LSA RunAsPPL | Low |
| `disable_credential_security` | WDigest on (passwords in memory), PPL off | High |
| `enable_malware_protection` | Defender + Tamper Protection + 10 ASR rules + Firewall GP lock | Low |
| `disable_malware_protection` | Disables all malware protection (requires CONFIRM) | Critical |
| `enable_office_security` | Macros and ActiveX disabled (HKLM locked, multi-version) | Low |
| `disable_office_security` | Macros and ActiveX enabled (requires CONFIRM) | High |
| `apply_all_security` | Runs all enable scripts | Low |
| `remove_all_security` | Runs all disable scripts (requires CONFIRM) | High |
| `check_security_status` | ★ Shows ✅/❌ status for every setting | None |
| `admin_emergency_unlock` | ★ Password-protected admin bypass + logs every use | Admin only |
| `admin_relock` | ★ Instantly re-applies all hardening | Low |

---

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

---

## USB Protection

The `others/usb_protect/` folder includes a monitor that **automatically locks the workstation when a USB drive is inserted**, requiring the system password to unlock.

**v2 Improvement:** The monitor is now registered as a **SYSTEM Scheduled Task** — it auto-starts on boot, survives reboots, and **cannot be killed by standard users** via Task Manager.

**CMD**: Run `start_usb_monitor.bat` as Administrator.  
**PowerShell**: Run `start_usb_monitor.ps1` from an elevated terminal.

To remove: `schtasks /delete /tn "OrgSecurity_USBLockMonitor" /f`

---

## ★ Admin Emergency Unlock (For the Creator/IT Admin)

After applying hardening, the creator may need to run maintenance scripts. The `admin_emergency_unlock` script provides a **safe, password-protected bypass** without permanently disabling security.

### How It Works

1. Run `admin_emergency_unlock.bat` (or `.ps1`) as Administrator
2. Enter your secret passphrase when prompted (input is hidden/masked in PS)
3. If correct:
   - Tamper Protection is **temporarily** disabled
   - Execution Policy set to `Bypass` **for the current session only** (not written to registry)
   - An elevated shell opens for admin work
   - Every unlock is logged with timestamp + username
4. When done, run `admin_relock.bat` (or `admin_relock.ps1`) to instantly re-apply all hardening

### ⚠️ CRITICAL — Change the Default Passphrase Before Deployment

The scripts ship with a **placeholder hash** for the default passphrase `OrgAdmin2024!Unlock`.  
**You MUST change this before deploying to any machine.**

**How to generate your own hash:**

```powershell
# PowerShell — run this to get the SHA-256 hash of your passphrase
$bytes = [System.Text.Encoding]::UTF8.GetBytes("YourNewPassphrase")
$sha256 = [System.Security.Cryptography.SHA256]::Create()
[BitConverter]::ToString($sha256.ComputeHash($bytes)).Replace("-","")
```

```batch
:: CMD alternative — use certutil
echo|set /p="YourNewPassphrase" > %TEMP%\pp.txt
certutil -hashfile %TEMP%\pp.txt SHA256
del %TEMP%\pp.txt
```

Then open `admin_emergency_unlock.bat` (and `.ps1`) and replace the `ADMIN_HASH` / `$AdminHash` value.

### Audit Logs

- `C:\ProgramData\OrgSecurity\security_log.txt` — all script activity
- `C:\ProgramData\OrgSecurity\unlock_log.txt` — dedicated unlock/relock audit trail
- `C:\ProgramData\OrgSecurity\usb_events.txt` — USB insertion events

---

## ★ Security Status Check

Run `check_security_status.bat` or `check_security_status.ps1` at any time to see the current state of all hardening settings:

```
[MALWARE PROTECTION]
  Real-time Protection GP:      [OK] LOCKED ON
  Realtime Monitoring GP:       [OK] LOCKED ON
  Tamper Protection:            [OK] ENABLED (5)
  Cloud Protection GP:          [OK] ENABLED
  PS Script Block Logging:      [OK] ENABLED
  ASR Rules active:             [OK] 10 rules active

[NETWORK / FIREWALL]
  Firewall GP Lock (Domain):    [OK] LOCKED ON
  Firewall GP Lock (Private):   [OK] LOCKED ON
  Firewall GP Lock (Public):    [OK] LOCKED ON
  SMBv1:                        [OK] DISABLED
  LLMNR:                        [OK] DISABLED
  ...
```

---

## Known Limitations

| Limitation | Impact | Mitigation |
|-----------|--------|------------|
| Tamper Protection requires Windows Security Center service running | If SHSVC is stopped, TP bypassed | Lock SecurityHealthService startup |
| Group Policy Firewall lock works best on Win10/11 Pro/Enterprise | Home edition may still show toggle | Use Pro/Enterprise for org machines |
| Registry changes can be reverted from Safe Mode | Attacker with physical access | BitLocker + BIOS password |
| USB monitor (Scheduled Task) can be removed by local admin | Local admin = already compromised | Remove local admin rights from employees |
| Office macro GP covers 15.0 and 16.0 only | Older Office may not be covered | Uninstall old Office versions |

---

## 🛑 Emergency Recovery — When Disable Scripts Don't Work

If hardening policies have locked you out or prevent running the disable scripts (e.g., PowerShell execution policy blocks `.ps1` files, firewall blocks everything), use the manual recovery methods below.

### Before You Start: Prevention Checklist

Always do these **before** applying hardening:

1. **Create a System Restore Point**: `Win + S` → type `Create a restore point` → click `Create...`
2. **Export your current registry**: Open `regedit` → `File` → `Export` → save as `backup.reg`
3. **Note your BitLocker recovery key**: `Win + S` → `Manage BitLocker` → `Back up your recovery key`
4. **Keep a bootable Windows USB** ready (create via [Media Creation Tool](https://www.microsoft.com/software-download/windows10))

---

### Recovery Method 1: Admin Emergency Unlock (First Try This)

If you just need to run a script and execution policy is blocking you:

```batch
:: Run as Administrator
admin_emergency_unlock.bat
```

This is the fastest and safest option if the system is still bootable.

---

### Recovery Method 2: Safe Mode

If Windows boots but scripts won't run or policies block execution:

1. Hold `Shift` and click `Restart` from the Start menu
2. Go to **Troubleshoot → Advanced Options → Startup Settings → Restart**
3. Press `4` or `F4` for **Safe Mode** (or `5`/`F5` for Safe Mode with Networking)
4. In Safe Mode, most Group Policy and registry restrictions are relaxed:

```batch
:: Fix PowerShell execution policy
powershell -Command "Set-ExecutionPolicy Unrestricted -Force"

:: Remove Defender GP lock completely
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f

:: Remove Firewall GP locks
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /f

:: Revert firewall to defaults
netsh advfirewall reset

:: Disable Ctrl+Alt+Del requirement (if stuck at login)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f

:: Re-enable WDigest (if login is affected)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f
```

5. Reboot normally

---

### Recovery Method 3: Windows Recovery Environment (WinRE)

If Windows won't boot at all or Safe Mode fails:

1. Boot from a **Windows installation USB/DVD**
2. Click **Repair your computer** → **Troubleshoot** → **Command Prompt**
3. The registry hives are offline. Load them manually:

```batch
:: Load the SYSTEM hive from the installed Windows
reg load HKLM\OFFLINE_SYSTEM C:\Windows\System32\config\SYSTEM

:: Fix registry keys
reg add "HKLM\OFFLINE_SYSTEM\ControlSet001\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 1 /f
reg add "HKLM\OFFLINE_SYSTEM\ControlSet001\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f

:: Unload when done
reg unload HKLM\OFFLINE_SYSTEM
```

4. Type `exit` and reboot

---

### Recovery Method 4: System Restore

If you created a restore point before hardening:

1. Boot into **Safe Mode** or **WinRE** (see above)
2. Go to **Troubleshoot → Advanced Options → System Restore**
3. Select the restore point created before applying hardening

---

### Recovery Method 5: Manual Registry Nuke (Last Resort)

```batch
:: Run these from Safe Mode or WinRE Command Prompt
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /f
netsh advfirewall reset
powershell -Command "Set-ExecutionPolicy Unrestricted -Force"
```

---

### Common Lockout Scenarios & Quick Fixes

| Problem | Cause | Quick Fix |
|---------|-------|-----------|
| Can't run `.ps1` scripts | Execution policy `RemoteSigned` | Run `admin_emergency_unlock.ps1` → or Safe Mode → `Set-ExecutionPolicy Bypass -Force` |
| Real-time Protection greyed on (can't disable) | Tamper Protection enabled (✅ this is correct!) | Use `admin_emergency_unlock` → then `disable_malware_protection.ps1` |
| Firewall toggle greyed out | Group Policy Firewall lock (✅ correct!) | Use `admin_emergency_unlock` → or Safe Mode → delete GP registry keys |
| Can't access network shares | Port 445 blocked / SMBv1 off | Safe Mode → `netsh advfirewall reset` |
| RDP not working | Port 3389 blocked | Safe Mode → `netsh advfirewall firewall delete rule name="Block_RDP_3389_IN"` |
| Stuck at Ctrl+Alt+Del | `enable_login_security` enforced CAD | Safe Mode → `reg add "HKLM\...\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f` |
| Windows Defender blocking everything | ASR rules too aggressive | Safe Mode → `reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f` |
| USB monitor keeps locking PC | Scheduled Task running | Admin CMD → `schtasks /delete /tn "OrgSecurity_USBLockMonitor" /f` |
| Office macros won't run | Macro policy locked | Run `disable_office_security` or delete HKLM Office GP keys |
| Username shows on lockscreen after v1 | Old `dontdisplaylastusername=0` | Run `enable_login_security` again (v2 fixes it to `1`) |

---

> **⚠️ KNOWN v1 → v2 UPGRADE NOTE:** If you applied v1 scripts previously, you **must run `apply_all_security` again** with the v2 scripts to apply the new Tamper Protection + Firewall GP locks. A reboot is required after.

> **⚠️ v2 → v2.1 UPGRADE NOTE:** No re-application needed. The 4 new entry-point scripts (`turn on security`, `turn off security`, `ironclad security`, `disable security`) are additive and do not change existing behaviour. The auto-exit change (removal of `pause`/`Read-Host`) is cosmetic only.
