@echo off
setlocal enabledelayedexpansion
:: Enable Office Security - Disable Macros and ActiveX (HKLM + HKCU, multi-version)
:: Must be run as Administrator
:: Version 2.0 - Fixed: now uses HKLM Group Policy paths (employees cannot override)
::               Covers Office 2013 (15.0) and 2016/2019/365 (16.0)

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
echo [%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%] [ENABLE] Office Security applied by %USERNAME% >> "%LOG_FILE%"

echo [1/4] Disabling VBA Macros via HKCU (user-level settings)...
for %%v in (15.0 16.0) do (
    for %%a in (Excel Word PowerPoint Outlook Access) do (
        reg add "HKCU\Software\Microsoft\Office\%%v\%%a\Security" /v VBAWarnings /t REG_DWORD /d 4 /f >nul 2>&1
    )
)

echo [2/4] Locking VBA Macros via HKLM Group Policy (employees cannot override)...
:: VBAWarnings=4 disables all macros without notification (most restrictive)
for %%v in (15.0 16.0) do (
    for %%a in (excel word powerpoint outlook access) do (
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\%%v\%%a\Security" /v VBAWarnings /t REG_DWORD /d 4 /f >nul 2>&1
    )
)

echo [3/4] Disabling ActiveX via HKCU...
for %%v in (15.0 16.0) do (
    for %%a in (Excel Word PowerPoint) do (
        reg add "HKCU\Software\Microsoft\Office\%%v\%%a\Security" /v DisableActiveX /t REG_DWORD /d 1 /f >nul 2>&1
    )
)

echo [4/4] Locking ActiveX via HKLM Group Policy (employees cannot override)...
for %%v in (15.0 16.0) do (
    for %%a in (excel word powerpoint) do (
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\%%v\%%a\Security" /v DisableActiveX /t REG_DWORD /d 1 /f >nul 2>&1
    )
)

echo.
echo [OK] Office Security Enabled (Macros and ActiveX disabled)
echo [OK] HKLM Group Policy locks prevent employee overrides
echo [OK] Covers Office 2013 (15.0) and 2016/2019/365 (16.0)
echo [OK] Log written to: %LOG_FILE%
endlocal
exit /b 0
