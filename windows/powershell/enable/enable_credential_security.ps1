#Requires -RunAsAdministrator
# Enable Credential Security - WDigest disabled, SEHOP enabled

Write-Host "[1/2] Disabling WDigest Authentication..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0 -Type DWord -Force

Write-Host "[2/2] Enabling SEHOP..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "DisableExceptionChainValidation" -Value 0 -Type DWord -Force

Write-Host "[OK] Credential Security Enabled" -ForegroundColor Green
Read-Host "Press Enter to continue"
