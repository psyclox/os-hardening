#Requires -RunAsAdministrator
# Disable Network Security - Restore defaults

Write-Host "[1/7] Restoring Windows Firewall to defaults..." -ForegroundColor Yellow
netsh advfirewall reset | Out-Null

Write-Host "[2/7] Enabling SMBv1 (NOT recommended)..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 1 -Type DWord -Force

Write-Host "[3/7] Enabling IP Source Routing..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DisableIPSourceRouting" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DisableIPSourceRoutingIPv6" -Value 0 -Type DWord -Force

Write-Host "[4/7] Enabling ICMP Redirects..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "EnableICMPRedirect" -Value 1 -Type DWord -Force

Write-Host "[5/7] Enabling LLMNR..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 1 -Type DWord -Force

Write-Host "[6/7] Removing Port 445 Block Rule..." -ForegroundColor Yellow
Remove-NetFirewallRule -DisplayName "Block_SMB_445" -ErrorAction SilentlyContinue

Write-Host "[7/7] Removing Port 3389 Block Rule..." -ForegroundColor Yellow
Remove-NetFirewallRule -DisplayName "Block_RDP_3389" -ErrorAction SilentlyContinue

Write-Host "[OK] Network Security Disabled (Default Settings Restored)" -ForegroundColor Green
Read-Host "Press Enter to continue"
