#Requires -RunAsAdministrator
# Disable Lock Screen Security - Enable camera/notifications on lock screen

Write-Host "Disabling Lock Screen Security..." -ForegroundColor Yellow

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableLockScreenAppNotifications" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreenCamera" -Value 0 -Type DWord -Force

Write-Host "[OK] Lock Screen Security Disabled" -ForegroundColor Green

