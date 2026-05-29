@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: DISABLE SECURITY - Remove ALL security hardening completely
:: Must be run as Administrator
:: Disables: core security + others security + stops USB monitor
:: WARNING: This leaves the system at Windows defaults (unprotected).
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    exit /b 1
)

echo.
echo ==============================================
echo  [CRITICAL] DISABLE ALL SECURITY
echo  This will remove ALL layers of hardening:
echo    - Core Security (Login, Network, Credential,
echo      Malware, Office)
echo    - Extended Security (Privacy, Updates,
echo      LockScreen, AutoPlay)
echo    - USB Lock Monitor task
echo  Your system will be at Windows defaults.
echo ==============================================
echo.
set /p confirm="Type DISABLE to proceed (anything else cancels): "
if /i not "!confirm!"=="DISABLE" (
    echo [CANCELLED] No changes made. System remains secure.
    exit /b 0
)

:: Logging
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [DISABLE-ALL] ALL security layers DISABLED by %USERNAME% >> "%LOG_FILE%"
echo [SECURITY EVENT] Complete security wipe executed >> "%LOG_FILE%"

echo [PHASE 1/3] Removing Core Security Hardening...
call "%~dp0disable\disable_login_security.bat"
call "%~dp0disable\disable_network_security.bat"
call "%~dp0disable\disable_credential_security.bat"
call "%~dp0disable\disable_malware_protection.bat"
call "%~dp0disable\disable_office_security.bat"

echo.
echo [PHASE 2/3] Removing Extended (Others) Security Hardening...
call "%~dp0others\disable\disable_privacy_security.bat"
call "%~dp0others\disable\disable_update_security.bat"
call "%~dp0others\disable\disable_lockscreen_security.bat"
call "%~dp0others\disable\disable_autoplay_security.bat"

echo.
echo [PHASE 3/3] Stopping and Removing USB Lock Monitor...
schtasks /end /tn "OrgSecurity_USBLockMonitor" >nul 2>&1
schtasks /delete /tn "OrgSecurity_USBLockMonitor" /f >nul 2>&1
echo [OK] USB Monitor task removed

echo.
echo ==============================================
echo    [WARN] ALL Security Measures DISABLED
echo    System is now at Windows default settings.
echo    Log: C:\ProgramData\OrgSecurity\security_log.txt
echo    Run "ironclad security.bat" or "turn on security.bat"
echo    to re-apply hardening.
echo ==============================================
echo.
endlocal
exit /b 0
