#Requires -RunAsAdministrator
# Disable Update Security - Restore P2P updates

Write-Host "Disabling Update Security..." -ForegroundColor Yellow

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 1 -Type DWord -Force

Write-Host "[OK] Update Security Disabled (P2P Updates Restored)" -ForegroundColor Green
Read-Host "Press Enter to continue"
