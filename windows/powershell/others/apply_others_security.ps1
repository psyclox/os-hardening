#Requires -RunAsAdministrator
# Apply ALL Others Security Hardening

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   Applying Others Security Hardening" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

& "$PSScriptRoot\enable\enable_privacy_security.ps1"
& "$PSScriptRoot\enable\enable_update_security.ps1"
& "$PSScriptRoot\enable\enable_lockscreen_security.ps1"
& "$PSScriptRoot\enable\enable_autoplay_security.ps1"

Write-Host "==============================================" -ForegroundColor Green
Write-Host "   All Others Security Measures Applied" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

