<# ==============================================================
   GPO COMPLIANCE CHECK & REPORT
   ==============================================================
   Purpose  : Verify that all security policies are properly
              applied on the current machine and generate
              a compliance report
   Run As   : Administrator
   Usage    : .\gpo_compliance_check.ps1 [-ExportHTML]
   ==============================================================
#>

[CmdletBinding()]
param(
    [switch]$ExportHTML,
    [string]$ReportPath = "$PSScriptRoot\compliance_report_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
)

#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

# ─── Setup ────────────────────────────────────────────────────
$results = @()
$passCount = 0
$failCount = 0
$warnCount = 0

function Add-Result {
    param([string]$Category, [string]$Check, [string]$Status, [string]$Expected, [string]$Actual, [string]$Ref = "")
    $script:results += [PSCustomObject]@{
        Category = $Category
        Check    = $Check
        Status   = $Status
        Expected = $Expected
        Actual   = $Actual
        Reference = $Ref
    }
    switch ($Status) {
        "PASS" { $script:passCount++; $col = "Green" }
        "FAIL" { $script:failCount++; $col = "Red" }
        "WARN" { $script:warnCount++; $col = "Yellow" }
        default{ $col = "White" }
    }
    $statusPad = $Status.PadRight(4)
    Write-Host "  [$statusPad] $Category — $Check" -ForegroundColor $col
}

function Get-RegValue {
    param([string]$Path, [string]$Name)
    try { return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name }
    catch { return $null }
}

function Check-Reg {
    param([string]$Category, [string]$CheckName, [string]$Path, [string]$Name, $Expected, [string]$Ref = "")
    $actual = Get-RegValue -Path $Path -Name $Name
    if ($null -eq $actual) {
        Add-Result $Category $CheckName "WARN" $Expected "NOT SET" $Ref
    } elseif ($actual -eq $Expected) {
        Add-Result $Category $CheckName "PASS" $Expected $actual $Ref
    } else {
        Add-Result $Category $CheckName "FAIL" $Expected $actual $Ref
    }
}

# ─── Banner ───────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║     IT ORGANIZATION — GPO COMPLIANCE CHECKER            ║" -ForegroundColor Cyan
Write-Host "  ║     Machine: $($env:COMPUTERNAME.PadRight(20)) Date: $(Get-Date -Format 'yyyy-MM-dd')   ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ═══════════════════════════════════════════════════════════════
# CHECK 1: WINDOWS FIREWALL
# ═══════════════════════════════════════════════════════════════
Write-Host "  [FIREWALL]" -ForegroundColor Cyan
$fwProfiles = @("DomainProfile", "PrivateProfile", "PublicProfile")
foreach ($profile in $fwProfiles) {
    Check-Reg "Firewall" "Enabled - $profile" `
        "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\$profile" "EnableFirewall" 1 "CIS 9.1"
    Check-Reg "Firewall" "Local Policy Merge Disabled - $profile" `
        "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\$profile" "AllowLocalPolicyMerge" 0 "CIS 9.2"
}

# Check actual firewall state
try {
    $fwStatus = Get-NetFirewallProfile -All -ErrorAction Stop
    foreach ($fw in $fwStatus) {
        $status = if ($fw.Enabled) { "PASS" } else { "FAIL" }
        Add-Result "Firewall" "Profile Active - $($fw.Name)" $status "True" "$($fw.Enabled)" "CIS 9.1"
    }
} catch {
    Add-Result "Firewall" "Firewall Profile Status" "WARN" "Enabled" "Could not check" "CIS 9.1"
}

