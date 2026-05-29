#Requires -RunAsAdministrator
# Enable Office Security - Disable Macros and ActiveX (HKLM + HKCU, multi-version)
# Version 2.0 - Uses HKLM Group Policy paths (employees cannot override)
#               Covers Office 2013 (15.0) and 2016/2019/365 (16.0)

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [ENABLE] Office Security applied by $env:USERNAME"

$officeVersions = @("15.0", "16.0")
$appsForMacros  = @("Excel", "Word", "PowerPoint", "Outlook", "Access")
$appsForActiveX = @("Excel", "Word", "PowerPoint")

Write-Host "[1/4] Disabling VBA Macros via HKCU (user-level)..." -ForegroundColor Cyan
foreach ($ver in $officeVersions) {
    foreach ($app in $appsForMacros) {
        $path = "HKCU:\Software\Microsoft\Office\$ver\$app\Security"
        New-Item -Path $path -Force | Out-Null
        # VBAWarnings=4 = Disable all macros without notification (most restrictive)
        Set-ItemProperty -Path $path -Name "VBAWarnings" -Value 4 -Type DWord -Force
    }
}

Write-Host "[2/4] Locking VBA Macros via HKLM Group Policy (employees cannot override)..." -ForegroundColor Cyan
foreach ($ver in $officeVersions) {
    foreach ($app in $appsForMacros) {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\$ver\$($app.ToLower())\Security"
        New-Item -Path $path -Force | Out-Null
        Set-ItemProperty -Path $path -Name "VBAWarnings" -Value 4 -Type DWord -Force
    }
}

Write-Host "[3/4] Disabling ActiveX via HKCU..." -ForegroundColor Cyan
foreach ($ver in $officeVersions) {
    foreach ($app in $appsForActiveX) {
        $path = "HKCU:\Software\Microsoft\Office\$ver\$app\Security"
        New-Item -Path $path -Force | Out-Null
        Set-ItemProperty -Path $path -Name "DisableActiveX" -Value 1 -Type DWord -Force
    }
}

Write-Host "[4/4] Locking ActiveX via HKLM Group Policy (employees cannot override)..." -ForegroundColor Cyan
foreach ($ver in $officeVersions) {
    foreach ($app in $appsForActiveX) {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\$ver\$($app.ToLower())\Security"
        New-Item -Path $path -Force | Out-Null
        Set-ItemProperty -Path $path -Name "DisableActiveX" -Value 1 -Type DWord -Force
    }
}

Write-Host ""
Write-Host "[OK] Office Security Enabled (Macros and ActiveX disabled)" -ForegroundColor Green
Write-Host "[OK] HKLM Group Policy locks prevent employee overrides" -ForegroundColor Green
Write-Host "[OK] Covers Office 2013 (15.0) and 2016/2019/365 (16.0)" -ForegroundColor Green
Write-Host "[OK] Log written to: $LogFile" -ForegroundColor Green

