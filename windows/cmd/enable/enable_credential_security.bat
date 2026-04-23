@echo off
:: Enable Credential Security - WDigest disabled, SEHOP enabled
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo [1/2] Disabling WDigest Authentication...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f >nul 2>&1

echo [2/2] Enabling SEHOP...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 0 /f >nul 2>&1

echo [OK] Credential Security Enabled
pause
exit /b 0
