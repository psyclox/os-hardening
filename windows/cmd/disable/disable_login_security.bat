@echo off
setlocal enabledelayedexpansion
:: Disable Login Security - Remove CAD requirement, restore defaults
:: Must be run as Administrator

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
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [DISABLE] Login Security disabled by %USERNAME% >> "%LOG_FILE%"

echo Disabling Login Security (restoring defaults)...

echo [1/2] Removing CAD requirement...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableCAD /t REG_DWORD /d 1 /f >nul 2>&1

echo [2/2] Ensuring username display is on (should already be, confirming)...
:: Value 0 = SHOW username - this is both the default and what enable sets
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v dontdisplaylastusername /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo [OK] Login Security Disabled (CAD requirement removed)
echo [OK] Log written to: %LOG_FILE%
endlocal
exit /b 0
