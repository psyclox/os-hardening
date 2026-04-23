# Windows Security Hardening - Others (CMD)

This folder contains supplementary security scripts to harden peripheral areas of your Windows operating system.

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
   - Background monitor that locks the workstation when a USB drive is inserted, requiring password re-entry.

## Directory Structure

* `enable/`: Specific scripts to enable each of the supplementary features.
* `disable/`: Specific scripts to disable/revert the supplementary features.
* `usb_protect/`: USB insertion monitor daemon (locks workstation on USB insert).
* `apply_others_security.bat`: Master script to run all `enable` scripts sequentially.
* `remove_others_security.bat`: Master script to run all `disable` scripts sequentially.

Remember to run all batch files as **Administrator**.
