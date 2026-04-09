# Windows Security Hardening - Others

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

## Directory Structure

* `enable/`: Specific scripts to enable each of the supplementary features.
* `disable/`: Specific scripts to disable/revert the supplementary features.
* `apply_others_security.bat`: Master script to run all `enable` scripts sequentially.
* `remove_others_security.bat`: Master script to run all `disable` scripts sequentially.

Remember to run all batch files as **Administrator**.
