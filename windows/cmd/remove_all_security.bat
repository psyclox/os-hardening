@echo off
:: Remove ALL Security Hardening (Restore Defaults)
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo ==============================================
echo    WARNING: Removing ALL Security Hardening
echo    Your system will be less secure
echo ==============================================
set /p confirm="Are you sure? (Y/N): "
if /i not "!confirm!"=="Y" exit /b 0

call "%~dp0disable\disable_login_security.bat"
call "%~dp0disable\disable_network_security.bat"
call "%~dp0disable\disable_credential_security.bat"
call "%~dp0disable\disable_malware_protection.bat"
call "%~dp0disable\disable_office_security.bat"

echo ==============================================
echo    All Security Measures Removed
echo    Default Windows settings restored
echo ==============================================
pause
exit /b 0
