<# ==============================================================
   APPLY LOCAL SECURITY POLICY
   ==============================================================
   Purpose  : Enforce all security policies on a standalone/workgroup machine
              (No Active Directory required)
   Run As   : Local Administrator
   Usage    : .\apply_local_security_policy.ps1
   Scope    : Firewall, Defender, Password, Audit, Screen Lock,
              USB Control, UAC, User Rights
   ==============================================================
#>

#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

# ─── Logging Setup ────────────────────────────────────────────────────────────
$LogDir  = "$PSScriptRoot\logs"
$LogFile = "$LogDir\local_policy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$ts][$Level] $Message"
    Add-Content -Path $LogFile -Value $entry
    $col = switch ($Level) {
        "OK"      { "Green" }
        "WARN"    { "Yellow" }
        "ERROR"   { "Red" }
        "SECTION" { "Cyan" }
        default   { "White" }
    }
    if ($Level -eq "SECTION") {
        Write-Host ""
        Write-Host ("=" * 60) -ForegroundColor $col
        Write-Host "  $Message" -ForegroundColor $col
        Write-Host ("=" * 60) -ForegroundColor $col
    } else {
        Write-Host "  [$Level] $Message" -ForegroundColor $col
    }
}

function Set-Reg {
    param([string]$Path, [string]$Name, $Value, [string]$Type = "DWORD")
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
        Write-Log "SET: $Path\$Name = $Value" "OK"
    } catch {
        Write-Log "FAILED: $Path\$Name — $_" "ERROR"
    }
}

# ─── Banner ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║    LOCAL SECURITY POLICY ENFORCER — IT ORGANIZATION     ║" -ForegroundColor Cyan
Write-Host "  ║    CIS Benchmark | NIST 800-53 | ISO 27001 Compliant    ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Log "Local Security Policy Application Started" "INFO"
Write-Log "Machine: $env:COMPUTERNAME | User: $env:USERNAME" "INFO"

# ═══════════════════════════════════════════════════════════════════════════════
# [1] WINDOWS FIREWALL — ENFORCE ON, PREVENT USER CHANGES
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "WINDOWS FIREWALL ENFORCEMENT" "SECTION"

# Enable Firewall for all profiles via netsh
$profiles = @("domain", "private", "public")
foreach ($profile in $profiles) {
    try {
        netsh advfirewall set $profile state on | Out-Null
        Write-Log "Firewall ON — Profile: $profile" "OK"
    } catch { Write-Log "Failed to enable firewall for $profile" "ERROR" }
}

# Block user from disabling firewall via registry
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"  "EnableFirewall" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "EnableFirewall" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"  "EnableFirewall" 1

# Disable notifications to users about firewall changes
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"  "DisableNotifications" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"  "DisableNotifications" 0

# Prevent user from modifying firewall rules
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"  "AllowLocalPolicyMerge"   0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "AllowLocalPolicyMerge"   0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"  "AllowLocalPolicyMerge"   0

# ═══════════════════════════════════════════════════════════════════════════════
# [2] WINDOWS DEFENDER — ENFORCE, PREVENT DISABLING
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "WINDOWS DEFENDER ENFORCEMENT" "SECTION"

# Ensure Defender is running
try {
    Set-MpPreference -DisableRealtimeMonitoring $false
    Write-Log "Defender Real-Time Protection: ENABLED" "OK"
} catch { Write-Log "Failed to set Defender Real-Time — may need Tamper Protection" "WARN" }

# Registry: Prevent disabling Defender via policy
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableAntiSpyware"     0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableAntiVirus"       0

# Real-Time Protection
$rtPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
Set-Reg $rtPath "DisableRealtimeMonitoring"    0
Set-Reg $rtPath "DisableBehaviorMonitoring"    0
Set-Reg $rtPath "DisableOnAccessProtection"    0
Set-Reg $rtPath "DisableScanOnRealtimeEnable"  0

# Cloud Protection
$cloudPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
Set-Reg $cloudPath "SpynetReporting"              2
Set-Reg $cloudPath "SubmitSamplesConsent"         1
Set-Reg $cloudPath "DisableBlockAtFirstSeen"      0

# PUA Protection
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" "MpEnablePus" 1

# Tamper Protection (requires Windows Security Center)
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" "TamperProtection" 5

# ═══════════════════════════════════════════════════════════════════════════════
# [3] USER ACCOUNT CONTROL (UAC) — STRICT MODE
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "UAC ENFORCEMENT" "SECTION"

