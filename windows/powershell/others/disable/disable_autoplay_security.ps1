#Requires -RunAsAdministrator
# Disable AutoPlay Security - Enable AutoPlay

Write-Host "Disabling AutoPlay Security..." -ForegroundColor Yellow

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 145 -Type DWord -Force

Write-Host "[OK] AutoPlay Security Disabled" -ForegroundColor Green
Read-Host "Press Enter to continue"
