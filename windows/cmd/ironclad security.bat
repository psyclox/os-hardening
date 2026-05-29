@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: IRONCLAD SECURITY - Maximum Security Mode
:: Must be run as Administrator
:: Applies ALL hardening: core security + others (privacy,
:: update, lockscreen, autoplay) + USB Lock Monitor
:: This is the highest level of organisational lockdown.
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    exit /b 1
)

:: Logging
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [IRONCLAD] Maximum security mode applied by %USERNAME% >> "%LOG_FILE%"

echo ==============================================
echo    IRONCLAD SECURITY - Maximum Lockdown
echo    All hardening layers will be applied:
echo      1. Core Security (Login, Network,
echo         Credential, Malware, Office)
echo      2. Extended Security (Privacy, Updates,
echo         LockScreen, AutoPlay)
echo      3. USB Lock Monitor (auto-starts on boot)
echo ==============================================
echo.

echo [PHASE 1/3] Applying Core Security Hardening...
call "%~dp0enable\enable_login_security.bat"
call "%~dp0enable\enable_network_security.bat"
call "%~dp0enable\enable_credential_security.bat"
call "%~dp0enable\enable_malware_protection.bat"
call "%~dp0enable\enable_office_security.bat"

echo.
echo [PHASE 2/3] Applying Extended (Others) Security Hardening...
call "%~dp0others\enable\enable_privacy_security.bat"
call "%~dp0others\enable\enable_update_security.bat"
call "%~dp0others\enable\enable_lockscreen_security.bat"
call "%~dp0others\enable\enable_autoplay_security.bat"

echo.
echo [PHASE 3/3] Starting USB Lock Monitor (Persistent SYSTEM Task)...
call "%~dp0others\usb_protect\start_usb_monitor.bat"

echo.
echo ==============================================
echo    [OK] IRONCLAD MODE ACTIVE
echo    All 3 phases completed successfully.
echo    Core + Extended + USB Monitor are running.
echo    Log: C:\ProgramData\OrgSecurity\security_log.txt
echo    Reboot REQUIRED for all changes to take effect.
echo ==============================================
echo.
endlocal
exit /b 0
