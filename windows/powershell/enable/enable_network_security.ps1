#Requires -RunAsAdministrator
# Enable Network Security - Firewall (UI locked), SMBv1 disabled, ports blocked
# Version 2.0 - Group Policy Firewall paths added to grey out UI for employees

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [ENABLE] Network Security applied by $env:USERNAME"

Write-Host "[1/9] Enabling Windows Firewall (runtime config)..." -ForegroundColor Cyan
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block -DefaultOutboundAction Allow

Write-Host "[2/9] Locking Firewall via Group Policy (greys out toggle in Windows Security UI)..." -ForegroundColor Cyan
foreach ($profile in @("DomainProfile", "StandardProfile", "PublicProfile")) {
    $fwPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\$profile"
    New-Item -Path $fwPath -Force | Out-Null
    Set-ItemProperty -Path $fwPath -Name "EnableFirewall"        -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fwPath -Name "DefaultInboundAction"  -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fwPath -Name "DefaultOutboundAction" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $fwPath -Name "DisableNotifications"  -Value 0 -Type DWord -Force
}

Write-Host "[3/9] Disabling SMBv1..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Type DWord -Force
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null

Write-Host "[4/9] Disabling IP Source Routing..." -ForegroundColor Cyan
$TcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Set-ItemProperty -Path $TcpipPath -Name "DisableIPSourceRouting"     -Value 2 -Type DWord -Force
Set-ItemProperty -Path $TcpipPath -Name "DisableIPSourceRoutingIPv6" -Value 2 -Type DWord -Force

Write-Host "[5/9] Disabling ICMP Redirects..." -ForegroundColor Cyan
Set-ItemProperty -Path $TcpipPath -Name "EnableICMPRedirect" -Value 0 -Type DWord -Force

Write-Host "[6/9] Disabling LLMNR (prevents poisoning attacks)..." -ForegroundColor Cyan
$DNSPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
New-Item -Path $DNSPath -Force | Out-Null
Set-ItemProperty -Path $DNSPath -Name "EnableMulticast" -Value 0 -Type DWord -Force

Write-Host "[7/9] Disabling NetBIOS over TCP/IP..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -Name "NodeType" -Value 2 -Type DWord -Force

Write-Host "[8/9] Blocking Inbound Port 445 (SMB)..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Block_SMB_445_IN" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Block -ErrorAction SilentlyContinue | Out-Null

Write-Host "[9/9] Blocking Inbound Port 3389 (RDP)..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Block_RDP_3389_IN" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block -ErrorAction SilentlyContinue | Out-Null

Write-Host ""
Write-Host "[OK] Network Security Enabled and Locked" -ForegroundColor Green
Write-Host "[OK] Firewall toggle is now greyed out in Windows Security UI" -ForegroundColor Green
Write-Host "[OK] Log written to: $LogFile" -ForegroundColor Green
Write-Host ""
Write-Host "[WARN] Reboot recommended for all settings to take full effect." -ForegroundColor Yellow
Read-Host "Press Enter to continue"
