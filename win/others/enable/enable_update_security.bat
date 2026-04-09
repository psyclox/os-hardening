@echo off
:: Enable Update Security - Disable P2P updates
:: Must be run as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 ( exit /b 1 )

echo Enabling Update Security...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f >nul 2>&1
echo [OK] Update Security Enabled (P2P Updates Disabled)
pause
exit /b 0
