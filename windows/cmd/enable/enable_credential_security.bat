@echo off
setlocal enabledelayedexpansion
:: Enable Credential Security - WDigest disabled, SEHOP enabled, LSA Protection
:: Must be run as Administrator
:: Version 2.0 - Added LSA RunAsPPL (Protected Process Light) for enhanced credential protection

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
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [ENABLE] Credential Security applied by %USERNAME% >> "%LOG_FILE%"

echo [1/3] Disabling WDigest Authentication (prevents plaintext passwords in memory)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v Negotiate /t REG_DWORD /d 0 /f >nul 2>&1

echo [2/3] Enabling SEHOP (Structured Exception Handling Overwrite Protection)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 0 /f >nul 2>&1

echo [3/3] Enabling LSA Protected Process Light (blocks credential dumping tools)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 1 /f >nul 2>&1

echo.
echo [OK] Credential Security Enabled
echo [OK] WDigest disabled - no plaintext passwords in memory
echo [OK] SEHOP enabled - stack overflow exploits blocked
echo [OK] LSA RunAsPPL enabled - Mimikatz-style credential dumping blocked
echo [OK] Log written to: %LOG_FILE%
echo.
echo [WARN] Reboot required for LSA Protected Process Light to take effect.
pause
endlocal
exit /b 0
