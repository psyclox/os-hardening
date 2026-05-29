#Requires -RunAsAdministrator
# Disable Office Security - Enable Macros and ActiveX (NOT RECOMMENDED)
# Version 2.0 - CONFIRM prompt + HKLM GP cleanup + multi-version + logging

Write-Host ""
Write-Host "============================================================" -ForegroundColor Red
Write-Host " [WARNING] Re-enabling Office Macros increases malware risk!" -ForegroundColor Red
Write-Host " Macro viruses and ransomware commonly use Office macros."    -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Red
Write-Host ""
$confirm = Read-Host "Type CONFIRM to proceed (anything else cancels)"
if ($confirm -ne "CONFIRM") {
    Write-Host "[CANCELLED] No changes made." -ForegroundColor Green
    exit
}

# Logging
$LogDir  = "C:\ProgramData\OrgSecurity"
$LogFile = "$LogDir\security_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$Stamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
Add-Content -Path $LogFile -Value "[$Stamp] [DISABLE] Office Security DISABLED by $env:USERNAME"

$officeVersions = @("15.0", "16.0")
$appsForMacros  = @("Excel", "Word", "PowerPoint", "Outlook", "Access")
$appsForActiveX = @("Excel", "Word", "PowerPoint")

Write-Host "[1/4] Restoring VBA Macros via HKCU (VBAWarnings=2 = prompt user)..." -ForegroundColor Yellow
foreach ($ver in $officeVersions) {
    foreach ($app in $appsForMacros) {
        $path = "HKCU:\Software\Microsoft\Office\$ver\$app\Security"
        New-Item -Path $path -Force | Out-Null
        Set-ItemProperty -Path $path -Name "VBAWarnings" -Value 2 -Type DWord -Force
    }
}

Write-Host "[2/4] Removing HKLM Group Policy Macro locks..." -ForegroundColor Yellow
foreach ($ver in $officeVersions) {
    foreach ($app in $appsForMacros) {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\$ver\$($app.ToLower())\Security"
        if (Test-Path $path) { Remove-ItemProperty -Path $path -Name "VBAWarnings" -Force -ErrorAction SilentlyContinue }
    }
}

Write-Host "[3/4] Restoring ActiveX via HKCU..." -ForegroundColor Yellow
foreach ($ver in $officeVersions) {
    foreach ($app in $appsForActiveX) {
        $path = "HKCU:\Software\Microsoft\Office\$ver\$app\Security"
        New-Item -Path $path -Force | Out-Null
        Set-ItemProperty -Path $path -Name "DisableActiveX" -Value 0 -Type DWord -Force
    }
}

Write-Host "[4/4] Removing HKLM Group Policy ActiveX locks..." -ForegroundColor Yellow
foreach ($ver in $officeVersions) {
    foreach ($app in $appsForActiveX) {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\$ver\$($app.ToLower())\Security"
        if (Test-Path $path) { Remove-ItemProperty -Path $path -Name "DisableActiveX" -Force -ErrorAction SilentlyContinue }
    }
}

Write-Host ""
Write-Host "[OK] Office Security Disabled - Macros and ActiveX enabled" -ForegroundColor Red
Write-Host "[WARN] System is now vulnerable to macro-based malware!" -ForegroundColor Red
Write-Host "[OK] Log written to: $LogFile" -ForegroundColor Green

