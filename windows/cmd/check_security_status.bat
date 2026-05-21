@echo off
setlocal enabledelayedexpansion
:: Security Status Check - Shows current state of all hardening settings
:: Run as Administrator for complete results
:: Version 2.0

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator for accurate results
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  SECURITY STATUS CHECK - Organisation Hardening Report
echo  %DATE% %TIME%
echo ============================================================
echo.

:: --- MALWARE PROTECTION ---
echo [MALWARE PROTECTION]

:: Real-time Protection
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware 2^>nul ^| find "DisableAntiSpyware"') do set AV_VAL=%%v
if "!AV_VAL!"=="0x0" ( echo   Real-time Protection (GP):  [OK] ENABLED ) else ( echo   Real-time Protection (GP):  [!!] DISABLED or NOT SET )

for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring 2^>nul ^| find "DisableRealtimeMonitoring"') do set RTP_VAL=%%v
if "!RTP_VAL!"=="0x0" ( echo   Realtime Monitoring (GP):   [OK] LOCKED ON ) else ( echo   Realtime Monitoring (GP):   [!!] NOT LOCKED )

:: Tamper Protection
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows Defender" /v TamperProtection 2^>nul ^| find "TamperProtection"') do set TP_VAL=%%v
if "!TP_VAL!"=="0x5" ( echo   Tamper Protection:          [OK] ENABLED (5) ) else ( echo   Tamper Protection:          [!!] DISABLED or NOT SET (val=!TP_VAL!) )

:: Cloud Protection
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpyNetReporting 2^>nul ^| find "SpyNetReporting"') do set CLOUD_VAL=%%v
if "!CLOUD_VAL!"=="0x2" ( echo   Cloud Protection (GP):     [OK] ENABLED ) else ( echo   Cloud Protection (GP):     [!!] DISABLED or NOT SET )

:: Script Block Logging
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging 2^>nul ^| find "EnableScriptBlockLogging"') do set SBL_VAL=%%v
if "!SBL_VAL!"=="0x1" ( echo   PS Script Block Logging:   [OK] ENABLED ) else ( echo   PS Script Block Logging:   [!!] DISABLED )

echo.

:: --- NETWORK SECURITY ---
echo [NETWORK / FIREWALL]

:: Firewall GP lock - Domain
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /v EnableFirewall 2^>nul ^| find "EnableFirewall"') do set FW_D=%%v
if "!FW_D!"=="0x1" ( echo   Firewall GP Lock (Domain):  [OK] LOCKED ON ) else ( echo   Firewall GP Lock (Domain):  [!!] NOT LOCKED - employees can toggle! )

:: Firewall GP lock - Standard
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /v EnableFirewall 2^>nul ^| find "EnableFirewall"') do set FW_S=%%v
if "!FW_S!"=="0x1" ( echo   Firewall GP Lock (Private): [OK] LOCKED ON ) else ( echo   Firewall GP Lock (Private): [!!] NOT LOCKED - employees can toggle! )

:: Firewall GP lock - Public
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /v EnableFirewall 2^>nul ^| find "EnableFirewall"') do set FW_P=%%v
if "!FW_P!"=="0x1" ( echo   Firewall GP Lock (Public):  [OK] LOCKED ON ) else ( echo   Firewall GP Lock (Public):  [!!] NOT LOCKED - employees can toggle! )

:: SMBv1
for /f "tokens=3" %%v in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 2^>nul ^| find "SMB1"') do set SMB_VAL=%%v
if "!SMB_VAL!"=="0x0" ( echo   SMBv1:                      [OK] DISABLED ) else ( echo   SMBv1:                      [!!] ENABLED (security risk!) )

:: LLMNR
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast 2^>nul ^| find "EnableMulticast"') do set LLMNR_VAL=%%v
if "!LLMNR_VAL!"=="0x0" ( echo   LLMNR:                      [OK] DISABLED ) else ( echo   LLMNR:                      [!!] ENABLED (poisoning risk) )

echo.

:: --- LOGIN SECURITY ---
echo [LOGIN SECURITY]

:: CAD
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD 2^>nul ^| find "DisableCAD"') do set CAD_VAL=%%v
if "!CAD_VAL!"=="0x0" ( echo   Ctrl+Alt+Del Required:     [OK] YES ) else ( echo   Ctrl+Alt+Del Required:     [!!] NO )

:: Username hidden
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername 2^>nul ^| find "dontdisplaylastusername"') do set UNAME_VAL=%%v
if "!UNAME_VAL!"=="0x0" ( echo   Username Shown (by design):  [OK] YES ) else ( echo   Username Shown (by design):  [--] Key not set or set to hide )

echo.

:: --- CREDENTIAL SECURITY ---
echo [CREDENTIAL SECURITY]

:: WDigest
for /f "tokens=3" %%v in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential 2^>nul ^| find "UseLogonCredential"') do set WD_VAL=%%v
if "!WD_VAL!"=="0x0" ( echo   WDigest (plaintext creds):  [OK] DISABLED ) else ( echo   WDigest (plaintext creds):  [!!] ENABLED - passwords in memory! )

:: SEHOP
for /f "tokens=3" %%v in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation 2^>nul ^| find "DisableExceptionChainValidation"') do set SEHOP_VAL=%%v
if "!SEHOP_VAL!"=="0x0" ( echo   SEHOP:                     [OK] ENABLED ) else ( echo   SEHOP:                     [!!] DISABLED )

:: LSA RunAsPPL
for /f "tokens=3" %%v in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL 2^>nul ^| find "RunAsPPL"') do set PPL_VAL=%%v
if "!PPL_VAL!"=="0x1" ( echo   LSA RunAsPPL:              [OK] ENABLED ) else ( echo   LSA RunAsPPL:              [!!] DISABLED - credential dumping possible ) )

echo.

:: --- OFFICE SECURITY ---
echo [OFFICE SECURITY]

for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\word\Security" /v VBAWarnings 2^>nul ^| find "VBAWarnings"') do set OFF_VAL=%%v
if "!OFF_VAL!"=="0x4" ( echo   Office Macros (GP 16.0):   [OK] LOCKED DISABLED ) else ( echo   Office Macros (GP 16.0):   [!!] NOT LOCKED or NOT SET )

for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Office\15.0\word\Security" /v VBAWarnings 2^>nul ^| find "VBAWarnings"') do set OFF15_VAL=%%v
if "!OFF15_VAL!"=="0x4" ( echo   Office Macros (GP 15.0):   [OK] LOCKED DISABLED ) else ( echo   Office Macros (GP 15.0):   [--] NOT SET (OK if Office 2013 not installed) )

echo.
echo ============================================================
echo  [OK] = Setting is correctly hardened
echo  [!!] = PROBLEM - setting is missing or wrong
echo  [--] = Not applicable / informational only
echo ============================================================
echo.
echo Run enable_malware_protection.bat / apply_all_security.bat
echo to fix any [!!] items.
echo.
pause
endlocal
exit /b 0
