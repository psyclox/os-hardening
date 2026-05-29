<# ==============================================================
   LINK GPO TO OU
   ==============================================================
   Purpose  : Link an existing GPO to an Active Directory OU
   Run As   : Domain Administrator
   Usage    : .\link_gpo_to_ou.ps1 -GPOName "IT-SEC-Firewall-Enforcement" `
                                    -OUPath "OU=Workstations,DC=company,DC=local" `
                                    -LinkOrder 1 -Enforced
   ==============================================================
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$GPOName,

    [Parameter(Mandatory=$true)]
    [string]$OUPath,

    [int]$LinkOrder = 1,
    [switch]$Enforced,
    [switch]$Disable
)

#Requires -RunAsAdministrator
#Requires -Modules GroupPolicy

Write-Host ""
Write-Host "  [GPO LINK]" -ForegroundColor Cyan
Write-Host "  GPO      : $GPOName" -ForegroundColor White
Write-Host "  OU Path  : $OUPath" -ForegroundColor White
Write-Host "  Order    : $LinkOrder | Enforced: $Enforced" -ForegroundColor White

# Check GPO exists
$gpo = Get-GPO -Name $GPOName -ErrorAction SilentlyContinue
if (-not $gpo) {
    Write-Host "  [ERROR] GPO '$GPOName' does not exist in the domain." -ForegroundColor Red
    Write-Host "  Run import_gpo_backup.ps1 first to create it." -ForegroundColor Yellow
    exit 1
}

try {
    # Check if already linked
    $existing = Get-GPInheritance -Target $OUPath | Select-Object -ExpandProperty GpoLinks |
                Where-Object { $_.DisplayName -eq $GPOName }

    if ($existing) {
        Write-Host "  [INFO] Link exists. Updating settings..." -ForegroundColor Yellow
        Set-GPLink -Name $GPOName -Target $OUPath `
                   -Enforced $(if ($Enforced) {"Yes"} else {"No"}) `
                   -LinkEnabled $(if ($Disable) {"No"} else {"Yes"}) `
                   -Order $LinkOrder | Out-Null
        Write-Host "  [OK] Link updated." -ForegroundColor Green
    } else {
        New-GPLink -Name $GPOName -Target $OUPath `
                   -Enforced $(if ($Enforced) {"Yes"} else {"No"}) `
                   -LinkEnabled $(if ($Disable) {"No"} else {"Yes"}) `
                   -Order $LinkOrder | Out-Null
        Write-Host "  [OK] Link created." -ForegroundColor Green
    }
} catch {
    Write-Host "  [ERROR] Failed to link GPO: $_" -ForegroundColor Red
    exit 1
}
