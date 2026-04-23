@echo off
:: Remove ALL Others Security Hardening
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo ==============================================
echo    WARNING: Removing Others Security Hardening
echo ==============================================
set /p confirm="Are you sure? (Y/N): "
if /i not "!confirm!"=="Y" exit /b 0

call "%~dp0disable\disable_privacy_security.bat"
call "%~dp0disable\disable_update_security.bat"
call "%~dp0disable\disable_lockscreen_security.bat"
call "%~dp0disable\disable_autoplay_security.bat"

echo ==============================================
echo    All Others Security Measures Removed
echo ==============================================
pause
exit /b 0
