# macOS Security Hardening Scripts

This folder contains shell scripts to harden your macOS operating system's security.

## Directory Structure

* `enable/`: Contains individual scripts to enable specific security features.
* `disable/`: Contains scripts to disable/revert those features (use with caution).
* `apply_all_security.sh`: Master script to enable all security measures.
* `remove_all_security.sh`: Master script to disable all security measures.

## ⚠️ Important Notes and Warnings

1. **Run as root**: ALL scripts must be run with `sudo`.
2. **Restart**: Some changes (especially FileVault) may require a restart to complete.
3. **FileVault**: Enabling FileVault encrypts your entire disk. **Store the recovery key securely** — losing it may result in permanent data loss.
4. **Gatekeeper**: Disabling Gatekeeper allows unsigned apps to run, which is a significant security risk.
5. **Testing**: Test on a non-critical machine first.

## How to Use

```bash
# Make scripts executable
chmod +x enable/*.sh disable/*.sh apply_all_security.sh remove_all_security.sh

# Apply all hardening
sudo ./apply_all_security.sh

# Or apply individually
sudo ./enable/enable_firewall.sh
sudo ./enable/enable_filevault.sh

# Revert specific hardening
sudo ./disable/disable_firewall.sh
```

## Script Reference Table

| Script | What It Does | Risk Level |
|--------|-------------|------------|
| `enable_firewall.sh` | Enables macOS Application Firewall + stealth mode + logging | Low |
| `disable_firewall.sh` | Disables Application Firewall and stealth mode | High |
| `enable_filevault.sh` | Enables FileVault full-disk encryption | Low |
| `disable_filevault.sh` | Disables FileVault and decrypts disk | Medium |
| `enable_gatekeeper.sh` | Enforces Gatekeeper (App Store + identified developers) | Low |
| `disable_gatekeeper.sh` | Allows apps from any source (unsigned) | Critical |
| `enable_network_security.sh` | Disables Bonjour advertising, captive portal, restricts AirDrop, disables wake-on-LAN | Low |
| `disable_network_security.sh` | Restores default network settings | Medium |
| `enable_privacy_security.sh` | Disables analytics, ads, Siri data sharing, Safari suggestions | Low |
| `disable_privacy_security.sh` | Restores default privacy/analytics settings | Medium |
| `apply_all_security.sh` | Runs all enable scripts | Low |
| `remove_all_security.sh` | Runs all disable scripts | High |

## Requirements

* macOS 10.14 (Mojave) or later
* Administrator access

## 🛑 Emergency Recovery — When Disable Scripts Don't Work

If hardening has caused issues and you can't run the disable scripts (e.g., Gatekeeper blocks script execution, FileVault recovery key lost, or system becomes unresponsive), use the manual recovery methods below.

### Before You Start: Prevention Checklist

Always do these **before** applying hardening:

1. **Back up your Mac** with Time Machine or a full disk clone
2. **Save the FileVault recovery key** in a secure, separate location (printed or in a password manager)
3. **Know your Apple ID credentials** (needed for some recovery scenarios)
4. **Keep a macOS recovery USB** ready (create via `createinstallmedia` or use Internet Recovery)

---

### Recovery Method 1: macOS Recovery Mode (⌘+R)

If macOS boots but hardening prevents normal operation:

1. Restart your Mac
2. Immediately hold **⌘ (Command) + R** until you see the Apple logo
3. In **macOS Utilities**, select **Utilities → Terminal** from the menu bar
4. Fix the issue:

```bash
# If Gatekeeper is blocking everything and you can't open apps
spctl --master-disable

# If firewall is blocking all network traffic
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode off

# Reset network settings that were hardened
defaults delete /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements
defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool true
```

5. Close Terminal and restart from the Apple menu

---

### Recovery Method 2: Single-User Mode (⌘+S) — Intel Macs Only

For Intel-based Macs:

1. Restart and hold **⌘ (Command) + S**
2. You'll get a command-line prompt. Mount the filesystem:

```bash
/sbin/mount -uw /
```

3. Fix the issue using the same commands from Recovery Method 1

4. Reboot:

```bash
reboot
```

> **Note:** On Apple Silicon Macs (M1/M2/M3+), single-user mode is not available. Use Recovery Mode instead.

---

### Recovery Method 3: Reset NVRAM / SMC

If the system is unresponsive or behaving erratically after hardening:

**Reset NVRAM (Intel Macs):**
1. Shut down the Mac
2. Turn it on and immediately hold **⌥ (Option) + ⌘ (Command) + P + R** for 20 seconds

**Reset SMC (Intel Macs with T2 chip):**
1. Shut down, then hold **Control + Option + Shift** for 7 seconds
2. While still holding those keys, press and hold the **Power button** for another 7 seconds
3. Release all keys, wait a few seconds, then turn on

**Apple Silicon Macs:**
Simply shut down and wait 30 seconds before restarting. NVRAM resets automatically.

---

### Recovery Method 4: FileVault Issues

**If you have the recovery key:**

1. Boot into Recovery Mode (⌘+R)
2. Select **Disk Utility**
3. Unlock the encrypted volume using the recovery key
4. Restart normally

**If you've lost the recovery key AND password:**

> ⚠️ **This is unrecoverable.** FileVault uses strong encryption, and without either the user password or the recovery key, the data is permanently inaccessible. Your only option is to erase the disk and reinstall macOS.

1. Boot into Recovery Mode (⌘+R)
2. Open **Disk Utility** → select your drive → **Erase**
3. Reinstall macOS from the Utilities menu

**This is why saving the recovery key is critical.**

---

### Recovery Method 5: Reinstall macOS (Last Resort)

If nothing else works:

1. Boot into **Internet Recovery**: hold **⌥ (Option) + ⌘ + R** at startup
2. This downloads and boots the latest compatible macOS from Apple's servers
3. Use **Disk Utility** to erase the drive if needed
4. Select **Reinstall macOS**
5. Restore your data from Time Machine backup

---

### Common Lockout Scenarios & Quick Fixes

| Problem | Cause | Quick Fix |
|---------|-------|-----------|
| Apps won't open ("unidentified developer") | `enable_gatekeeper` enforced strict app policy | Recovery Terminal → `spctl --master-disable` |
| No Wi-Fi / No AirDrop | `enable_network_security` disabled Bonjour, restricted AirDrop | Terminal → `defaults delete /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements` |
| Can't access Mac after FileVault | Lost FileVault recovery key | Use recovery key at login prompt, or erase & reinstall if key is lost |
| Wake-on-LAN not working | `enable_network_security` disabled `womp` | Terminal → `sudo pmset -a womp 1` |
| Safari search suggestions missing | `enable_privacy_security` disabled them | Terminal → `defaults write com.apple.Safari UniversalSearchEnabled -bool true` |
| Firewall blocking needed connections | `enable_firewall` + stealth mode enabled | Terminal → `sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off` |
| Crash reports not sending to IT/devs | `enable_privacy_security` disabled analytics | Terminal → `defaults write com.apple.CrashReporter DialogType -string "crashreport"` |
