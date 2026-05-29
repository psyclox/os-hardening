@echo off
setlocal enabledelayedexpansion
:: Start USB Lock Monitor - Registers as a Scheduled Task under SYSTEM account
:: Version 2.0 - Persistent, survives reboots, unkillable by standard users
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

set SCRIPT_PATH=%~dp0usb_lock_monitor.ps1
set TASK_NAME=OrgSecurity_USBLockMonitor

echo [1/3] Checking if USB monitor task already exists...
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [INFO] Task already registered. Removing old task first...
    schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
)

echo [2/3] Registering USB Lock Monitor as a Scheduled Task (SYSTEM account)...
powershell -ExecutionPolicy Bypass -Command ^
    "$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File \"%SCRIPT_PATH%\"';" ^
    "$Trigger = New-ScheduledTaskTrigger -AtStartup;" ^
    "$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);" ^
    "$Principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest;" ^
    "Register-ScheduledTask -TaskName 'OrgSecurity_USBLockMonitor' -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Force | Out-Null;" ^
    "Write-Host '[OK] Task registered'"

echo [3/3] Starting the task now...
schtasks /run /tn "%TASK_NAME%" >nul 2>&1

echo.
echo [OK] USB Lock Monitor is now running as a SYSTEM Scheduled Task
echo [OK] It will auto-start on every reboot
echo [OK] Standard users cannot kill it via Task Manager
echo [OK] USB insertion events logged to: C:\ProgramData\OrgSecurity\usb_events.txt
echo.
echo To stop/remove: run as admin and execute:
echo   schtasks /delete /tn "%TASK_NAME%" /f
endlocal
exit /b 0
