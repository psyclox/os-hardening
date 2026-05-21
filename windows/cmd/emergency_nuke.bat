@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: EMERGENCY NUKE — Remove ALL Hardening Instantly
:: ============================================================
:: USE CASE: You are at an admin CMD and need to remove
:: all hardening WITHOUT relying on any of the disable scripts.
::
:: This script uses only: reg.exe, netsh.exe, powershell.exe
:: with inline -ExecutionPolicy Bypass (so PS policy doesn't matter).
::
:: KEEP THIS ON A USB STICK AS A PHYSICAL RECOVERY KEY.
:: Run from an Administrator CMD window.
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [ERROR] This script must be run as Administrator.
    echo Right-click CMD and select "Run as administrator"
    echo then run this script again.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  EMERGENCY NUKE - Removes ALL OS Hardening
echo  This is the manual recovery tool for when normal
echo  disable scripts cannot be run.
echo ============================================================
echo.
echo [STEP 1/10] Disabling Tamper Protection (required first)...
powershell -ExecutionPolicy Bypass -Command "try { Set-MpPreference -TamperProtection 4 -ErrorAction Stop; Write-Host ' Tamper Protection disabled' } catch { Write-Host ' NOTE: Disable Tamper Protection manually in Windows Security if Defender changes fail' }" 2>nul
echo.

echo [STEP 2/10] Removing Defender Group Policy locks...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f >nul 2>&1
if %errorLevel% equ 0 ( echo  [OK] Defender GP lock removed ) else ( echo  [--] Defender GP key not found (already clean) )

echo [STEP 3/10] Removing Firewall Group Policy locks (restores UI toggles)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /f >nul 2>&1
echo  [OK] Firewall GP locks removed - UI toggles restored

echo [STEP 4/10] Resetting Windows Firewall to defaults...
netsh advfirewall reset >nul
echo  [OK] Firewall reset to Windows defaults

echo [STEP 5/10] Removing port block rules (445, 3389)...
netsh advfirewall firewall delete rule name="Block_SMB_445_IN" >nul 2>&1
netsh advfirewall firewall delete rule name="Block_RDP_3389_IN" >nul 2>&1
echo  [OK] Port block rules removed

echo [STEP 6/10] Restoring login screen defaults (username visible, no CAD)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LegalNoticeCaption /t REG_SZ /d "" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LegalNoticeText /t REG_SZ /d "" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DontDisplayLastUserName /f >nul 2>&1
echo  [OK] Login screen restored to Windows defaults

echo [STEP 7/10] Restoring credential security defaults...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] WDigest restored, SEHOP disabled, RunAsPPL disabled

echo [STEP 8/10] Removing Office macro locks (HKLM GP paths)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office" /f >nul 2>&1
echo  [OK] Office GP macro locks removed

echo [STEP 9/10] Removing PowerShell logging and policy locks...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /f >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force" >nul 2>&1
echo  [OK] PS logging removed, execution policy reset to RemoteSigned

echo [STEP 10/10] Stopping and removing USB Lock Monitor task...
schtasks /end /tn "OrgSecurity_USBLockMonitor" >nul 2>&1
schtasks /delete /tn "OrgSecurity_USBLockMonitor" /f >nul 2>&1
echo  [OK] USB monitor task removed

echo.
echo [CLEANUP] Removing ASR rules...
powershell -ExecutionPolicy Bypass -Command "Remove-MpPreference -AttackSurfaceReductionRules_Ids 'D4F940AB-401B-4EFC-AADC-AD5F3C50688A','9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2','BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550','75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84','5BEB7EFE-FD9A-4556-801D-275E5FFC04CC','01443614-CD74-433A-B99E-2ECDC07BFC25','3B576869-A4EC-4529-8536-B80A7769E899','92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B','D3E037E1-3EB8-44C8-A917-57927947596D','26190899-1602-49E8-8B27-EB1D0A1CE869' -ErrorAction SilentlyContinue" 2>nul
echo  [OK] ASR rules removed

echo.
echo ============================================================
echo  [DONE] All hardening has been removed.
echo.
echo  IMPORTANT: A reboot is required for:
echo    - LSA RunAsPPL change to take effect
echo    - Some Defender/Tamper Protection changes to finalize
echo.
echo  After reboot, the system will be at Windows defaults.
echo  To re-apply hardening: run apply_all_security.bat
echo ============================================================
echo.
set /p reboot="Reboot now? (Y/N): "
if /i "!reboot!"=="Y" shutdown /r /t 5 /c "Emergency nuke reboot - hardening removed"
pause
endlocal
exit /b 0
