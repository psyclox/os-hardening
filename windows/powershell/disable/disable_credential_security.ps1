#Requires -RunAsAdministrator
# Disable Credential Security - WDigest enabled, SEHOP disabled

Write-Host "[1/2] Enabling WDigest Authentication..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 1 -Type DWord -Force

Write-Host "[2/2] Disabling SEHOP..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "DisableExceptionChainValidation" -Value 1 -Type DWord -Force

Write-Host "[WARNING] WDigest stores plaintext passwords in memory" -ForegroundColor Red
Write-Host "[OK] Credential Security Disabled" -ForegroundColor Green
Read-Host "Press Enter to continue"
