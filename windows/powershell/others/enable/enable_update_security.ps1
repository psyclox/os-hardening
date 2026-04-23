#Requires -RunAsAdministrator
# Enable Update Security - Disable P2P updates

Write-Host "Enabling Update Security..." -ForegroundColor Cyan

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0 -Type DWord -Force

Write-Host "[OK] Update Security Enabled (P2P Updates Disabled)" -ForegroundColor Green
Read-Host "Press Enter to continue"
