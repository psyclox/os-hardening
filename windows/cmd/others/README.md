# Windows Security Hardening - Others (CMD)

This folder contains supplementary security scripts to harden peripheral areas of your Windows operating system. All scripts **auto-exit** after completion — no manual key press required.

> These scripts are also called automatically by `ironclad security.bat` (Phase 2 enable) and `disable security.bat` (Phase 2 disable) from the parent `cmd/` directory.

## Available Segments

1. **Privacy Security**
   - Enables/Disables Windows Telemetry, Cortana, and Advertising ID tracking.
2. **Update Security**
   - Enables/Disables Peer-to-Peer (P2P) Windows Update delivery optimization (prevents your PC from uploading updates to other devices).
3. **Lock Screen Security**
   - Enables/Disables camera access and app notifications on the lock screen to prevent information disclosure.
4. **AutoPlay Security**
   - Enables/Disables AutoPlay for all drives (including USB) to prevent automatic execution of malware upon insertion.
5. **USB Protection**
   - Background monitor that locks the workstation when a USB drive is inserted, requiring password re-entry. Registered as a SYSTEM Scheduled Task — persists on reboot, unkillable by standard users.

## Directory Structure

* `enable/`: Specific scripts to enable each of the supplementary features.
* `disable/`: Specific scripts to disable/revert the supplementary features.
* `usb_protect/`: USB insertion monitor daemon (locks workstation on USB insert).
* `apply_others_security.bat`: Master script to run all `enable` scripts sequentially.
* `remove_others_security.bat`: Master script to run all `disable` scripts sequentially.

## Script Reference

| Script | What It Does |
|--------|-------------|
| `enable_privacy_security` | Disables Telemetry, Cortana, Advertising ID |
| `disable_privacy_security` | Restores telemetry and Cortana defaults |
| `enable_update_security` | Disables P2P Windows Updates (DODownloadMode=0) |
| `disable_update_security` | Restores P2P updates (DODownloadMode=1) |
| `enable_lockscreen_security` | Disables camera and notifications on lock screen |
| `disable_lockscreen_security` | Restores lock screen camera and notifications |
| `enable_autoplay_security` | Disables AutoPlay for all drives (NoDriveTypeAutoRun=255) |
| `disable_autoplay_security` | Restores AutoPlay defaults |
| `start_usb_monitor` | Registers USB lock monitor as a SYSTEM Scheduled Task |

## Relation to Parent Scripts

| Parent Script (in `cmd/`) | Others Layer Action |
|---------------------------|-------------------|
| `ironclad security.bat` | Calls all `enable/` scripts + starts USB monitor (Phase 2 & 3) |
| `disable security.bat` | Calls all `disable/` scripts + removes USB monitor task (Phase 2 & 3) |
| `apply_others_security.bat` | Calls all `enable/` scripts only (no USB monitor) |
| `remove_others_security.bat` | Calls all `disable/` scripts only (no USB monitor) |

Remember to run all batch files as **Administrator**.

