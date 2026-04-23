#Requires -RunAsAdministrator
# Enable Network Security - Firewall, SMBv1 disabled, ports blocked

Write-Host "[1/7] Enabling Windows Firewall..." -ForegroundColor Cyan
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block -DefaultOutboundAction Allow

Write-Host "[2/7] Disabling SMBv1..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Type DWord -Force
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null

Write-Host "[3/7] Disabling IP Source Routing..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DisableIPSourceRouting" -Value 2 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DisableIPSourceRoutingIPv6" -Value 2 -Type DWord -Force

Write-Host "[4/7] Disabling ICMP Redirects..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "EnableICMPRedirect" -Value 0 -Type DWord -Force

Write-Host "[5/7] Disabling LLMNR..." -ForegroundColor Cyan
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 0 -Type DWord -Force

Write-Host "[6/7] Blocking Inbound Port 445 (SMB)..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Block_SMB_445" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Block -ErrorAction SilentlyContinue | Out-Null

Write-Host "[7/7] Blocking Inbound Port 3389 (RDP)..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Block_RDP_3389" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block -ErrorAction SilentlyContinue | Out-Null

Write-Host "[OK] Network Security Enabled" -ForegroundColor Green
Read-Host "Press Enter to continue"
