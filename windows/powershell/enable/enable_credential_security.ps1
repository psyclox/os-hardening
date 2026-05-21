#Requires -RunAsAdministrator
# Enable Credential Security - WDigest disabled, SEHOP enabled, LSA RunAsPPL
# Version 2.0 - Added LSA Protected Process Light to block credential dumping tools

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [ENABLE] Credential Security applied by $env:USERNAME"

Write-Host "[1/3] Disabling WDigest Authentication (prevents plaintext passwords in memory)..." -ForegroundColor Cyan
$WDigestPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest"
Set-ItemProperty -Path $WDigestPath -Name "UseLogonCredential" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $WDigestPath -Name "Negotiate"          -Value 0 -Type DWord -Force

Write-Host "[2/3] Enabling SEHOP (Structured Exception Handling Overwrite Protection)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "DisableExceptionChainValidation" -Value 0 -Type DWord -Force

Write-Host "[3/3] Enabling LSA Protected Process Light (blocks credential dumping tools like Mimikatz)..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 1 -Type DWord -Force

Write-Host ""
Write-Host "[OK] Credential Security Enabled" -ForegroundColor Green
Write-Host "[OK] WDigest disabled - no plaintext passwords in memory" -ForegroundColor Green
Write-Host "[OK] SEHOP enabled - stack overflow exploits blocked" -ForegroundColor Green
Write-Host "[OK] LSA RunAsPPL enabled - Mimikatz-style attacks blocked" -ForegroundColor Green
Write-Host "[OK] Log written to: $LogFile" -ForegroundColor Green
Write-Host ""
Write-Host "[WARN] Reboot required for LSA Protected Process Light to take effect." -ForegroundColor Yellow
Read-Host "Press Enter to continue"
