@echo off
setlocal enabledelayedexpansion
:: Disable Credential Security - Restore defaults (WDigest enabled, SEHOP disabled)
:: Must be run as Administrator
:: Version 2.0 - setlocal + logging

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
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [DISABLE] Credential Security disabled by %USERNAME% >> "%LOG_FILE%"
echo [SECURITY EVENT] WDigest re-enabled - plaintext passwords now exposed in memory >> "%LOG_FILE%"

echo [1/3] Re-enabling WDigest Authentication...
echo [WARNING] WDigest stores plaintext passwords in memory - credential dumping tools can extract them!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v Negotiate /t REG_DWORD /d 1 /f >nul 2>&1

echo [2/3] Disabling SEHOP...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 1 /f >nul 2>&1

echo [3/3] Disabling LSA Protected Process Light (RunAsPPL)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo [WARNING] WDigest stores plaintext passwords in memory!
echo [WARNING] LSA protection disabled - credential dumping tools may work!
echo [OK] Credential Security Disabled
echo [OK] Log written to: %LOG_FILE%
echo.
echo [WARN] Reboot required for RunAsPPL change to take effect.
endlocal
exit /b 0
