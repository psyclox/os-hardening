@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: TURN ON SECURITY - Enable all core security hardening
:: Must be run as Administrator
:: Calls: enable_login, enable_network, enable_credential,
::        enable_malware, enable_office
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
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [TURN-ON] Full security hardening enabled by %USERNAME% >> "%LOG_FILE%"

echo ==============================================
echo    TURN ON SECURITY - Enabling All Hardening
echo    Organisation Security Lockdown
echo ==============================================
echo.

call "%~dp0enable\enable_login_security.bat"
call "%~dp0enable\enable_network_security.bat"
call "%~dp0enable\enable_credential_security.bat"
call "%~dp0enable\enable_malware_protection.bat"
call "%~dp0enable\enable_office_security.bat"

echo.
echo ==============================================
echo    [OK] All Security Measures are NOW ON
echo    Log: C:\ProgramData\OrgSecurity\security_log.txt
echo    Reboot REQUIRED for all changes to take effect
echo ==============================================
echo.
endlocal
exit /b 0
