<# ==============================================================
   GENERATE GPO REPORT (Domain / AD Environments)
   ==============================================================
   Purpose  : Generate HTML GPO reports from Active Directory
              for all GPOs or linked to a specific OU
   Run As   : Domain Admin / RSAT Tools Required
   Usage    : .\generate_gpo_report.ps1 [-OUPath "OU=..."]
              .\generate_gpo_report.ps1 -AllGPOs
   ==============================================================
#>

[CmdletBinding()]
param(
    [string]$OUPath = "",
    [switch]$AllGPOs,
    [string]$OutputDir = "$PSScriptRoot\gpo_reports_$(Get-Date -Format 'yyyyMMdd')"
)

#Requires -RunAsAdministrator
#Requires -Modules GroupPolicy

Write-Host ""
Write-Host "  GPO REPORT GENERATOR — IT Organization" -ForegroundColor Cyan
Write-Host "  Output: $OutputDir" -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

try {
    if ($AllGPOs) {
        $gpos = Get-GPO -All -Domain $env:USERDNSDOMAIN
        Write-Host "  Found $($gpos.Count) GPOs in domain. Generating reports..." -ForegroundColor White
        foreach ($gpo in $gpos) {
            $safeGpoName = $gpo.DisplayName -replace '[<>:"/\\|?*]', '_'
            $reportPath = "$OutputDir\$safeGpoName.html"
            Get-GPOReport -Name $gpo.DisplayName -ReportType HTML -Path $reportPath
            Write-Host "  [OK] $($gpo.DisplayName)" -ForegroundColor Green
        }
    } elseif ($OUPath) {
        $links = Get-GPInheritance -Target $OUPath | Select-Object -ExpandProperty GpoLinks
        Write-Host "  Found $($links.Count) GPOs linked to '$OUPath'." -ForegroundColor White
        foreach ($link in $links) {
            $safeGpoName = $link.DisplayName -replace '[<>:"/\\|?*]', '_'
            $reportPath = "$OutputDir\$safeGpoName.html"
            Get-GPOReport -Name $link.DisplayName -ReportType HTML -Path $reportPath
            Write-Host "  [OK] $($link.DisplayName)" -ForegroundColor Green
        }
    } else {
        Write-Host "  Use -AllGPOs or -OUPath to specify what to report on." -ForegroundColor Yellow
        exit 0
    }

    # Generate index
    $indexPath = "$OutputDir\index.html"
    $files = Get-ChildItem -Path $OutputDir -Filter "*.html" -Exclude "index.html"
    $links = $files | ForEach-Object { "<li><a href='$($_.Name)'>$([System.IO.Path]::GetFileNameWithoutExtension($_.Name))</a></li>" }
    @"
<!DOCTYPE html>
<html>
<head><title>GPO Reports Index</title>
<style>body{font-family:Segoe UI;background:#1a1a2e;color:#eee;padding:20px}
h1{color:#00d4ff}a{color:#7dd3fc}li{margin:8px 0}</style>
</head>
<body>
<h1>📋 GPO Report Index</h1>
<p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm') | Domain: $env:USERDNSDOMAIN</p>
<ul>$($links -join "`n")</ul>
</body></html>
"@ | Out-File -FilePath $indexPath -Encoding UTF8

    Write-Host ""
    Write-Host "  Reports saved to: $OutputDir" -ForegroundColor Green
    Write-Host "  Opening index..." -ForegroundColor White
    Start-Process $indexPath

} catch {
    Write-Host "  [ERROR] $_ " -ForegroundColor Red
    Write-Host "  Ensure RSAT Group Policy tools are installed and you are a Domain Admin." -ForegroundColor Yellow
}
