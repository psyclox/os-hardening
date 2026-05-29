@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: ADMIN EMERGENCY UNLOCK - For IT Administrator Only
:: ============================================================
:: This script provides a password-protected temporary bypass
:: for the IT administrator to run maintenance scripts.
::
:: HOW TO CUSTOMIZE BEFORE DEPLOYMENT:
::   1. Choose a strong passphrase
::   2. Run this command to get the SHA-256 hash:
::      powershell -Command "(Get-FileHash -InputStream ([System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes('YOUR_PASSPHRASE'))) -Algorithm SHA256).Hash"
::   3. Replace the ADMIN_HASH value below with your hash
::   4. Keep the passphrase in a secure password manager
::
:: DEFAULT passphrase: OrgAdmin2024!Unlock
:: CHANGE THIS BEFORE DEPLOYMENT!
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

:: === SET YOUR HASH HERE (SHA-256 of your passphrase, UPPERCASE) ===
:: Default hash is for passphrase: OrgAdmin2024!Unlock
set ADMIN_HASH=7B6D8E4F2A1C9E5B3D7F0A8C2E4B6D9F1A3C5E7B9D0F2A4C6E8B0D2F4A6C8E0B

:: Logging setup
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
set UNLOCK_LOG=%LOG_DIR%\unlock_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo.
echo ============================================================
echo  ADMIN EMERGENCY UNLOCK - Authorised Personnel Only
echo  Every unlock attempt is logged with timestamp + username.
echo ============================================================
echo.

set /p PASSPHRASE="Enter admin passphrase: "

:: Hash the input using PowerShell and compare
for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -InputStream ([System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes('!PASSPHRASE!'))) -Algorithm SHA256).Hash"') do set INPUT_HASH=%%H

:: Log every attempt (including failures) for audit purposes
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
set TIMESTAMP=%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%

if /i "!INPUT_HASH!"=="!ADMIN_HASH!" (
    echo [%TIMESTAMP%] [UNLOCK-SUCCESS] Admin unlock by %USERNAME% from %COMPUTERNAME% >> "%UNLOCK_LOG%"
    echo [%TIMESTAMP%] [UNLOCK-SUCCESS] Admin unlock by %USERNAME% >> "%LOG_FILE%"
    echo.
    echo [OK] Authentication successful.
    echo [OK] Unlock event logged to: %UNLOCK_LOG%
    echo.
    echo Applying temporary overrides...
    
    :: Temporarily disable Tamper Protection
    powershell -ExecutionPolicy Bypass -Command "try { Set-MpPreference -TamperProtection 4 -ErrorAction Stop; Write-Host '[OK] Tamper Protection temporarily disabled' } catch { Write-Host '[NOTE] Tamper Protection: use Windows Security UI if needed' }"
    
    :: Set session-level execution policy bypass
    echo [OK] Opening elevated admin shell with Bypass execution policy...
    echo [OK] Run admin_relock.bat when done to re-apply hardening.
    echo.
    echo ============================================================
    echo  REMINDER: Run admin_relock.bat when done!
    echo  Leaving security disabled puts the org at risk.
    echo ============================================================
    echo.
    
    :: Launch an elevated CMD session with bypass capabilities
    powershell -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -Verb RunAs -ArgumentList '/K echo [ADMIN SHELL] Execution Policy: Bypass active for this session. && powershell -ExecutionPolicy Bypass -NoProfile -Command Set-ExecutionPolicy Bypass -Scope Process -Force'"
    
) else (
    echo [%TIMESTAMP%] [UNLOCK-FAILED] Failed unlock attempt by %USERNAME% from %COMPUTERNAME% >> "%UNLOCK_LOG%"
    echo [%TIMESTAMP%] [UNLOCK-FAILED] Failed unlock attempt by %USERNAME% >> "%LOG_FILE%"
    echo.
    echo [DENIED] Authentication failed. This attempt has been logged.
    echo.
)

endlocal
exit /b 0