# ═══════════════════════════════════════════════════════════════
# CHECK 2: WINDOWS DEFENDER
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  [DEFENDER]" -ForegroundColor Cyan
Check-Reg "Defender" "AntiSpyware Not Disabled" `
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" 0 "CIS 18.9"
Check-Reg "Defender" "Real-Time Monitoring" `
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0 "CIS 18.9"
Check-Reg "Defender" "Behavior Monitoring" `
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" 0 "CIS 18.9"
Check-Reg "Defender" "Cloud Protection (MAPS)" `
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting" 2 "CIS 18.9"
Check-Reg "Defender" "PUA Protection" `
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" "MpEnablePus" 1 "CIS 18.9"

# Real-time check
try {
    $mpPref = Get-MpPreference -ErrorAction Stop
    $rtStatus = if (-not $mpPref.DisableRealtimeMonitoring) { "PASS" } else { "FAIL" }
    Add-Result "Defender" "Real-Time Active (MpPreference)" $rtStatus "False" "$($mpPref.DisableRealtimeMonitoring)" "CIS 18.9"
} catch {
    Add-Result "Defender" "Real-Time Active (MpPreference)" "WARN" "Enabled" "Could not check" ""
}

# ═══════════════════════════════════════════════════════════════
# CHECK 3: UAC
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  [UAC]" -ForegroundColor Cyan
$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Check-Reg "UAC" "UAC Enabled (EnableLUA)" $uacPath "EnableLUA" 1 "CIS 2.3.17"
Check-Reg "UAC" "Admin Prompt Behavior" $uacPath "ConsentPromptBehaviorAdmin" 2 "CIS 2.3.17"
Check-Reg "UAC" "User Elevation Denied" $uacPath "ConsentPromptBehaviorUser" 0 "CIS 2.3.17"
Check-Reg "UAC" "Secure Desktop" $uacPath "PromptOnSecureDesktop" 1 "CIS 2.3.17"
Check-Reg "UAC" "CTRL+ALT+DEL Required" $uacPath "DisableCAD" 0 "CIS 2.3.17"

# ═══════════════════════════════════════════════════════════════
# CHECK 4: PASSWORD POLICY
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  [PASSWORD POLICY]" -ForegroundColor Cyan
try {
    $pwPolicy = net accounts 2>&1
    $minLen  = ($pwPolicy | Select-String "Minimum password length").ToString() -replace '\D',''
    $maxAge  = ($pwPolicy | Select-String "Maximum password age").ToString() -replace '[^0-9]',''
    $history = ($pwPolicy | Select-String "Password history").ToString() -replace '[^0-9]',''
    $lockout = ($pwPolicy | Select-String "Lockout threshold").ToString() -replace '[^0-9]',''

    Add-Result "Password" "Min Length >= 14" $(if ([int]$minLen -ge 14) {"PASS"} else {"FAIL"}) ">=14" $minLen "CIS 1.1"
    Add-Result "Password" "Max Age <= 90 days" $(if ([int]$maxAge -le 90) {"PASS"} else {"FAIL"}) "<=90" $maxAge "CIS 1.2"
    Add-Result "Password" "History >= 24" $(if ([int]$history -ge 24) {"PASS"} else {"FAIL"}) ">=24" $history "CIS 1.3"
    Add-Result "Password" "Lockout <= 5 attempts" $(if ([int]$lockout -le 5 -and [int]$lockout -gt 0) {"PASS"} else {"FAIL"}) "<=5" $lockout "CIS 1.4"
} catch {
    Add-Result "Password" "Policy Readable" "WARN" "Accessible" "Failed to read" ""
}

# ═══════════════════════════════════════════════════════════════
# CHECK 5: USB / AUTORUN
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  [USB / REMOVABLE MEDIA]" -ForegroundColor Cyan
Check-Reg "USB" "AutoRun Disabled (255)" `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 255 "CIS 18.8"
Check-Reg "USB" "USB Write Blocked" `
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" "Deny_Write" 1 "CIS 18.8"

# ═══════════════════════════════════════════════════════════════
# CHECK 6: AUDIT POLICY
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  [AUDIT POLICY]" -ForegroundColor Cyan
$auditsToCheck = @(
    "Logon", "Logoff", "Account Lockout", "Special Logon",
    "Credential Validation", "Process Creation",
    "Security State Change", "Audit Policy Change"
)
foreach ($audit in $auditsToCheck) {
    try {
        $res = auditpol /get /subcategory:"$audit" 2>&1 | Select-String $audit
        $setting = if ($res -match "Success and Failure") { "S+F" }
                   elseif ($res -match "Success") { "Success" }
                   elseif ($res -match "Failure") { "Failure" }
                   else { "No Auditing" }
        $status = if ($setting -in @("S+F", "Success")) { "PASS" } else { "FAIL" }
        Add-Result "Audit" "Subcategory: $audit" $status "Enabled" $setting "CIS 17"
    } catch {
        Add-Result "Audit" "Subcategory: $audit" "WARN" "Enabled" "Could not check" "CIS 17"
    }
}

# ═══════════════════════════════════════════════════════════════
# CHECK 7: BITLOCKER
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  [BITLOCKER]" -ForegroundColor Cyan
try {
    $bl = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
    $status = if ($bl.ProtectionStatus -eq "On") { "PASS" } else { "FAIL" }
    Add-Result "BitLocker" "C: Drive Protection" $status "On" "$($bl.ProtectionStatus)" "NIST AC-3"
} catch {
    Add-Result "BitLocker" "C: Drive Protection" "WARN" "On" "Could not check" "NIST AC-3"
}

# ═══════════════════════════════════════════════════════════════
# CHECK 8: SMBv1
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  [PROTOCOL SECURITY]" -ForegroundColor Cyan
try {
    $smb1 = Get-SmbServerConfiguration -ErrorAction Stop | Select-Object -ExpandProperty EnableSMB1Protocol
    Add-Result "Protocol" "SMBv1 Disabled" $(if (-not $smb1) {"PASS"} else {"FAIL"}) "False" "$smb1" "CIS 18.3"
} catch {
    Add-Result "Protocol" "SMBv1 Status" "WARN" "Disabled" "Could not check" "CIS 18.3"
}
Check-Reg "Protocol" "LLMNR Disabled" `
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 0 "CIS 18.5"

