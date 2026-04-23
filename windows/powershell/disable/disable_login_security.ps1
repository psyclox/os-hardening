#Requires -RunAsAdministrator
# Disable Login Security - No CAD Required, Username Shown

Write-Host "Disabling Login Security..." -ForegroundColor Yellow

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "dontdisplaylastusername" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "DisableCAD" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "dontdisplaylastusername" -Value 0 -Type DWord -Force

Write-Host "[OK] CAD Not Required, Username Shown" -ForegroundColor Green
Read-Host "Press Enter to continue"
