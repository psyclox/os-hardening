#Requires -RunAsAdministrator
# Apply ALL Security Hardening Measures

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   Applying ALL Security Hardening" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

& "$PSScriptRoot\enable\enable_login_security.ps1"
& "$PSScriptRoot\enable\enable_network_security.ps1"
& "$PSScriptRoot\enable\enable_credential_security.ps1"
& "$PSScriptRoot\enable\enable_malware_protection.ps1"
& "$PSScriptRoot\enable\enable_office_security.ps1"

Write-Host "==============================================" -ForegroundColor Green
Write-Host "   All Security Measures Applied" -ForegroundColor Green
Write-Host "   Reboot recommended" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Green
Read-Host "Press Enter to continue"
