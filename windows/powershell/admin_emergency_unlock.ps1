#Requires -RunAsAdministrator
# ============================================================
# ADMIN EMERGENCY UNLOCK - For IT Administrator Only (PowerShell)
# ============================================================
# This script provides a password-protected temporary bypass
# for the IT administrator to run maintenance scripts.
#
# HOW TO CUSTOMIZE BEFORE DEPLOYMENT:
#   1. Choose a strong passphrase
#   2. Run this command to get the SHA-256 hash:
#      $bytes = [System.Text.Encoding]::UTF8.GetBytes("YOUR_PASSPHRASE")
#      $sha256 = [System.Security.Cryptography.SHA256]::Create()
#      [BitConverter]::ToString($sha256.ComputeHash($bytes)).Replace("-","")
#   3. Replace the $AdminHash value below with your hash (uppercase)
#   4. Store the passphrase in a secure password manager
#
# DEFAULT passphrase: OrgAdmin2024!Unlock
# CHANGE THIS BEFORE DEPLOYMENT!
# ============================================================

# === SET YOUR HASH HERE (SHA-256 of your passphrase, UPPERCASE) ===
# Default hash is for passphrase: OrgAdmin2024!Unlock
$AdminHash = "7B6D8E4F2A1C9E5B3D7F0A8C2E4B6D9F1A3C5E7B9D0F2A4C6E8B0D2F4A6C8E0B"

# Logging setup
$LogDir    = "C:\ProgramData\OrgSecurity"
$LogFile   = "$LogDir\security_log.txt"
$UnlockLog = "$LogDir\unlock_log.txt"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host " ADMIN EMERGENCY UNLOCK - Authorised Personnel Only"         -ForegroundColor Magenta
Write-Host " Every unlock attempt is logged with timestamp + username."  -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

# Securely read passphrase (masked input)
$SecurePass = Read-Host "Enter admin passphrase" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePass)
$Passphrase = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

# Hash the input
$Sha256 = [System.Security.Cryptography.SHA256]::Create()
$Bytes  = [System.Text.Encoding]::UTF8.GetBytes($Passphrase)
$InputHash = [BitConverter]::ToString($Sha256.ComputeHash($Bytes)).Replace("-", "").ToUpper()
$Passphrase = $null  # Clear from memory immediately

# Timestamp
$Stamp = Get-Date -Format "yyyy-MM-dd HH:mm"

if ($InputHash -eq $AdminHash.ToUpper()) {
    # SUCCESS
    Add-Content -Path $UnlockLog -Value "[$Stamp] [UNLOCK-SUCCESS] Admin unlock by $env:USERNAME on $env:COMPUTERNAME"
    Add-Content -Path $LogFile   -Value "[$Stamp] [UNLOCK-SUCCESS] Admin unlock by $env:USERNAME"

    Write-Host ""
    Write-Host "[OK] Authentication successful." -ForegroundColor Green
    Write-Host "[OK] Unlock event logged to: $UnlockLog" -ForegroundColor Green
    Write-Host ""
    Write-Host "Applying temporary overrides..." -ForegroundColor Yellow

    # Step 1: Disable Tamper Protection
    try {
        Set-MpPreference -TamperProtection 4 -ErrorAction Stop
        Write-Host "[OK] Tamper Protection temporarily disabled" -ForegroundColor Green
    } catch {
        Write-Host "[NOTE] Tamper Protection API unavailable - use Windows Security UI if needed" -ForegroundColor Yellow
    }

    # Step 2: Set execution policy to Bypass for this process only (NOT permanent)
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    Write-Host "[OK] Execution Policy: Bypass (this session only, NOT written to registry)" -ForegroundColor Green

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host " Admin shell is now ACTIVE with:"                             -ForegroundColor Yellow
    Write-Host "   - ExecutionPolicy: Bypass (session only)"                 -ForegroundColor Cyan
    Write-Host "   - Tamper Protection: Temporarily disabled"                -ForegroundColor Cyan
    Write-Host ""
    Write-Host " Run your maintenance scripts now."                           -ForegroundColor White
    Write-Host " When finished, run: admin_relock.ps1"                       -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "REMINDER: Run admin_relock.ps1 when done!" -ForegroundColor Red
    Write-Host ""

    # Drop into interactive admin shell in the same window
    # The caller can now run any script freely in this session
    Write-Host "You are now in the unlocked admin session." -ForegroundColor Green
    Write-Host "Type 'exit' or run admin_relock.ps1 to re-lock." -ForegroundColor Cyan
    Write-Host ""

    # Keep session alive for admin work
    $Host.EnterNestedPrompt()

    # After nested prompt exits (admin typed 'exit'), auto-relock
    Write-Host ""
    Write-Host "[INFO] Admin session ended. Initiating auto-relock..." -ForegroundColor Yellow
    $RelockPath = Join-Path $PSScriptRoot "admin_relock.ps1"
    if (Test-Path $RelockPath) {
        & $RelockPath
    } else {
        Write-Host "[WARN] admin_relock.ps1 not found. Please run apply_all_security.ps1 manually!" -ForegroundColor Red
    }

} else {
    # FAILED
    Add-Content -Path $UnlockLog -Value "[$Stamp] [UNLOCK-FAILED] Failed attempt by $env:USERNAME on $env:COMPUTERNAME"
    Add-Content -Path $LogFile   -Value "[$Stamp] [UNLOCK-FAILED] Failed unlock attempt by $env:USERNAME"

    Write-Host ""
    Write-Host "[DENIED] Authentication failed. This attempt has been logged." -ForegroundColor Red
    Write-Host ""
}

Read-Host "Press Enter to exit"
