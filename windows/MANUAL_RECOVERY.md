# 🛑 Manual Recovery & Situation Guide
## OS Hardening Toolkit — Windows

This document answers one critical question:  
**"If I can't run any script, how do I undo the hardening manually?"**

Read this **before** deploying hardening to any machine.

---

## Quick Situation Finder

| Your Situation | Jump To |
|----------------|---------|
| Machine is running, I'm logged in, PS scripts won't run | [Situation A](#situation-a--im-logged-in-but-ps-scripts-are-blocked) |
| Machine is at the lock screen, screen is locked | [Situation B](#situation-b--screen-is-locked--i-need-to-get-in) |
| I can log in but something is broken after hardening | [Situation C](#situation-c--logged-in-but-something-is-broken) |
| Machine won't boot / Safe Mode needed | [Situation D](#situation-d--machine-wont-boot-or-safe-mode-needed) |
| I need to undo everything with zero tools (pure manual) | [Situation E](#situation-e--pure-manual-undo--no-scripts-at-all) |
| I want a USB stick I can plug in for emergency recovery | [Situation F](#situation-f--usb-emergency-recovery-stick) |

---

## Why This Problem Exists (Logical Explanation)

After running `enable_malware_protection`, the script sets:

```
PowerShell Execution Policy = RemoteSigned
Tamper Protection           = Enabled
```

This creates two chains:

```
[Creator wants to run disable scripts]
       ↓
[.ps1 scripts → blocked by RemoteSigned policy]
       ↓
[.bat scripts → call "powershell -ExecutionPolicy Bypass -Command ..."  ← ALWAYS WORKS]
       ↓
[But Tamper Protection blocks Defender-related changes]
       ↓
[Need: Tamper Protection OFF first, then everything else works]
```

**Key insight:**  
- `.bat` scripts are **never blocked** by PowerShell execution policy  
- `cmd.exe` has no execution policy — it runs `.bat` files unconditionally  
- The only thing that can block `.bat` files is if `cmd.exe` itself is blocked (very rare, requires separate GPO)

---

## Situation A — I'm Logged In But PS Scripts Are Blocked

### What Happened
`enable_malware_protection` set `RemoteSigned` policy. Now `.ps1` files show:
> *"cannot be loaded because running scripts is disabled on this system"*

### Solution 1: Use the `.bat` version instead (Easiest)

The CMD versions of all scripts use `powershell -ExecutionPolicy Bypass -Command "..."` inline.  
They **always work regardless of system execution policy**.

```batch
:: Navigate to the cmd/ folder and run the bat version:
cd "C:\path\to\os hardening\windows\cmd"
disable_malware_protection.bat   ← works even if PS is locked down
remove_all_security.bat
```

### Solution 2: Use admin_emergency_unlock.bat (Password Protected)

```batch
:: Run as Administrator:
admin_emergency_unlock.bat
:: Enter your passphrase → unlocked shell opens → run your scripts → relock
```

### Solution 3: Call the .ps1 with an inline bypass (No files needed)

Open CMD as Administrator, then:

```cmd
powershell -ExecutionPolicy Bypass -File "C:\path\to\disable_malware_protection.ps1"
```

The `-ExecutionPolicy Bypass` flag **overrides** the system policy for that specific call.

### Solution 4: Bypass just for the current session

Open CMD as Administrator:

```cmd
powershell -ExecutionPolicy Bypass
```

Now you're in a PowerShell session with Bypass policy. Run any `.ps1` from here:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\disable_malware_protection.ps1
```

---

## Situation B — Screen Is Locked / I Need to Get In

### The Lock Screen Power Menu Trick (No Password Needed to Restart)

Even from the **Windows lock screen**, you can reach Safe Mode without knowing the password:

```
1. On the lock screen → click the Power icon (⏻) at the bottom right corner
2. Hold SHIFT on the keyboard
3. While holding SHIFT → click "Restart"
4. Windows restarts into Advanced Startup (WinRE) automatically
5. You DON'T need the login password for this step
```

You are now in the Windows Recovery Environment. Continue to **Situation D** for what to do next.

> **If the machine is fully off (not just locked):**  
> Turn it on → immediately tap F8 or F11 repeatedly → Advanced Startup  
> OR: Turn on → hold power button to force shutdown 3 times → Windows auto-boots into WinRE

### If You Know the Password But the Session Is Locked

Just unlock normally. Then:
- Open **CMD as Administrator** (`Win+X → Command Prompt (Admin)`)
- Run the `.bat` disable scripts

### If the Login Screen Requires Ctrl+Alt+Delete (CAD enforced by our script)

This is expected behaviour from `enable_login_security`. Just press **Ctrl+Alt+Delete** first, then enter your password. The CAD requirement does NOT lock you out — it just adds one extra keypress.

> **If you're stuck on the CAD screen with no keyboard (e.g., remote machine via screen share):**  
> Use the On-Screen Keyboard (`Win+R → osk`) after pressing Ctrl+Alt+Delete, or send Ctrl+Alt+Delete via your remote tool's special key function.

---

## Situation C — Logged In But Something Is Broken

### Problem: Can't open PowerShell at all
**Cause:** Very rare — would require a separate GPO blocking `powershell.exe`  
**Fix:** Use CMD → run `cmd.exe` as Admin → use the `.bat` scripts

### Problem: Defender is blocking a legitimate program (ASR rules too aggressive)
**Fix Option 1 — Quick (no reboot):**
```batch
:: Run as Administrator from the cmd/ disable folder:
disable_malware_protection.bat
:: Then re-enable with:
enable_malware_protection.bat
```

**Fix Option 2 — Surgical (remove one specific ASR rule):**
```cmd
powershell -ExecutionPolicy Bypass -Command "Remove-MpPreference -AttackSurfaceReductionRules_Ids 'RULE-GUID-HERE' -ErrorAction SilentlyContinue"
```

Replace `RULE-GUID-HERE` with the specific rule ID shown in the Defender event log.

### Problem: Can't access a network share (port 445 blocked)
```cmd
:: Run as Administrator:
netsh advfirewall firewall delete rule name="Block_SMB_445_IN"
```

### Problem: RDP stopped working (port 3389 blocked)
```cmd
netsh advfirewall firewall delete rule name="Block_RDP_3389_IN"
```

### Problem: Macros don't work in Office (for a specific trusted file)
```cmd
:: Run as Administrator - removes the HKLM lock for Word:
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\word\Security" /v VBAWarnings /f
```

Or use the full disable script:
```batch
disable_office_security.bat
```

### Problem: USB monitor keeps locking the machine
```cmd
:: Run as Administrator:
schtasks /delete /tn "OrgSecurity_USBLockMonitor" /f
```

---

## Situation D — Machine Won't Boot or Safe Mode Needed

### Entering Safe Mode (3 Methods)

**Method 1 — From running Windows (you're logged in):**
```cmd
:: Run as Administrator:
bcdedit /set {default} safeboot minimal
shutdown /r /t 0
:: After work in Safe Mode, to return to normal:
bcdedit /deletevalue {default} safeboot
shutdown /r /t 0
```

**Method 2 — From the lock screen (no login needed):**
```
Lock screen → Power icon → Hold SHIFT → Restart
→ Troubleshoot → Advanced Options → Startup Settings → Restart
→ Press 4 (Safe Mode) or 5 (Safe Mode with Networking)
```

**Method 3 — From a powered-off machine:**
```
Power on → rapidly tap F8 (or Fn+F8) before Windows logo appears
→ Advanced Boot Options → Safe Mode
```
> Note: F8 only works on older systems. Modern UEFI systems may require Method 1 or Method 2.

### What Safe Mode Changes

In Safe Mode:
- Most Group Policy restrictions are **relaxed**
- PowerShell execution policy can be changed freely
- The SYSTEM Scheduled Task (USB monitor) does **not** start
- Defender may operate in a limited mode
- Registry edits via `regedit.exe` work freely

### In Safe Mode — Run the Disable Scripts

1. Navigate to the USB stick or the scripts folder
2. Right-click `remove_all_security.bat` → **Run as Administrator**
3. Type `CONFIRM` when prompted
4. Reboot normally

### In Safe Mode — If Scripts Still Don't Work

Use the manual commands from **Situation E** below directly in a CMD window.

---

## Situation E — Pure Manual Undo (No Scripts at All)

This is for extreme cases: you have a CMD window (or Safe Mode CMD), no script files available, and you need to undo the hardening completely by typing commands.

Copy-paste these commands into an **Administrator CMD** or **Safe Mode CMD**.  
Each block is independent — run only what you need.

---

### Block 1: Unlock PowerShell Execution Policy

```cmd
powershell -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"
```

---

### Block 2: Disable Tamper Protection (must do BEFORE touching Defender)

```cmd
powershell -ExecutionPolicy Bypass -Command "Set-MpPreference -TamperProtection 4"
```

> If this fails with an access error: Go to **Windows Security** → **Virus & threat protection** → **Virus & threat protection settings** → **Tamper Protection** → Toggle it **OFF** manually. Then re-run the command above.

---

### Block 3: Remove ALL Defender Group Policy Locks

```cmd
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f
```

This single command removes the entire Defender policy subtree, restoring all Defender settings to defaults. The UI toggles become active again immediately.

---

### Block 4: Remove Firewall Group Policy Locks (restores toggle in UI)

```cmd
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /f
```

After this, the Firewall toggle in Windows Security is clickable again.

---

### Block 5: Reset Windows Firewall to Default

```cmd
netsh advfirewall reset
```

---

### Block 6: Remove Port Block Rules

```cmd
netsh advfirewall firewall delete rule name="Block_SMB_445_IN"
netsh advfirewall firewall delete rule name="Block_RDP_3389_IN"
```

---

### Block 7: Restore Login Screen (show username, remove CAD)

```cmd
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DontDisplayLastUserName /t REG_DWORD /d 0 /f
```

---

### Block 8: Restore WDigest / Disable LSA RunAsPPL (requires reboot)

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 0 /f
```

> RunAsPPL change requires a **reboot** to take effect.

---

### Block 9: Re-enable SMBv1 (if needed for legacy access)

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 1 /f
```

---

### Block 10: Remove Office Macro Locks

```cmd
:: Office 2016/2019/365 (16.0)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\excel\Security" /v VBAWarnings /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\word\Security" /v VBAWarnings /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\powerpoint\Security" /v VBAWarnings /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\outlook\Security" /v VBAWarnings /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\access\Security" /v VBAWarnings /f

:: Office 2013 (15.0)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\15.0\excel\Security" /v VBAWarnings /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\15.0\word\Security" /v VBAWarnings /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\15.0\powerpoint\Security" /v VBAWarnings /f
```

---

### Block 11: Stop and Remove USB Monitor Task

```cmd
schtasks /end /tn "OrgSecurity_USBLockMonitor"
schtasks /delete /tn "OrgSecurity_USBLockMonitor" /f
```

---

### Block 12: Remove ASR Rules (PowerShell inline — always works)

```cmd
powershell -ExecutionPolicy Bypass -Command "Remove-MpPreference -AttackSurfaceReductionRules_Ids 'D4F940AB-401B-4EFC-AADC-AD5F3C50688A','9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2','BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550','75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84','5BEB7EFE-FD9A-4556-801D-275E5FFC04CC','01443614-CD74-433A-B99E-2ECDC07BFC25','3B576869-A4EC-4529-8536-B80A7769E899','92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B','D3E037E1-3EB8-44C8-A917-57927947596D','26190899-1602-49E8-8B27-EB1D0A1CE869' -ErrorAction SilentlyContinue"
```

---

### Block 13: Remove PS Script Block Logging

```cmd
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /f
```

---

### Block 14: NUCLEAR — Delete Everything at Once

If you want to wipe all hardening policies in one shot:

```cmd
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office" /f
netsh advfirewall reset
powershell -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"
schtasks /delete /tn "OrgSecurity_USBLockMonitor" /f
```

> Reboot after this for all changes to take full effect.

---

## Situation F — USB Emergency Recovery Stick

Create a bootable USB with a plain `.bat` file that can be run from any logged-in admin CMD.  
Keep this USB locked in a drawer — it's your physical master key.

**Contents of the USB:**
- A copy of the entire `windows/cmd/` folder
- The `emergency_nuke.bat` file below

**emergency_nuke.bat** — Save this on the USB, run from Admin CMD when needed:

```batch
@echo off
:: USB EMERGENCY RECOVERY — Removes all hardening silently
:: Run from an Administrator CMD window
:: Does NOT need PowerShell execution policy to work

net session >nul 2>&1
if %errorLevel% neq 0 ( echo Run as Administrator & pause & exit /b 1 )

echo Removing all hardening policies...

powershell -ExecutionPolicy Bypass -Command "try { Set-MpPreference -TamperProtection 4 } catch {}" 2>nul

reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 0 /f >nul 2>&1
netsh advfirewall reset >nul
schtasks /delete /tn "OrgSecurity_USBLockMonitor" /f >nul 2>&1
netsh advfirewall firewall delete rule name="Block_SMB_445_IN" >nul 2>&1
netsh advfirewall firewall delete rule name="Block_RDP_3389_IN" >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force" >nul 2>&1

echo.
echo [OK] All hardening removed. Reboot to finalize all changes.
pause
```

---

## The Key Logical Rules to Remember

| Rule | Explanation |
|------|-------------|
| **BAT files are never blocked by PS policy** | `cmd.exe` has no execution policy. Always use `.bat` versions first. |
| **`-ExecutionPolicy Bypass` in-line always works** | `powershell -ExecutionPolicy Bypass -Command "..."` overrides system policy for that call |
| **Tamper Protection must be disabled FIRST** | Before any Defender change via registry or script, TP must be off or changes are silently ignored |
| **Lock screen → Shift+Restart = Safe Mode access** | You don't need the password to reach Safe Mode from the lock screen |
| **Safe Mode relaxes Group Policy** | Most policy restrictions are inactive in Safe Mode — best environment for recovery |
| **`reg delete` on a key removes everything under it** | `reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f` wipes ALL Defender policy at once |
| **`netsh advfirewall reset` always works** | Resets firewall to Windows defaults regardless of policy. No PS needed. |
| **Registry edits don't need execution policy** | `regedit.exe` and `reg.exe` are not PS — they're not affected by PS execution policy at all |

---

## Registry Quick Reference — All Hardening Keys

Use this table to manually check or change individual settings in `regedit.exe`.

### Defender / Malware

| Registry Path | Value Name | Secure | Default |
|---------------|-----------|--------|---------|
| `HKLM\SOFTWARE\Policies\Microsoft\Windows Defender` | `DisableAntiSpyware` | `0` | *(key absent)* |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection` | `DisableRealtimeMonitoring` | `0` | *(key absent)* |
| `HKLM\SOFTWARE\Microsoft\Windows Defender` | `TamperProtection` | `5` | `5` (usually) |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet` | `SpyNetReporting` | `2` | *(key absent)* |

### Firewall

| Registry Path | Value Name | Secure | Default |
|---------------|-----------|--------|---------|
| `HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile` | `EnableFirewall` | `1` | *(key absent)* |
| `HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile` | `EnableFirewall` | `1` | *(key absent)* |
| `HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile` | `EnableFirewall` | `1` | *(key absent)* |

### Login

| Registry Path | Value Name | Secure | Default |
|---------------|-----------|--------|---------|
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` | `DisableCAD` | `0` | `1` |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` | `dontdisplaylastusername` | `1` | `0` |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\System` | `DontDisplayLastUserName` | `1` | *(key absent)* |

### Credentials

| Registry Path | Value Name | Secure | Default |
|---------------|-----------|--------|---------|
| `HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest` | `UseLogonCredential` | `0` | `0` |
| `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel` | `DisableExceptionChainValidation` | `0` | `0` |
| `HKLM\SYSTEM\CurrentControlSet\Control\Lsa` | `RunAsPPL` | `1` | `0` |

### Network

| Registry Path | Value Name | Secure | Default |
|---------------|-----------|--------|---------|
| `HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters` | `SMB1` | `0` | `1` |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient` | `EnableMulticast` | `0` | *(key absent)* |

### Office

| Registry Path | Value Name | Secure | Default |
|---------------|-----------|--------|---------|
| `HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\word\Security` | `VBAWarnings` | `4` | *(key absent)* |
| `HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\excel\Security` | `VBAWarnings` | `4` | *(key absent)* |

> **To unlock macros via regedit:** Navigate to each path → right-click `VBAWarnings` → Delete. The HKCU values remain but employees control them.

---

## Recommended: Print This Page

Keep a printed copy of [Situation E (Pure Manual Commands)](#situation-e--pure-manual-undo--no-scripts-at-all) and [Situation B (Lock Screen)](#situation-b--screen-is-locked--i-need-to-get-in) in a secure location (locked drawer or safe) near each hardened machine.  

If all else fails and you can't even reach a CMD window, boot from a **Windows PE USB** or **WinRE** and use the offline registry loading method in the main `windows/README.md`.
