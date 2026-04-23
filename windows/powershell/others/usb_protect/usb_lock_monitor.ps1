# USB Lock Monitor
# This script monitors for USB drive insertions and locks the workstation immediately.
# Locking the workstation requires the user to input the system password to unlock.

$query = "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_LogicalDisk' AND TargetInstance.DriveType = 2"

$action = {
    Write-Host "USB device inserted! Locking workstation..."
    rundll32.exe user32.dll,LockWorkStation
}

Register-WmiEvent -Query $query -SourceIdentifier "USBInserted" -Action $action

Write-Host "Monitoring for USB insertions. Press Ctrl+C to exit."
while ($true) {
    Start-Sleep -Seconds 1
}
