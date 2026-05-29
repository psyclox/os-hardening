@echo off
setlocal enabledelayedexpansion
:: Enable Login Security - CAD Required, Username Shown
:: Must be run as Administrator
:: Note: Username display is intentionally kept ON (value 0).
::       The creator removed the hide-username feature because employee
::       usernames are often unknown. Employees can see their username
::       on the lock screen and just type their password as normal.

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
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [ENABLE] Login Security applied by %USERNAME% >> "%LOG_FILE%"

echo [1/2] Requiring Ctrl+Alt+Delete at login...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableCAD /t REG_DWORD /d 0 /f >nul 2>&1

echo [2/2] Keeping username visible on login/lock screen (intentional)...
:: Value 0 = DISPLAY last username (employees can see their own username)
:: The hide-username feature was removed by design — employees don't always
:: know their own login username and should be able to see it.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v dontdisplaylastusername /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo [OK] Login Security Enabled
echo [OK] Ctrl+Alt+Delete required at login
echo [OK] Username is shown on lock screen (by design)
echo [OK] Log written to: %LOG_FILE%
endlocal
exit /b 0
