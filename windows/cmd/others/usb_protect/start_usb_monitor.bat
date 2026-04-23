@echo off
:: Require Admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo Starting USB Monitor in the background...
start "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0usb_lock_monitor.ps1"
echo USB Monitor is running. When a USB flash drive is inserted, the PC will lock, requiring the system password.
pause
