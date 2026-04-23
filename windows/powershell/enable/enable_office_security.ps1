#Requires -RunAsAdministrator
# Enable Office Security - Disable Macros and ActiveX

Write-Host "[1/2] Disabling VBA Macros in Office..." -ForegroundColor Cyan
$officeApps = @("Excel", "Word", "PowerPoint", "Outlook")
foreach ($app in $officeApps) {
    $path = "HKCU:\Software\Microsoft\Office\16.0\$app\Security"
    New-Item -Path $path -Force | Out-Null
    Set-ItemProperty -Path $path -Name "VBAWarnings" -Value 2 -Type DWord -Force
}

Write-Host "[2/2] Disabling ActiveX in Office..." -ForegroundColor Cyan
foreach ($app in @("Excel", "Word")) {
    $path = "HKCU:\Software\Microsoft\Office\16.0\$app\Security"
    Set-ItemProperty -Path $path -Name "DisableActiveX" -Value 1 -Type DWord -Force
}

Write-Host "[OK] Office Security Enabled (Macros and ActiveX disabled)" -ForegroundColor Green
Read-Host "Press Enter to continue"
