@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: ADMIN RELOCK - Re-apply all security hardening instantly
:: Run this after admin_emergency_unlock.bat work is complete
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

:: Logging
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
set UNLOCK_LOG=%LOG_DIR%\unlock_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
set TIMESTAMP=%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%

echo [%TIMESTAMP%] [RELOCK] Security re-applied by %USERNAME% after admin unlock >> "%LOG_FILE%"
echo [%TIMESTAMP%] [RELOCK] System relocked by %USERNAME% >> "%UNLOCK_LOG%"

echo.
echo ============================================================
echo  ADMIN RELOCK - Re-applying all security hardening
echo ============================================================
echo.

call "%~dp0apply_all_security.bat"

echo.
echo ============================================================
echo  [OK] System is fully re-hardened
echo  [OK] Relock event logged
echo  [WARN] Reboot recommended for all changes to fully activate
echo ============================================================
pause
endlocal
exit /b 0
