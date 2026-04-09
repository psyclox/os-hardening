@echo off
:: Enable Privacy Security - Disable Telemetry, Cortana, Ad ID
:: Must be run as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 ( exit /b 1 )

echo Enabling Privacy Security...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
echo [OK] Privacy Security Enabled
pause
exit /b 0
