#Requires -RunAsAdministrator
# Enable AutoPlay Security - Disable AutoPlay for all drives

Write-Host "Enabling AutoPlay Security..." -ForegroundColor Cyan

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 1 -Type DWord -Force

New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255 -Type DWord -Force

Write-Host "[OK] AutoPlay Security Enabled" -ForegroundColor Green
Read-Host "Press Enter to continue"
