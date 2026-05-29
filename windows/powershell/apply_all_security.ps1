#Requires -RunAsAdministrator
# Apply ALL Security Hardening Measures
# Version 2.0 - Added logging + status hint

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [APPLY-ALL] Full hardening applied by $env:USERNAME"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   Applying ALL Security Hardening"            -ForegroundColor Cyan
Write-Host "   Version 2.0 - Organisation Lockdown"        -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

& "$PSScriptRoot\enable\enable_login_security.ps1"
& "$PSScriptRoot\enable\enable_network_security.ps1"
& "$PSScriptRoot\enable\enable_credential_security.ps1"
& "$PSScriptRoot\enable\enable_malware_protection.ps1"
& "$PSScriptRoot\enable\enable_office_security.ps1"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "   All Security Measures Applied"              -ForegroundColor Green
Write-Host "   Log: C:\ProgramData\OrgSecurity\security_log.txt" -ForegroundColor Cyan
Write-Host "   Reboot REQUIRED for all changes to take effect" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Run check_security_status.ps1 to verify all settings." -ForegroundColor Cyan

