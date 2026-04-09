@echo off
:: Disable Update Security - Restore P2P updates
:: Must be run as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 ( exit /b 1 )

echo Disabling Update Security...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 1 /f >nul 2>&1
echo [OK] Update Security Disabled (P2P Updates Restored)
pause
exit /b 0
