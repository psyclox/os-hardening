@echo off
:: Apply ALL Security Hardening Measures
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo ==============================================
echo    Applying ALL Security Hardening
echo ==============================================

call "%~dp0enable\enable_login_security.bat"
call "%~dp0enable\enable_network_security.bat"
call "%~dp0enable\enable_credential_security.bat"
call "%~dp0enable\enable_malware_protection.bat"
call "%~dp0enable\enable_office_security.bat"

echo ==============================================
echo    All Security Measures Applied
echo    Reboot recommended
echo ==============================================
pause
exit /b 0
