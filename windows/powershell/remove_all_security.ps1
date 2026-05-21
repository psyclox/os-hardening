#Requires -RunAsAdministrator
# Remove ALL Security Hardening (Restore Defaults)
# Version 2.0 - Requires typing CONFIRM + logging

Write-Host ""
Write-Host "==============================================" -ForegroundColor Red
Write-Host "  [CRITICAL] Removing ALL Security Hardening" -ForegroundColor Red
Write-Host "  Your system will be significantly less secure." -ForegroundColor Red
Write-Host "  All protections will be removed."             -ForegroundColor Red
Write-Host "==============================================" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Type CONFIRM to proceed (anything else cancels)"
if ($confirm -ne "CONFIRM") {
    Write-Host "[CANCELLED] No changes made. System remains secure." -ForegroundColor Green
    exit
}

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [REMOVE-ALL] ALL hardening REMOVED by $env:USERNAME"
Add-Content -Path $LogFile -Value "[$Stamp] [SECURITY EVENT] System hardening was completely removed"

& "$PSScriptRoot\disable\disable_login_security.ps1"
& "$PSScriptRoot\disable\disable_network_security.ps1"
& "$PSScriptRoot\disable\disable_credential_security.ps1"
& "$PSScriptRoot\disable\disable_malware_protection.ps1"
& "$PSScriptRoot\disable\disable_office_security.ps1"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "   All Security Measures Removed"              -ForegroundColor Green
Write-Host "   Default Windows settings restored"          -ForegroundColor Yellow
Write-Host "   Log: C:\ProgramData\OrgSecurity\security_log.txt" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host "[WARN] System is now unprotected. Run apply_all_security.ps1 to re-harden." -ForegroundColor Yellow
Read-Host "Press Enter to continue"
