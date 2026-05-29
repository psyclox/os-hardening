@echo off
:: ==============================================================
::  APPLY SECEDIT SECURITY BASELINE
::  IT Organization — OS Hardening Suite
:: ==============================================================
::  Purpose : Apply security_baseline.inf via secedit
::  Run As  : Local Administrator
::  Usage   : apply_secedit_template.bat
:: ==============================================================

title IT SECURITY - Secedit Baseline Enforcer
setlocal EnableDelayedExpansion

:: Elevation Check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [ERROR] Must be run as Administrator.
    pause
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
set "INF_FILE=%SCRIPT_DIR%security_baseline.inf"
set "DB_FILE=%TEMP%\security_baseline.sdb"
set "LOG_FILE=%SCRIPT_DIR%secedit_log_%DATE:~-4,4%%DATE:~-7,2%%DATE:~-10,2%.log"

echo.
echo  ============================================================
echo   IT ORGANIZATION — SECEDIT SECURITY BASELINE ENFORCEMENT
echo  ============================================================
echo   INF Template : %INF_FILE%
echo   Database     : %DB_FILE%
echo   Log File     : %LOG_FILE%
echo  ============================================================
echo.

if not exist "%INF_FILE%" (
    echo  [ERROR] Security template not found: %INF_FILE%
    echo  Ensure security_baseline.inf is in the same directory.
    pause
    exit /b 1
)

echo  [INFO] Applying security baseline via secedit...
echo.

:: Apply the security template
secedit /configure /db "%DB_FILE%" /cfg "%INF_FILE%" /log "%LOG_FILE%" /quiet

if %errorLevel% equ 0 (
    echo  [OK]   Security baseline applied successfully.
    echo  [INFO] Log: %LOG_FILE%
) else (
    echo  [WARN] Secedit completed with warnings. Check log: %LOG_FILE%
)

echo.
echo  [INFO] Refreshing group policy...
gpupdate /force /quiet

echo.
echo  ============================================================
echo  [OK]  Secedit baseline and policy refresh complete.
echo  ============================================================
echo.
echo  IMPORTANT: A REBOOT may be required for all settings to apply.
echo.
pause
endlocal