# ═══════════════════════════════════════════════════════════════
# SUMMARY REPORT
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  ══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   COMPLIANCE SUMMARY — $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "  ══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   PASS : $passCount" -ForegroundColor Green
Write-Host "   FAIL : $failCount" -ForegroundColor Red
Write-Host "   WARN : $warnCount" -ForegroundColor Yellow
$total = $passCount + $failCount + $warnCount
$score = if ($total -gt 0) { [math]::Round(($passCount / $total) * 100, 1) } else { 0 }
Write-Host "   SCORE: $score% ($passCount / $total checks passed)" -ForegroundColor $(if ($score -ge 90) {"Green"} elseif ($score -ge 70) {"Yellow"} else {"Red"})
Write-Host "  ══════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Export CSV
$csvPath = "$ReportPath.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "  CSV Report : $csvPath" -ForegroundColor White

# Export HTML
if ($ExportHTML) {
    $htmlPath = "$ReportPath.html"
    $html = @"
<!DOCTYPE html>
<html>
<head>
<title>GPO Compliance Report — $env:COMPUTERNAME</title>
<style>
  body { font-family: Segoe UI, sans-serif; background: #1a1a2e; color: #eee; padding: 20px; }
  h1 { color: #00d4ff; }
  .summary { display: flex; gap: 20px; margin-bottom: 20px; }
  .card { padding: 15px 30px; border-radius: 8px; text-align: center; }
  .pass { background: #1b4332; color: #40d96f; }
  .fail { background: #7f1d1d; color: #f87171; }
  .warn { background: #713f12; color: #fbbf24; }
  table { width: 100%; border-collapse: collapse; }
  th { background: #0f3460; color: #00d4ff; padding: 10px; text-align: left; }
  td { padding: 8px 10px; border-bottom: 1px solid #333; }
  tr:nth-child(even) { background: #16213e; }
  .PASS { color: #40d96f; font-weight: bold; }
  .FAIL { color: #f87171; font-weight: bold; }
  .WARN { color: #fbbf24; font-weight: bold; }
</style>
</head>
<body>
<h1>🔒 GPO Compliance Report</h1>
<p><strong>Machine:</strong> $env:COMPUTERNAME | <strong>Date:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm') | <strong>Score:</strong> $score%</p>
<div class="summary">
  <div class="card pass">✅ PASS<br><big>$passCount</big></div>
  <div class="card fail">❌ FAIL<br><big>$failCount</big></div>
  <div class="card warn">⚠️ WARN<br><big>$warnCount</big></div>
</div>
<table>
<tr><th>Category</th><th>Check</th><th>Status</th><th>Expected</th><th>Actual</th><th>Reference</th></tr>
$(foreach ($r in $results) {
"<tr><td>$($r.Category)</td><td>$($r.Check)</td><td class='$($r.Status)'>$($r.Status)</td><td>$($r.Expected)</td><td>$($r.Actual)</td><td>$($r.Reference)</td></tr>"
})
</table>
</body>
</html>
"@
    $html | Out-File -FilePath $htmlPath -Encoding UTF8
    Write-Host "  HTML Report: $htmlPath" -ForegroundColor White
    # Open in browser
    Start-Process $htmlPath
}

Write-Host ""
if ($failCount -gt 0) {
    Write-Host "  ⚠  ACTION REQUIRED: $failCount policy check(s) FAILED." -ForegroundColor Red
    Write-Host "     Run 'apply_local_security_policy.ps1' to remediate." -ForegroundColor Yellow
}
Write-Host ""
