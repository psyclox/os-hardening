@echo off
setlocal enabledelayedexpansion
:: Disable Network Security - Restore defaults
:: Must be run as Administrator
:: Version 2.0 - setlocal + logging + GP Firewall lock cleanup

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
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [DISABLE] Network Security disabled by %USERNAME% >> "%LOG_FILE%"

echo [1/8] Restoring Windows Firewall to defaults...
netsh advfirewall reset >nul

echo [2/8] Removing Group Policy Firewall locks (restoring UI controls)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" /f >nul 2>&1

echo [3/8] Re-enabling SMBv1 (NOT recommended unless required)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 1 /f >nul 2>&1

echo [4/8] Restoring IP Source Routing defaults...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRoutingIPv6 /t REG_DWORD /d 0 /f >nul 2>&1

echo [5/8] Restoring ICMP Redirects...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /t REG_DWORD /d 1 /f >nul 2>&1

echo [6/8] Restoring LLMNR...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /f >nul 2>&1

echo [7/8] Removing Port 445 Block Rule...
netsh advfirewall firewall delete rule name="Block_SMB_445_IN" >nul 2>&1

echo [8/8] Removing Port 3389 Block Rule...
netsh advfirewall firewall delete rule name="Block_RDP_3389_IN" >nul 2>&1

echo.
echo [OK] Network Security Disabled (Default Settings Restored)
echo [OK] Firewall GP locks removed - UI controls restored
echo [OK] Log written to: %LOG_FILE%
pause
endlocal
exit /b 0
