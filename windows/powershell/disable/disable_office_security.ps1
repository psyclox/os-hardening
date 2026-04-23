#Requires -RunAsAdministrator
# Disable Office Security - Enable Macros and ActiveX (NOT RECOMMENDED)

Write-Host "[WARNING] Enabling macros increases malware risk!" -ForegroundColor Red
$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne "Y") { exit }

Write-Host "[1/2] Enabling VBA Macros in Office..." -ForegroundColor Yellow
$officeApps = @("Excel", "Word", "PowerPoint", "Outlook")
foreach ($app in $officeApps) {
    $path = "HKCU:\Software\Microsoft\Office\16.0\$app\Security"
    New-Item -Path $path -Force | Out-Null
    Set-ItemProperty -Path $path -Name "VBAWarnings" -Value 1 -Type DWord -Force
}

Write-Host "[2/2] Enabling ActiveX in Office..." -ForegroundColor Yellow
foreach ($app in @("Excel", "Word")) {
    $path = "HKCU:\Software\Microsoft\Office\16.0\$app\Security"
    Set-ItemProperty -Path $path -Name "DisableActiveX" -Value 0 -Type DWord -Force
}

Write-Host "[OK] Office Security Disabled - Macros and ActiveX enabled" -ForegroundColor Red
Read-Host "Press Enter to continue"
