@echo off
:: Disable Lock Screen Security - Enable camera/notifications on lock screen
:: Must be run as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 ( exit /b 1 )

echo Disabling Lock Screen Security...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableLockScreenAppNotifications /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreenCamera /t REG_DWORD /d 0 /f >nul 2>&1
echo [OK] Lock Screen Security Disabled
pause
exit /b 0
