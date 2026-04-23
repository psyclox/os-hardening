@echo off
:: Disable Office Security - Enable Macros and ActiveX (NOT RECOMMENDED)
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo [WARNING] Enabling macros increases malware risk!
set /p confirm="Continue? (Y/N): "
if /i not "!confirm!"=="Y" exit /b 0

echo [1/2] Enabling VBA Macros in Office...
reg add "HKCU\Software\Microsoft\Office\16.0\Excel\Security" /v VBAWarnings /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Security" /v VBAWarnings /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Office\16.0\PowerPoint\Security" /v VBAWarnings /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Office\16.0\Outlook\Security" /v VBAWarnings /t REG_DWORD /d 1 /f >nul 2>&1

echo [2/2] Enabling ActiveX in Office...
reg add "HKCU\Software\Microsoft\Office\16.0\Excel\Security" /v DisableActiveX /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Security" /v DisableActiveX /t REG_DWORD /d 0 /f >nul 2>&1

echo [OK] Office Security Disabled - Macros and ActiveX enabled
pause
exit /b 0
