<# ==============================================================
   IMPORT SINGLE GPO FROM BACKUP
   ==============================================================
   Purpose  : Import a single GPO backup and optionally link it
   Run As   : Domain Administrator
   Usage    : .\import_gpo_backup.ps1 -BackupFolder "GPO_Firewall_Enforcement" `
                                       -GPOName "IT-SEC-Firewall-Enforcement" `
                                       -OUPath "OU=Workstations,DC=company,DC=local"
   ==============================================================
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFolder,

    [Parameter(Mandatory=$true)]
    [string]$GPOName,

    [Parameter(Mandatory=$false)]
    [string]$OUPath = "",

    [Parameter(Mandatory=$false)]
    [string]$BackupRoot = "$PSScriptRoot\..\gpo_policies",

    [switch]$LinkGPO,
    [switch]$Enforced
)

#Requires -RunAsAdministrator
#Requires -Modules GroupPolicy

$backupPath = Join-Path $BackupRoot $BackupFolder

Write-Host ""
Write-Host "  [GPO IMPORT]" -ForegroundColor Cyan
Write-Host "  GPO Name    : $GPOName" -ForegroundColor White
Write-Host "  Backup Path : $backupPath" -ForegroundColor White

if (-not (Test-Path $backupPath)) {
    Write-Host "  [ERROR] Backup folder not found: $backupPath" -ForegroundColor Red
    exit 1
}

try {
    $gpo = Import-GPO -BackupGpoName $GPOName -Path $backupPath `
                      -TargetName $GPOName -CreateIfNeeded -ErrorAction Stop
    Write-Host "  [OK] GPO '$GPOName' imported successfully." -ForegroundColor Green

    if ($LinkGPO -and $OUPath) {
        $link = New-GPLink -Name $GPOName -Target $OUPath `
                           -Enforced $(if ($Enforced) {"Yes"} else {"No"}) `
                           -LinkEnabled "Yes"
        Write-Host "  [OK] GPO linked to '$OUPath'" -ForegroundColor Green
    }
} catch {
    Write-Host "  [ERROR] Import failed: $_" -ForegroundColor Red
    exit 1
}
