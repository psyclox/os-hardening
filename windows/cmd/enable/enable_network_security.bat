@echo off
setlocal enabledelayedexpansion
:: Enable Network Security - Firewall (UI locked), SMBv1 disabled, ports blocked
:: Must be run as Administrator
:: Version 2.0 - Group Policy Firewall paths added to grey out UI for employees

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

:: Logging setup
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [ENABLE] Network Security applied by %USERNAME% >> "%LOG_FILE%"

echo [1/9] Enabling Windows Firewall (runtime config)...
netsh advfirewall set allprofiles state on >nul
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound >nul

echo [2/9] Locking Firewall via Group Policy (greys out toggle in Windows Security UI)...
:: Domain Profile
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /v EnableFirewall /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /v DefaultInboundAction /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /v DefaultOutboundAction /t REG_DWORD /d 0 /f >nul 2>&1
:: Standard (Private) Profile
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /v EnableFirewall /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /v DefaultInboundAction /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /v DefaultOutboundAction /t REG_DWORD /d 0 /f >nul 2>&1
:: Public Profile
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /v EnableFirewall /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /v DefaultInboundAction /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /v DefaultOutboundAction /t REG_DWORD /d 0 /f >nul 2>&1

echo [3/9] Disabling SMBv1...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart" >nul 2>&1

echo [4/9] Disabling IP Source Routing...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRoutingIPv6 /t REG_DWORD /d 2 /f >nul 2>&1

echo [5/9] Disabling ICMP Redirects...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /t REG_DWORD /d 0 /f >nul 2>&1

echo [6/9] Disabling LLMNR (prevents LLMNR poisoning attacks)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f >nul 2>&1

echo [7/9] Disabling NetBIOS over TCP/IP (prevents NetBIOS attacks)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" /v NodeType /t REG_DWORD /d 2 /f >nul 2>&1

echo [8/9] Blocking Inbound Port 445 (SMB)...
netsh advfirewall firewall add rule name="Block_SMB_445_IN" dir=in protocol=tcp localport=445 action=block >nul 2>&1

echo [9/9] Blocking Inbound Port 3389 (RDP)...
netsh advfirewall firewall add rule name="Block_RDP_3389_IN" dir=in protocol=tcp localport=3389 action=block >nul 2>&1

echo.
echo [OK] Network Security Enabled and Locked
echo [OK] Firewall toggle is now greyed out in Windows Security UI
echo [OK] Log written to: %LOG_FILE%
echo.
echo [WARN] Reboot recommended for all settings to take full effect.
pause
endlocal
exit /b 0
