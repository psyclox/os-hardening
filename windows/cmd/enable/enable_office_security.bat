@echo off
:: Enable Office Security - Disable Macros and ActiveX
:: Must be run as Administrator

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Run as Administrator
    pause
    exit /b 1
)

echo [1/2] Disabling VBA Macros in Office...
reg add "HKCU\Software\Microsoft\Office\16.0\Excel\Security" /v VBAWarnings /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Security" /v VBAWarnings /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Office\16.0\PowerPoint\Security" /v VBAWarnings /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Office\16.0\Outlook\Security" /v VBAWarnings /t REG_DWORD /d 2 /f >nul 2>&1

echo [2/2] Disabling ActiveX in Office...
reg add "HKCU\Software\Microsoft\Office\16.0\Excel\Security" /v DisableActiveX /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Security" /v DisableActiveX /t REG_DWORD /d 1 /f >nul 2>&1

echo [OK] Office Security Enabled (Macros and ActiveX disabled)
pause
exit /b 0
