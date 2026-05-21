@echo off
setlocal enabledelayedexpansion
:: Disable Office Security - Enable Macros and ActiveX (NOT RECOMMENDED)
:: Must be run as Administrator
:: Version 2.0 - Fixed confirmation bug + HKLM GP cleanup + logging

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  [WARNING] Re-enabling Office Macros increases malware risk!
echo  Macro viruses and ransomware commonly use Office macros.
echo  ONLY run this if specifically required for business.
echo ============================================================
echo.
set /p confirm="Type CONFIRM to proceed (anything else cancels): "
if /i not "!confirm!"=="CONFIRM" (
    echo [CANCELLED] No changes made.
    pause
    exit /b 0
)

:: Logging setup
set LOG_DIR=C:\ProgramData\OrgSecurity
set LOG_FILE=%LOG_DIR%\security_log.txt
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-2 delims= " %%a in ('wmic os get LocalDateTime /value ^| find "="') do set DT=%%b
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [DISABLE] Office Security DISABLED by %USERNAME% >> "%LOG_FILE%"

echo [1/4] Restoring VBA Macros via HKCU (VBAWarnings=2 = prompt)...
for %%v in (15.0 16.0) do (
    for %%a in (Excel Word PowerPoint Outlook Access) do (
        reg add "HKCU\Software\Microsoft\Office\%%v\%%a\Security" /v VBAWarnings /t REG_DWORD /d 2 /f >nul 2>&1
    )
)

echo [2/4] Removing HKLM Group Policy Macro locks...
for %%v in (15.0 16.0) do (
    for %%a in (excel word powerpoint outlook access) do (
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\%%v\%%a\Security" /v VBAWarnings /f >nul 2>&1
    )
)

echo [3/4] Restoring ActiveX via HKCU...
for %%v in (15.0 16.0) do (
    for %%a in (Excel Word PowerPoint) do (
        reg add "HKCU\Software\Microsoft\Office\%%v\%%a\Security" /v DisableActiveX /t REG_DWORD /d 0 /f >nul 2>&1
    )
)

echo [4/4] Removing HKLM Group Policy ActiveX locks...
for %%v in (15.0 16.0) do (
    for %%a in (excel word powerpoint) do (
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\%%v\%%a\Security" /v DisableActiveX /f >nul 2>&1
    )
)

echo.
echo [OK] Office Security Disabled - Macros and ActiveX enabled
echo [WARN] System is now vulnerable to macro-based malware!
echo [OK] Log written to: %LOG_FILE%
pause
endlocal
exit /b 0
