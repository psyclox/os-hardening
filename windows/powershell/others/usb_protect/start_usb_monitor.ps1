#Requires -RunAsAdministrator
# Start USB Lock Monitor - Registers as a Scheduled Task under SYSTEM account
# Version 2.0 - Persistent, survives reboots, unkillable by standard users

$ScriptPath = Join-Path $PSScriptRoot "usb_lock_monitor.ps1"
$TaskName   = "OrgSecurity_USBLockMonitor"

Write-Host "[1/3] Checking if USB monitor task already exists..." -ForegroundColor Cyan
$Existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($Existing) {
    Write-Host "    Removing old task..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Write-Host "[2/3] Registering USB Lock Monitor as a Scheduled Task (SYSTEM account)..." -ForegroundColor Cyan
$Action    = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File `"$ScriptPath`""
$Trigger   = New-ScheduledTaskTrigger -AtStartup
$Settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Force | Out-Null

Write-Host "[3/3] Starting the task now..." -ForegroundColor Cyan
Start-ScheduledTask -TaskName $TaskName

Write-Host ""
Write-Host "[OK] USB Lock Monitor is now running as a SYSTEM Scheduled Task" -ForegroundColor Green
Write-Host "[OK] It will auto-start on every reboot"                          -ForegroundColor Green
Write-Host "[OK] Standard users cannot kill it via Task Manager"              -ForegroundColor Green
Write-Host "[OK] USB insertion events logged to: C:\ProgramData\OrgSecurity\usb_events.txt" -ForegroundColor Green
Write-Host ""
Write-Host "To stop/remove: Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false" -ForegroundColor Yellow
Read-Host "Press Enter to continue"
