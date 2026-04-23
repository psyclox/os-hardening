#Requires -RunAsAdministrator
# Enable Login Security - CAD Required, Username Shown

Write-Host "Enabling Login Security..." -ForegroundColor Cyan

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "dontdisplaylastusername" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "DisableCAD" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "dontdisplaylastusername" -Value 0 -Type DWord -Force

Write-Host "[OK] CAD Required, Username Shown" -ForegroundColor Green
Read-Host "Press Enter to continue"
