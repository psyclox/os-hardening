<# ==============================================================
   VERIFY GPO APPLICATION
   ==============================================================
   Purpose  : Verify that GPOs are applied on local or remote
              machines using gpresult
   Run As   : Administrator
   Usage    : .\verify_gpo_application.ps1
              .\verify_gpo_application.ps1 -ComputerName PC001
              .\verify_gpo_application.ps1 -ComputerName PC001 -ExportHTML
   ==============================================================
#>

[CmdletBinding()]
param(
    [string]$ComputerName = $env:COMPUTERNAME,
    [string]$UserName = "",
    [switch]$ExportHTML
)

#Requires -RunAsAdministrator

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║      GPO APPLICATION VERIFIER — IT ORGANIZATION         ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Target Machine : $ComputerName" -ForegroundColor Yellow
Write-Host ""

$reportDir = "$PSScriptRoot\verification_reports"
if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }

# ─── Run gpresult ─────────────────────────────────────────────
if ($ExportHTML) {
    $reportFile = "$reportDir\gpresult_${ComputerName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    Write-Host "  Generating HTML report via gpresult..." -ForegroundColor White

    $gpArgs = "/H `"$reportFile`" /SCOPE COMPUTER /F"
    if ($ComputerName -ne $env:COMPUTERNAME) { $gpArgs = "/S $ComputerName $gpArgs" }
    if ($UserName) { $gpArgs += " /USER $UserName" }

    $proc = Start-Process -FilePath "gpresult.exe" -ArgumentList $gpArgs -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -eq 0 -and (Test-Path $reportFile)) {
        Write-Host "  [OK] Report saved: $reportFile" -ForegroundColor Green
        Start-Process $reportFile
    } else {
        Write-Host "  [ERROR] gpresult failed with exit code: $($proc.ExitCode)" -ForegroundColor Red
    }
} else {
    # Text summary
    Write-Host "  Applied GPOs (Computer Scope):" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor Gray

    $gpArgs = "/SCOPE COMPUTER /R"
    if ($ComputerName -ne $env:COMPUTERNAME) { $gpArgs = "/S $ComputerName $gpArgs" }

    $output = & gpresult.exe $gpArgs.Split(" ") 2>&1
    $output | Where-Object { $_ -match "GPO:|Applied Group Policy|Result" } | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor Gray

    # Check for our IT Security GPOs
    $expectedGPOs = @(
        "IT-SEC-Firewall-Enforcement",
        "IT-SEC-Defender-Enforcement",
        "IT-SEC-User-Rights-Assignment",
        "IT-SEC-Password-Policy",
        "IT-SEC-USB-Removable-Control",
        "IT-SEC-Software-Restriction",
        "IT-SEC-Audit-Logging-Policy",
        "IT-SEC-Screen-Lock-Policy"
    )

    Write-Host ""
    Write-Host "  Checking IT Security GPO Application:" -ForegroundColor Cyan
    foreach ($gpoName in $expectedGPOs) {
        if ($output -match [regex]::Escape($gpoName)) {
            Write-Host "  [✓] $gpoName" -ForegroundColor Green
        } else {
            Write-Host "  [✗] $gpoName — NOT APPLIED" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "  TIP: Run with -ExportHTML for a full detailed report." -ForegroundColor Gray
Write-Host ""
