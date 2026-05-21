@echo off
setlocal enabledelayedexpansion
:: Apply ALL Security Hardening Measures
:: Must be run as Administrator
:: Version 2.0 - Added logging, others scripts, and status summary

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

:: Logging setup
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [APPLY-ALL] Full hardening applied by %USERNAME% >> "%LOG_FILE%"

echo ==============================================
echo    Applying ALL Security Hardening
echo    Version 2.0 - Organisation Lockdown
echo ==============================================
echo.

call "%~dp0enable\enable_login_security.bat"
call "%~dp0enable\enable_network_security.bat"
call "%~dp0enable\enable_credential_security.bat"
call "%~dp0enable\enable_malware_protection.bat"
call "%~dp0enable\enable_office_security.bat"

echo.
echo ==============================================
echo    All Security Measures Applied
echo    Log: C:\ProgramData\OrgSecurity\security_log.txt
echo    Reboot REQUIRED for all changes to take effect
echo ==============================================
echo.
echo Run check_security_status.bat to verify all settings.
pause
endlocal
exit /b 0
