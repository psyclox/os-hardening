@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: TURN OFF SECURITY - Remove all core security hardening
:: Must be run as Administrator
:: Calls: disable_login, disable_network, disable_credential,
::        disable_malware, disable_office
:: WARNING: This leaves the system significantly less secure.
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    exit /b 1
)

echo.
echo ==============================================
echo  [CRITICAL] TURN OFF SECURITY
echo  Your system will be significantly less secure.
echo  All protections will be removed.
echo ==============================================
echo.
set /p confirm="Type CONFIRM to proceed (anything else cancels): "
if /i not "!confirm!"=="CONFIRM" (
    echo [CANCELLED] No changes made. System remains secure.
    exit /b 0
)

:: Logging
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [TURN-OFF] ALL hardening REMOVED by %USERNAME% >> "%LOG_FILE%"
echo [SECURITY EVENT] System hardening was completely turned off >> "%LOG_FILE%"

call "%~dp0disable\disable_login_security.bat"
call "%~dp0disable\disable_network_security.bat"
call "%~dp0disable\disable_credential_security.bat"
call "%~dp0disable\disable_malware_protection.bat"
call "%~dp0disable\disable_office_security.bat"

echo.
echo ==============================================
echo    [WARN] All Security Measures are NOW OFF
echo    Default Windows settings restored.
echo    Log: C:\ProgramData\OrgSecurity\security_log.txt
echo ==============================================
echo.
echo [WARN] System is now unprotected. Run "turn on security.bat" to re-harden.
endlocal
exit /b 0
