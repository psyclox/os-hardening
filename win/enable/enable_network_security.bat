@echo off
:: Enable Network Security - Firewall, SMBv1 disabled, ports blocked
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo [1/7] Enabling Windows Firewall...
netsh advfirewall set allprofiles state on >nul
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound >nul

echo [2/7] Disabling SMBv1...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart" >nul 2>&1

echo [3/7] Disabling IP Source Routing...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRoutingIPv6 /t REG_DWORD /d 2 /f >nul 2>&1

echo [4/7] Disabling ICMP Redirects...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /t REG_DWORD /d 0 /f >nul 2>&1

echo [5/7] Disabling LLMNR...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f >nul 2>&1

echo [6/7] Blocking Inbound Port 445 (SMB)...
netsh advfirewall firewall add rule name="Block_SMB_445" dir=in protocol=tcp localport=445 action=block >nul 2>&1

echo [7/7] Blocking Inbound Port 3389 (RDP)...
netsh advfirewall firewall add rule name="Block_RDP_3389" dir=in protocol=tcp localport=3389 action=block >nul 2>&1

echo [OK] Network Security Enabled
pause
exit /b 0
