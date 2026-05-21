@echo off
setlocal enabledelayedexpansion
:: Remove ALL Security Hardening (Restore Defaults)
:: Must be run as Administrator
:: Version 2.0 - Fixed confirmation bug (requires typing CONFIRM) + logging

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo.
echo ==============================================
echo  [CRITICAL] Removing ALL Security Hardening
echo  Your system will be significantly less secure.
echo  All protections will be removed.
echo ==============================================
echo.
set /p confirm="Type CONFIRM to proceed (anything else cancels): "
if /i not "!confirm!"=="CONFIRM" (
    echo [CANCELLED] No changes made. System remains secure.
    pause
    exit /b 0
)

:: Logging setup
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [REMOVE-ALL] ALL hardening REMOVED by %USERNAME% >> "%LOG_FILE%"
echo [SECURITY EVENT] System hardening was completely removed >> "%LOG_FILE%"

call "%~dp0disable\disable_login_security.bat"
call "%~dp0disable\disable_network_security.bat"
call "%~dp0disable\disable_credential_security.bat"
call "%~dp0disable\disable_malware_protection.bat"
call "%~dp0disable\disable_office_security.bat"

echo.
echo ==============================================
echo    All Security Measures Removed
echo    Default Windows settings restored
echo    Log: C:\ProgramData\OrgSecurity\security_log.txt
echo ==============================================
echo.
echo [WARN] System is now unprotected. Run apply_all_security.bat to re-harden.
pause
endlocal
exit /b 0
