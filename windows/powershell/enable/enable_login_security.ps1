#Requires -RunAsAdministrator
# Enable Login Security - CAD Required, Username Shown
# Note: Username display is intentionally kept ON (value 0).
#       The creator removed the hide-username feature because employee
#       usernames are often unknown. Employees can see their username
#       on the lock screen and just type their password as normal.

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [ENABLE] Login Security applied by $env:USERNAME"

Write-Host "Enabling Login Security..." -ForegroundColor Cyan

Write-Host "[1/2] Requiring Ctrl+Alt+Delete at login..." -ForegroundColor Cyan
$SysPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $SysPath -Name "DisableCAD" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "DisableCAD" -Value 0 -Type DWord -Force

Write-Host "[2/2] Keeping username visible on login/lock screen (intentional)..." -ForegroundColor Cyan
# Value 0 = DISPLAY last username (employees can see their own username)
# The hide-username feature was removed by design — employees don't always
# know their own login username and should be able to see it on screen.
Set-ItemProperty -Path $SysPath -Name "dontdisplaylastusername" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "dontdisplaylastusername" -Value 0 -Type DWord -Force

Write-Host ""
Write-Host "[OK] Login Security Enabled" -ForegroundColor Green
Write-Host "[OK] Ctrl+Alt+Delete required at login" -ForegroundColor Green
Write-Host "[OK] Username is shown on lock screen (by design)" -ForegroundColor Green
Write-Host "[OK] Log written to: $LogFile" -ForegroundColor Green
Read-Host "Press Enter to continue"
