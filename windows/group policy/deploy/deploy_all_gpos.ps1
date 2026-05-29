<# ==============================================================
   DEPLOY ALL GROUP POLICY OBJECTS - IT Organization Suite
   ==============================================================
   Purpose  : Import and link all GPO backups to an Active Directory OU
   Run As   : Domain Administrator on a Domain Controller
   Usage    : .\deploy_all_gpos.ps1 -OUPath "OU=Workstations,DC=company,DC=local"
   Requires : ActiveDirectory RSAT, GroupPolicy module
   ==============================================================
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OUPath,

    [Parameter(Mandatory = $false)]
    [string]$GPOBackupRoot = "$PSScriptRoot\..\gpo_policies",

    [Parameter(Mandatory = $false)]
    [string]$Domain = $env:USERDNSDOMAIN,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

#Requires -RunAsAdministrator
#Requires -Modules GroupPolicy, ActiveDirectory

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Banner ───────────────────────────────────────────────────────────────────
function Write-Banner {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "   GROUP POLICY DEPLOYMENT - IT ORGANIZATION SECURITY SUITE" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Domain      : $Domain" -ForegroundColor Yellow
    Write-Host "  Target OU   : $OUPath" -ForegroundColor Yellow
    Write-Host "  GPO Root    : $GPOBackupRoot" -ForegroundColor Yellow
    Write-Host "  Mode        : $(if ($WhatIf) { 'SIMULATION (WhatIf)' } else { 'LIVE DEPLOYMENT' })" -ForegroundColor $(if ($WhatIf) { 'Magenta' } else { 'Green' })
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

# ─── Logging ──────────────────────────────────────────────────────────────────
$LogFile = "$PSScriptRoot\deploy_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logEntry
    $color = switch ($Level) {
        "INFO"    { "White" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host $logEntry -ForegroundColor $color
}

# ─── GPO Definition Table ─────────────────────────────────────────────────────
# Each entry: BackupFolderName, GPODisplayName, LinkOrder, Enforced, Enabled
$GPODefinitions = @(
    @{ Folder = "GPO_Firewall_Enforcement";   Name = "IT-SEC-Firewall-Enforcement";    LinkOrder = 1;  Enforced = $true;  Enabled = $true }
    @{ Folder = "GPO_Defender_Enforcement";   Name = "IT-SEC-Defender-Enforcement";    LinkOrder = 2;  Enforced = $true;  Enabled = $true }
    @{ Folder = "GPO_User_Rights";            Name = "IT-SEC-User-Rights-Assignment";  LinkOrder = 3;  Enforced = $true;  Enabled = $true }
    @{ Folder = "GPO_Password_Policy";        Name = "IT-SEC-Password-Policy";         LinkOrder = 4;  Enforced = $true;  Enabled = $true }
    @{ Folder = "GPO_USB_Control";            Name = "IT-SEC-USB-Removable-Control";   LinkOrder = 5;  Enforced = $true;  Enabled = $true }
    @{ Folder = "GPO_Software_Restriction";   Name = "IT-SEC-Software-Restriction";    LinkOrder = 6;  Enforced = $false; Enabled = $true }
    @{ Folder = "GPO_Audit_Policy";           Name = "IT-SEC-Audit-Logging-Policy";    LinkOrder = 7;  Enforced = $true;  Enabled = $true }
    @{ Folder = "GPO_Screen_Lock";            Name = "IT-SEC-Screen-Lock-Policy";      LinkOrder = 8;  Enforced = $false; Enabled = $true }
)

# ─── Prerequisite Check ───────────────────────────────────────────────────────
function Test-Prerequisites {
    Write-Log "Checking prerequisites..."

    # Check domain connectivity
    try {
        $domainObj = Get-ADDomain -Identity $Domain
        Write-Log "Domain '$($domainObj.DNSRoot)' reachable." "SUCCESS"
    } catch {
        Write-Log "Cannot reach domain '$Domain'. Aborting." "ERROR"
        throw
    }

    # Check OU existence
    try {
        $null = Get-ADOrganizationalUnit -Identity $OUPath
        Write-Log "Target OU '$OUPath' verified." "SUCCESS"
    } catch {
        Write-Log "OU '$OUPath' does not exist. Please create it first." "ERROR"
        throw
    }

    # Check GPO backup root
    if (-not (Test-Path $GPOBackupRoot)) {
        Write-Log "GPO backup root '$GPOBackupRoot' not found." "ERROR"
        throw "Backup root missing."
    }
    Write-Log "GPO backup root found." "SUCCESS"
}

# ─── Import Single GPO ────────────────────────────────────────────────────────
function Import-GPOFromBackup {
    param([hashtable]$GPODef)

    $backupPath = Join-Path $GPOBackupRoot $GPODef.Folder
    if (-not (Test-Path $backupPath)) {
        Write-Log "Backup folder not found: '$backupPath'. Skipping '$($GPODef.Name)'." "WARNING"
        return $null
    }

    # Check if GPO already exists
    $existingGPO = Get-GPO -Name $GPODef.Name -ErrorAction SilentlyContinue
    if ($existingGPO) {
        Write-Log "GPO '$($GPODef.Name)' already exists. Updating settings via import..." "WARNING"
        if (-not $WhatIf) {
            Import-GPO -BackupGpoName $GPODef.Name -Path $backupPath -TargetName $GPODef.Name -CreateIfNeeded | Out-Null
        }
    } else {
        Write-Log "Creating new GPO: '$($GPODef.Name)'..." "INFO"
        if (-not $WhatIf) {
            $newGPO = New-GPO -Name $GPODef.Name -Domain $Domain
            Import-GPO -BackupGpoName $GPODef.Name -Path $backupPath -TargetName $GPODef.Name -CreateIfNeeded | Out-Null
        }
    }
    Write-Log "GPO '$($GPODef.Name)' imported successfully." "SUCCESS"
    return $GPODef.Name
}

# ─── Link GPO to OU ───────────────────────────────────────────────────────────
function Set-GPOLink {
    param([hashtable]$GPODef)

    Write-Log "Linking '$($GPODef.Name)' to '$OUPath' (Order: $($GPODef.LinkOrder), Enforced: $($GPODef.Enforced))..."

    if (-not $WhatIf) {
        $link = Get-GPInheritance -Target $OUPath | Select-Object -ExpandProperty GpoLinks |
                Where-Object { $_.DisplayName -eq $GPODef.Name }

        if ($link) {
            Set-GPLink -Name $GPODef.Name -Target $OUPath `
                       -Enforced $(if ($GPODef.Enforced) { "Yes" } else { "No" }) `
                       -LinkEnabled $(if ($GPODef.Enabled) { "Yes" } else { "No" }) `
                       -Order $GPODef.LinkOrder | Out-Null
            Write-Log "Link updated for '$($GPODef.Name)'." "SUCCESS"
        } else {
            New-GPLink -Name $GPODef.Name -Target $OUPath `
                       -Enforced $(if ($GPODef.Enforced) { "Yes" } else { "No" }) `
                       -LinkEnabled $(if ($GPODef.Enabled) { "Yes" } else { "No" }) `
                       -Order $GPODef.LinkOrder | Out-Null
            Write-Log "Link created for '$($GPODef.Name)'." "SUCCESS"
        }
    } else {
        Write-Log "[WHATIF] Would link '$($GPODef.Name)' to '$OUPath'." "INFO"
    }
}

# ─── Main Execution ───────────────────────────────────────────────────────────
Write-Banner
Write-Log "=== GPO Deployment Started ===" "INFO"

try {
    Test-Prerequisites

    $successCount = 0
    $failCount = 0

    foreach ($gpoDef in $GPODefinitions) {
        Write-Log "--- Processing: $($gpoDef.Name) ---" "INFO"
        try {
            $imported = Import-GPOFromBackup -GPODef $gpoDef
            if ($imported) {
                Set-GPOLink -GPODef $gpoDef
                $successCount++
            } else {
                $failCount++
            }
        } catch {
            Write-Log "FAILED processing '$($gpoDef.Name)': $_" "ERROR"
            $failCount++
        }
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "   DEPLOYMENT SUMMARY" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Log "GPOs Deployed Successfully : $successCount" "SUCCESS"
    if ($failCount -gt 0) {
        Write-Log "GPOs Failed / Skipped      : $failCount" "WARNING"
    }
    Write-Log "Log File                   : $LogFile" "INFO"
    Write-Host "============================================================" -ForegroundColor Cyan

    if (-not $WhatIf) {
        Write-Host ""
        Write-Host "Run 'gpupdate /force' on target machines or wait for GP refresh." -ForegroundColor Yellow
    }

} catch {
    Write-Log "CRITICAL DEPLOYMENT FAILURE: $_" "ERROR"
    exit 1
}
