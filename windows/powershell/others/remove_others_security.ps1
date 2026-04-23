#Requires -RunAsAdministrator
# Remove ALL Others Security Hardening

Write-Host "==============================================" -ForegroundColor Yellow
Write-Host "   WARNING: Removing Others Security Hardening" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Yellow

$confirm = Read-Host "Are you sure? (Y/N)"
if ($confirm -ne "Y") { exit }

& "$PSScriptRoot\disable\disable_privacy_security.ps1"
& "$PSScriptRoot\disable\disable_update_security.ps1"
& "$PSScriptRoot\disable\disable_lockscreen_security.ps1"
& "$PSScriptRoot\disable\disable_autoplay_security.ps1"

Write-Host "==============================================" -ForegroundColor Green
Write-Host "   All Others Security Measures Removed" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Read-Host "Press Enter to continue"