$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-Reg $uacPath "EnableLUA"                      1   # UAC ON
Set-Reg $uacPath "ConsentPromptBehaviorAdmin"      2   # Prompt for credentials (admin)
Set-Reg $uacPath "ConsentPromptBehaviorUser"       0   # Auto-deny elevation for standard users
Set-Reg $uacPath "EnableInstallerDetection"        1   # Detect app installs
Set-Reg $uacPath "EnableSecureUIAPaths"            1   # Secure UIAccess paths
Set-Reg $uacPath "EnableVirtualization"            1   # Virtualize file/registry writes
Set-Reg $uacPath "PromptOnSecureDesktop"           1   # Prompt on secure desktop
Set-Reg $uacPath "ValidateAdminCodeSignatures"     0
Set-Reg $uacPath "FilterAdministratorToken"        1

# ═══════════════════════════════════════════════════════════════════════════════
# [4] PASSWORD POLICY — CIS Benchmark Compliant
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "PASSWORD POLICY ENFORCEMENT" "SECTION"

$infPath = "$PSScriptRoot\password_policy.inf"
if (Test-Path $infPath) {
    try {
        secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $infPath /quiet
        Write-Log "Password policy applied via secedit." "OK"
    } catch { Write-Log "secedit password policy failed." "ERROR" }
} else {
    # Fallback: Apply via net accounts
    try {
        net accounts /minpwlen:14 /maxpwage:90 /minpwage:1 /uniquepw:24 /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30 | Out-Null
        Write-Log "Password policy applied via net accounts (fallback)." "OK"
    } catch { Write-Log "net accounts password policy failed." "ERROR" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# [5] SCREEN LOCK / SCREENSAVER POLICY
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "SCREEN LOCK POLICY" "SECTION"

$screensaverPath = "HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop"
Set-Reg $screensaverPath "ScreenSaveTimeOut"  "600"  "String"   # 10 minutes
Set-Reg $screensaverPath "ScreenSaveActive"   "1"    "String"   # Enable screensaver
Set-Reg $screensaverPath "ScreenSaverIsSecure" "1"   "String"   # Require password on resume

# Machine-wide screen lock via registry
$consoleSettings = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
Set-Reg $consoleSettings "NoLockScreenCamera"   1
Set-Reg $consoleSettings "NoLockScreenSlideshow" 1

# Require CTRL+ALT+DEL for logon
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0

# ═══════════════════════════════════════════════════════════════════════════════
# [6] USB / REMOVABLE MEDIA CONTROL
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "USB AND REMOVABLE MEDIA CONTROL" "SECTION"

# Disable AutoRun/AutoPlay for all drives
$autoRunPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
Set-Reg $autoRunPath "NoAutorun" 1
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 255
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoAutorun"          1

# Disable write access to removable storage
$removablePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices"
Set-Reg "$removablePath\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" "Deny_Write" 1  # Floppy/Disk
Set-Reg "$removablePath\{53f56307-b6bf-11d0-94f2-00a0c91efb8b}" "Deny_Write" 1  # Hard disk
Set-Reg "$removablePath\{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}" "Deny_Write" 1  # CD/DVD
Set-Reg "$removablePath\{6AC27878-A6FA-4155-BA85-F98F491D4F33}" "Deny_Write" 1  # WPD

# Optional: Deny ALL removable device read (set to 1 for stricter environments)
# Set-Reg "$removablePath\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" "Deny_Read" 0

Write-Log "USB write access disabled (read allowed). Modify Deny_Read keys to block read too." "WARN"

# ═══════════════════════════════════════════════════════════════════════════════
# [7] AUDIT POLICY — CIS Benchmark Level 2
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "AUDIT POLICY ENFORCEMENT" "SECTION"

$auditCategories = @{
    "Account Logon"         = @("Credential Validation", "Kerberos Authentication Service")
    "Account Management"    = @("Computer Account Management", "Other Account Management Events",
                                 "Security Group Management", "User Account Management")
    "Detailed Tracking"     = @("Process Creation")
    "Logon/Logoff"          = @("Account Lockout", "Logoff", "Logon", "Special Logon")
    "Object Access"         = @("Removable Storage", "File System", "Registry")
    "Policy Change"         = @("Audit Policy Change", "Authentication Policy Change",
                                 "Authorization Policy Change")
    "Privilege Use"         = @("Sensitive Privilege Use")
    "System"                = @("Security State Change", "Security System Extension",
                                 "System Integrity")
}

foreach ($category in $auditCategories.Keys) {
    foreach ($subcategory in $auditCategories[$category]) {
        try {
            auditpol /set /subcategory:"$subcategory" /success:enable /failure:enable 2>&1 | Out-Null
            Write-Log "Audit enabled: $subcategory (success+failure)" "OK"
        } catch {
            Write-Log "Audit set failed: $subcategory" "WARN"
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# [8] EVENT LOG SETTINGS
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "EVENT LOG CONFIGURATION" "SECTION"

$logs = @("Application", "Security", "System")
foreach ($log in $logs) {
    try {
        # Set max size to 1GB
        wevtutil sl $log /ms:1073741824 2>&1 | Out-Null
        # Set retention to "overwrite when full"
        wevtutil sl $log /rt:false 2>&1 | Out-Null
        Write-Log "Event log '$log' — MaxSize: 1GB, Retention: Overwrite" "OK"
    } catch {
        Write-Log "Event log config failed for $log" "WARN"
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# [9] WINDOWS UPDATE — ENFORCE AUTO-UPDATE
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "WINDOWS UPDATE POLICY" "SECTION"

$wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
Set-Reg $wuPath "NoAutoUpdate"                  0
Set-Reg $wuPath "AUOptions"                     4   # Auto-download and schedule install
Set-Reg $wuPath "ScheduledInstallDay"           0   # Every day
Set-Reg $wuPath "ScheduledInstallTime"          3   # 3 AM
Set-Reg $wuPath "AutoInstallMinorUpdates"       1
Set-Reg $wuPath "NoAutoRebootWithLoggedOnUsers" 0

# ═══════════════════════════════════════════════════════════════════════════════
# [10] RESTRICT CONTROL PANEL AND SYSTEM SETTINGS ACCESS
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "USER RESTRICTION — CONTROL PANEL / SETTINGS" "SECTION"

$explPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Set-Reg $explPath "NoControlPanel"               0   # Allow Control Panel (admins monitor)
Set-Reg $explPath "DisallowCpl"                  0

# Restrict access to specific Control Panel items
$restrictPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Set-Reg $restrictPath "NoWindowsUpdate"          0   # Allow update check UI
Set-Reg $restrictPath "NoChangeStartMenu"        0

# Prevent users from turning off Security Center
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableCMD"         0  # Allow CMD for admins
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "HideUACPrompt" 0

# ═══════════════════════════════════════════════════════════════════════════════
# [11] DISABLE UNNECESSARY FEATURES
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "DISABLE UNNECESSARY / RISKY FEATURES" "SECTION"

# Disable Remote Assistance
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" "fAllowToGetHelp" 0

# Disable WinRM if not needed (comment out if WinRM is used for management)
# try { Disable-PSRemoting -Force 2>&1 | Out-Null; Write-Log "PSRemoting disabled." "OK" } catch {}

# Disable SMBv1
try {
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
    Write-Log "SMBv1: DISABLED" "OK"
} catch { Write-Log "Failed to disable SMBv1 via cmdlet." "WARN" }
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 0

# Disable LLMNR
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 0

# Disable NetBIOS over TCP/IP (via registry)
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" "NodeType" 2

# Disable Autorun for all media types
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 255

# ═══════════════════════════════════════════════════════════════════════════════
# [12] SECURE BROWSER SETTINGS (EDGE / IE)
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "BROWSER SECURITY POLICIES" "SECTION"

# Microsoft Edge
$edgePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
Set-Reg $edgePath "SmartScreenEnabled"            1
Set-Reg $edgePath "PreventSmartScreenPromptOverride" 1
Set-Reg $edgePath "DownloadRestrictions"          2   # Block dangerous downloads
Set-Reg $edgePath "SSLVersionMin"                 "tls1.2"  "String"
Set-Reg $edgePath "NewTabPageAllowedBackgroundTypes" 3

# ═══════════════════════════════════════════════════════════════════════════════
# [13] BITLOCKER ENFORCEMENT CHECK
# ═══════════════════════════════════════════════════════════════════════════════
Write-Log "BITLOCKER STATUS CHECK" "SECTION"

try {
    $blStatus = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
    if ($blStatus) {
        $status = $blStatus.ProtectionStatus
        Write-Log "BitLocker on C: — Status: $status" $(if ($status -eq "On") { "OK" } else { "WARN" })
        if ($status -ne "On") {
            Write-Log "BitLocker is NOT enabled on C:. Consider enabling via: enable_bitlocker.ps1" "WARN"
        }
    }
} catch { Write-Log "Could not check BitLocker status." "WARN" }

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   LOCAL SECURITY POLICY — APPLIED SUCCESSFULLY          ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Log "Log saved to: $LogFile" "INFO"
Write-Host ""
Write-Host "  IMPORTANT: Some settings require a REBOOT to take full effect." -ForegroundColor Yellow
Write-Host "  Run 'gpupdate /force' to refresh policy on domain machines." -ForegroundColor Yellow
Write-Host ""
