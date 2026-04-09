@echo off
:: Disable Credential Security - WDigest enabled, SEHOP disabled
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo [1/2] Enabling WDigest Authentication...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f >nul 2>&1

echo [2/2] Disabling SEHOP...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 1 /f >nul 2>&1

echo [WARNING] WDigest stores plaintext passwords in memory
echo [OK] Credential Security Disabled
pause
exit /b 0
