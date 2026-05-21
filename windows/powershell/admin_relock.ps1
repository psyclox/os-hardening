#Requires -RunAsAdministrator
# ADMIN RELOCK - Re-apply all security hardening instantly
# Run this after admin_emergency_unlock.ps1 work is complete

# Logging
$LogDir    = "C:\ProgramData\OrgSecurity"
$LogFile   = "$LogDir\security_log.txt"
$UnlockLog = "$LogDir\unlock_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
Add-Content -Path $LogFile   -Value "[$Stamp] [RELOCK] Security re-applied by $env:USERNAME after admin unlock"
Add-Content -Path $UnlockLog -Value "[$Stamp] [RELOCK] System relocked by $env:USERNAME"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " ADMIN RELOCK - Re-applying all security hardening"          -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

& "$PSScriptRoot\apply_all_security.ps1"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " [OK] System is fully re-hardened"                            -ForegroundColor Green
Write-Host " [OK] Relock event logged"                                    -ForegroundColor Green
Write-Host " [WARN] Reboot recommended for all changes to fully activate" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Green
Read-Host "Press Enter to exit"
