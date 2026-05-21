#Requires -RunAsAdministrator
# Security Status Check - Shows current state of all hardening settings
# Version 2.0

function Check-RegValue {
    param($Path, $Name, $Expected, $Label, $PassMsg, $FailMsg)
    try {
        $val = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop
        if ($val -eq $Expected) {
            Write-Host "  $Label" -NoNewline
            Write-Host "  [OK] $PassMsg" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  $Label" -NoNewline
            Write-Host "  [!!] $FailMsg (current: $val)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  $Label" -NoNewline
        Write-Host "  [!!] KEY NOT FOUND - not applied!" -ForegroundColor Red
        return $false
    }
}

function Check-RegAbsent {
    param($Path, $Name, $Label, $FailMsg)
    try {
        $val = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop
        Write-Host "  $Label" -NoNewline
        Write-Host "  [!!] $FailMsg (val=$val)" -ForegroundColor Red
        return $false
    } catch {
        Write-Host "  $Label" -NoNewline
        Write-Host "  [OK] KEY ABSENT (good)" -ForegroundColor Green
        return $true
    }
}

$ok  = 0
$bad = 0

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " SECURITY STATUS CHECK - Organisation Hardening Report"       -ForegroundColor Cyan
Write-Host " $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"                   -ForegroundColor Gray
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ---- MALWARE PROTECTION ----
Write-Host "[MALWARE PROTECTION]" -ForegroundColor Magenta

$r = Check-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"                                 "DisableAntiSpyware"       0 "Real-time Protection GP:     " "LOCKED ON"      "DISABLED or not set!"
if ($r) { $ok++ } else { $bad++ }

$r = Check-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"            "DisableRealtimeMonitoring" 0 "Realtime Monitoring GP:       " "LOCKED ON"      "NOT LOCKED - employees can toggle!"
if ($r) { $ok++ } else { $bad++ }

$r = Check-RegValue "HKLM:\SOFTWARE\Microsoft\Windows Defender"                                          "TamperProtection"          5 "Tamper Protection:            " "ENABLED (5)"    "DISABLED or not set!"
if ($r) { $ok++ } else { $bad++ }

$r = Check-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"                          "SpyNetReporting"           2 "Cloud Protection GP:          " "ENABLED"        "DISABLED or not set!"
if ($r) { $ok++ } else { $bad++ }

$r = Check-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"            "EnableScriptBlockLogging"  1 "PS Script Block Logging:      " "ENABLED"        "DISABLED"
if ($r) { $ok++ } else { $bad++ }

# ASR Rules count
try {
    $asrRules = (Get-MpPreference -ErrorAction Stop).AttackSurfaceReductionRules_Ids
    $count = if ($asrRules) { $asrRules.Count } else { 0 }
    Write-Host "  ASR Rules active:" -NoNewline
    if ($count -ge 10) {
        Write-Host "  [OK] $count rules active" -ForegroundColor Green; $ok++
    } elseif ($count -gt 0) {
        Write-Host "  [!!] Only $count rules (expected 10+)" -ForegroundColor Yellow; $bad++
    } else {
        Write-Host "  [!!] NO ASR RULES ACTIVE!" -ForegroundColor Red; $bad++
    }
} catch {
    Write-Host "  ASR Rules active:" -NoNewline
    Write-Host "  [!!] Cannot check (Defender not accessible)" -ForegroundColor Red; $bad++
}

Write-Host ""

# ---- FIREWALL ----
Write-Host "[NETWORK / FIREWALL]" -ForegroundColor Magenta

foreach ($profile in @("DomainProfile", "StandardProfile", "PublicProfile")) {
    $label = "Firewall GP Lock ($profile):"
    $padded = $label.PadRight(32)
    $r = Check-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\$profile" "EnableFirewall" 1 $padded "LOCKED ON" "NOT LOCKED - toggle accessible!"
    if ($r) { $ok++ } else { $bad++ }
}

$r = Check-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 0 "SMBv1:                         " "DISABLED"  "ENABLED (critical risk!)"
if ($r) { $ok++ } else { $bad++ }

$r = Check-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 0 "LLMNR:                         " "DISABLED"  "ENABLED (poisoning risk)"
if ($r) { $ok++ } else { $bad++ }

Write-Host ""

# ---- LOGIN SECURITY ----
Write-Host "[LOGIN SECURITY]" -ForegroundColor Magenta

$r = Check-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD"              0 "Ctrl+Alt+Del Required:        " "YES"                          "NO - login not secured"
if ($r) { $ok++ } else { $bad++ }

$r = Check-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "dontdisplaylastusername" 0 "Username Shown on lockscreen:  " "YES (by design - employees can see login name)" "NO - key is set to hide username unexpectedly"
if ($r) { $ok++ } else { $bad++ }

Write-Host ""

# ---- CREDENTIAL SECURITY ----
Write-Host "[CREDENTIAL SECURITY]" -ForegroundColor Magenta

$r = Check-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" "UseLogonCredential"          0 "WDigest (plaintext creds):    " "DISABLED"  "ENABLED - passwords stored in memory!"
if ($r) { $ok++ } else { $bad++ }

$r = Check-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"    "DisableExceptionChainValidation" 0 "SEHOP:                        " "ENABLED"   "DISABLED"
if ($r) { $ok++ } else { $bad++ }

$r = Check-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RunAsPPL" 1 "LSA RunAsPPL:                 " "ENABLED (anti-dump)" "DISABLED - credential dumping possible"
if ($r) { $ok++ } else { $bad++ }

Write-Host ""

# ---- OFFICE SECURITY ----
Write-Host "[OFFICE SECURITY]" -ForegroundColor Magenta

foreach ($ver in @("16.0", "15.0")) {
    $label = "Office Macros GP ($ver):"
    $padded = $label.PadRight(32)
    $r = Check-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Office\$ver\word\Security" "VBAWarnings" 4 $padded "LOCKED DISABLED" "NOT LOCKED (employees can enable macros!)"
    if ($r) { $ok++ } else { $bad++ }
}

Write-Host ""

# ---- SUMMARY ----
Write-Host "============================================================" -ForegroundColor Cyan
$total = $ok + $bad
Write-Host " RESULTS: $ok / $total checks passed" -ForegroundColor $(if ($bad -eq 0) { "Green" } else { "Yellow" })
if ($bad -gt 0) {
    Write-Host " $bad ISSUES FOUND - run apply_all_security.ps1 to fix" -ForegroundColor Red
} else {
    Write-Host " All hardening settings are correctly applied!" -ForegroundColor Green
}
Write-Host ""
Write-Host " [OK]  = Setting is correctly hardened"  -ForegroundColor Green
Write-Host " [!!]  = PROBLEM - setting is missing or wrong" -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
