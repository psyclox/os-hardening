#Requires -RunAsAdministrator
# Disable Login Security - Remove CAD requirement, restore defaults

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [DISABLE] Login Security disabled by $env:USERNAME"

Write-Host "Disabling Login Security (restoring defaults)..." -ForegroundColor Yellow
$SysPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

Write-Host "[1/2] Removing CAD requirement..." -ForegroundColor Yellow
Set-ItemProperty -Path $SysPath -Name "DisableCAD" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "DisableCAD" -Value 1 -Type DWord -Force

Write-Host "[2/2] Ensuring username display is on (confirming)..." -ForegroundColor Yellow
# Value 0 = SHOW username - this is both the default and what enable sets
Set-ItemProperty -Path $SysPath -Name "dontdisplaylastusername" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "dontdisplaylastusername" -Value 0 -Type DWord -Force

Write-Host ""
Write-Host "[OK] Login Security Disabled (CAD requirement removed)" -ForegroundColor Green
Write-Host "[OK] Log written to: $LogFile" -ForegroundColor Green

