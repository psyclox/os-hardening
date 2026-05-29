@echo off
:: ==============================================================
::  APPLY LOCAL SECURITY POLICY (CMD WRAPPER)
::  IT Organization - OS Hardening Suite
:: ==============================================================
::  Purpose : Launches the PowerShell local security policy
::            script with proper elevation check
::  Run As  : Administrator
:: ==============================================================

title IT SECURITY - Local Policy Enforcer

:: ─── Elevation Check ──────────────────────────────────────────
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [ERROR] This script must be run as Administrator.
    echo  Right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo  ============================================================
echo   IT ORGANIZATION - LOCAL SECURITY POLICY ENFORCEMENT
echo   CIS Benchmark / NIST 800-53 / ISO 27001 Compliant
echo  ============================================================
echo.
echo  [INFO] Machine  : %COMPUTERNAME%
echo  [INFO] User     : %USERNAME%
echo  [INFO] Domain   : %USERDOMAIN%
echo  [INFO] Date     : %DATE% %TIME%
echo.
echo  [WARN] This will apply mandatory security restrictions.
echo  [WARN] Some features will be restricted for standard users.
echo.
set /p CONFIRM="  Proceed with policy enforcement? (Y/N): "
if /i "%CONFIRM%" neq "Y" (
    echo  [INFO] Operation cancelled by user.
    exit /b 0
)

echo.
echo  [INFO] Launching PowerShell policy enforcement...
echo.

:: ─── Execute PowerShell Script ────────────────────────────────
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0apply_local_security_policy.ps1"

if %errorLevel% equ 0 (
    echo.
    echo  ============================================================
    echo  [OK] Security policy applied successfully.
    echo  ============================================================
) else (
    echo.
    echo  ============================================================
    echo  [ERROR] Policy application encountered errors. Check logs.
    echo  ============================================================
)

echo.
pause
