@echo off
:: Apply ALL Others Security Hardening
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo ==============================================
echo    Applying Others Security Hardening
echo ==============================================

call "%~dp0enable\enable_privacy_security.bat"
call "%~dp0enable\enable_update_security.bat"
call "%~dp0enable\enable_lockscreen_security.bat"
call "%~dp0enable\enable_autoplay_security.bat"

echo ==============================================
echo    All Others Security Measures Applied
echo ==============================================
pause
exit /b 0
