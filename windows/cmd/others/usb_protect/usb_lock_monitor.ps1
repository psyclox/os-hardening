# USB Lock Monitor - Persistent Scheduled Task Version
# Monitors for USB drive insertions and locks the workstation immediately.
# Registered as a SYSTEM-level Scheduled Task (unkillable by standard users).
# Version 2.0 - Uses CIM (replaces deprecated WMI Register-WmiEvent)

# Log the event
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\usb_events.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$Query = "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_LogicalDisk' AND TargetInstance.DriveType = 2"

$Action = {
    $Stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path "C:\ProgramData\OrgSecurity\usb_events.txt" -Value "[$Stamp] USB drive inserted - workstation locked"
    Write-Host "[$Stamp] USB device detected! Locking workstation..." -ForegroundColor Red
    & rundll32.exe user32.dll,LockWorkStation
}

try {
    # Use Register-CimIndicationEvent (modern replacement for deprecated Register-WmiEvent)
    $Subscription = Register-CimIndicationEvent -Query $Query -SourceIdentifier "USBInserted" -Action $Action -ErrorAction Stop
    Write-Host "[OK] USB Lock Monitor active (CIM subscription)" -ForegroundColor Green
    Write-Host "[OK] Events logged to: $LogFile" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop (if running manually)." -ForegroundColor Yellow

    while ($true) {
        Start-Sleep -Seconds 2
    }
} catch {
    # Fallback to WMI if CIM not available
    Write-Host "[WARN] CIM subscription failed, falling back to WMI..." -ForegroundColor Yellow
    Register-WmiEvent -Query $Query -SourceIdentifier "USBInserted" -Action $Action -ErrorAction SilentlyContinue
    Write-Host "[OK] USB Lock Monitor active (WMI fallback)" -ForegroundColor Green

    while ($true) {
        Start-Sleep -Seconds 2
    }
}
