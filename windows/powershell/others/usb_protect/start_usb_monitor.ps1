#Requires -RunAsAdministrator
# Start USB Lock Monitor in the background

Write-Host "Starting USB Monitor in the background..." -ForegroundColor Cyan
$scriptPath = Join-Path $PSScriptRoot "usb_lock_monitor.ps1"
Start-Process powershell -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`"" -WindowStyle Hidden
Write-Host "USB Monitor is running. When a USB flash drive is inserted, the PC will lock, requiring the system password." -ForegroundColor Green
Read-Host "Press Enter to continue"
