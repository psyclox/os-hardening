#Requires -RunAsAdministrator
# Disable Network Security - Restore defaults
# Version 2.0 - GP Firewall lock cleanup + logging

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [DISABLE] Network Security disabled by $env:USERNAME"

Write-Host "[1/8] Restoring Windows Firewall to defaults..." -ForegroundColor Yellow
netsh advfirewall reset | Out-Null

Write-Host "[2/8] Removing Group Policy Firewall locks (restoring UI controls)..." -ForegroundColor Yellow
foreach ($profile in @("DomainProfile", "StandardProfile", "PublicProfile")) {
    $fwPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\$profile"
    if (Test-Path $fwPath) { Remove-Item -Path $fwPath -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host "[3/8] Enabling SMBv1 (NOT recommended unless legacy systems require it)..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 1 -Type DWord -Force

Write-Host "[4/8] Restoring IP Source Routing defaults..." -ForegroundColor Yellow
$TcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Set-ItemProperty -Path $TcpipPath -Name "DisableIPSourceRouting"     -Value 0 -Type DWord -Force
Set-ItemProperty -Path $TcpipPath -Name "DisableIPSourceRoutingIPv6" -Value 0 -Type DWord -Force

Write-Host "[5/8] Restoring ICMP Redirects..." -ForegroundColor Yellow
Set-ItemProperty -Path $TcpipPath -Name "EnableICMPRedirect" -Value 1 -Type DWord -Force

Write-Host "[6/8] Restoring LLMNR..." -ForegroundColor Yellow
$DNSPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
if (Test-Path $DNSPath) { Remove-ItemProperty -Path $DNSPath -Name "EnableMulticast" -Force -ErrorAction SilentlyContinue }

Write-Host "[7/8] Removing Port 445 Block Rule..." -ForegroundColor Yellow
Remove-NetFirewallRule -DisplayName "Block_SMB_445_IN" -ErrorAction SilentlyContinue

Write-Host "[8/8] Removing Port 3389 Block Rule..." -ForegroundColor Yellow
Remove-NetFirewallRule -DisplayName "Block_RDP_3389_IN" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "[OK] Network Security Disabled (Default Settings Restored)" -ForegroundColor Green
Write-Host "[OK] Firewall GP locks removed - UI controls restored" -ForegroundColor Green
Write-Host "[OK] Log written to: $LogFile" -ForegroundColor Green

