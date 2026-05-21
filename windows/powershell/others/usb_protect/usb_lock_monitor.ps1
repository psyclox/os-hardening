# USB Lock Monitor - CIM-based (replaces deprecated Register-WmiEvent)
# This script monitors for USB drive insertions and locks the workstation immediately.
# Designed to run as a SYSTEM Scheduled Task - do not run directly.
# Version 2.0

$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\usb_events.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$Query = "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_LogicalDisk' AND TargetInstance.DriveType = 2"

$Action = {
    $Stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path "C:\ProgramData\OrgSecurity\usb_events.txt" -Value "[$Stamp] USB drive inserted - workstation locked"
    & rundll32.exe user32.dll,LockWorkStation
}

try {
    Register-CimIndicationEvent -Query $Query -SourceIdentifier "USBInserted" -Action $Action -ErrorAction Stop
} catch {
    # Fallback to WMI if CIM subscription fails
    Register-WmiEvent -Query $Query -SourceIdentifier "USBInserted" -Action $Action -ErrorAction SilentlyContinue
}

# Keep alive indefinitely (when running as a Scheduled Task, this is managed by the task)
while ($true) {
    Start-Sleep -Seconds 2
}
