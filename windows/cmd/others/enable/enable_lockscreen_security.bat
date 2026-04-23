@echo off
:: Enable Lock Screen Security - Disable camera/notifications on lock screen
:: Must be run as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 ( exit /b 1 )

echo Enabling Lock Screen Security...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableLockScreenAppNotifications /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreenCamera /t REG_DWORD /d 1 /f >nul 2>&1
echo [OK] Lock Screen Security Enabled
pause
exit /b 0
