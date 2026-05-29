#Requires -RunAsAdministrator
# Disable Credential Security - Restore defaults
# Version 2.0 - Added RunAsPPL disable + logging

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [DISABLE] Credential Security disabled by $env:USERNAME"
Add-Content -Path $LogFile -Value "[$Stamp] [SECURITY EVENT] WDigest re-enabled - plaintext passwords now exposed"

Write-Host "[1/3] Re-enabling WDigest Authentication..." -ForegroundColor Yellow
Write-Host "    [WARNING] WDigest stores plaintext passwords in memory!" -ForegroundColor Red
$WDigestPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest"
Set-ItemProperty -Path $WDigestPath -Name "UseLogonCredential" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $WDigestPath -Name "Negotiate"          -Value 1 -Type DWord -Force

Write-Host "[2/3] Disabling SEHOP..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "DisableExceptionChainValidation" -Value 1 -Type DWord -Force

Write-Host "[3/3] Disabling LSA Protected Process Light (RunAsPPL)..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 0 -Type DWord -Force

Write-Host ""
Write-Host "[WARNING] WDigest stores plaintext passwords in memory!" -ForegroundColor Red
Write-Host "[WARNING] LSA protection disabled - credential dumping tools may work!" -ForegroundColor Red
Write-Host "[OK] Credential Security Disabled" -ForegroundColor Green
Write-Host "[OK] Log written to: $LogFile" -ForegroundColor Green
Write-Host ""
Write-Host "[WARN] Reboot required for RunAsPPL change to take effect." -ForegroundColor Yellow

