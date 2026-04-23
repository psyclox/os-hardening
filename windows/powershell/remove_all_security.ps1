#Requires -RunAsAdministrator
# Remove ALL Security Hardening (Restore Defaults)

Write-Host "==============================================" -ForegroundColor Red
Write-Host "   WARNING: Removing ALL Security Hardening" -ForegroundColor Red
Write-Host "   Your system will be less secure" -ForegroundColor Red
Write-Host "==============================================" -ForegroundColor Red

$confirm = Read-Host "Are you sure? (Y/N)"
if ($confirm -ne "Y") { exit }

& "$PSScriptRoot\disable\disable_login_security.ps1"
& "$PSScriptRoot\disable\disable_network_security.ps1"
& "$PSScriptRoot\disable\disable_credential_security.ps1"
& "$PSScriptRoot\disable\disable_malware_protection.ps1"
& "$PSScriptRoot\disable\disable_office_security.ps1"

Write-Host "==============================================" -ForegroundColor Green
Write-Host "   All Security Measures Removed" -ForegroundColor Green
Write-Host "   Default Windows settings restored" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Green
Read-Host "Press Enter to continue"
