@echo off
:: Disable Network Security - Restore defaults
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo [1/7] Restoring Windows Firewall to defaults...
netsh advfirewall reset >nul

echo [2/7] Enabling SMBv1 (if you really want this - NOT recommended)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 1 /f >nul 2>&1

echo [3/7] Enabling IP Source Routing...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRoutingIPv6 /t REG_DWORD /d 0 /f >nul 2>&1

echo [4/7] Enabling ICMP Redirects...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /t REG_DWORD /d 1 /f >nul 2>&1

echo [5/7] Enabling LLMNR...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 1 /f >nul 2>&1

echo [6/7] Removing Port 445 Block Rule...
netsh advfirewall firewall delete rule name="Block_SMB_445" >nul 2>&1

echo [7/7] Removing Port 3389 Block Rule...
netsh advfirewall firewall delete rule name="Block_RDP_3389" >nul 2>&1

echo [OK] Network Security Disabled (Default Settings Restored)
pause
exit /b 0
