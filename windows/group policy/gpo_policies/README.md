# GPO Policy Backup Folders

This directory contains exported Group Policy Object (GPO) backups.
Each subfolder is a named GPO that can be imported into Active Directory
using the `deploy\import_gpo_backup.ps1` script or via the
**Group Policy Management Console (GPMC)**.

---

## How to Create a GPO Backup (Export)

1. Open **Group Policy Management** (`gpmc.msc`)
2. Right-click your GPO → **Back Up...**
3. Set the destination to one of the folders below
4. The backup will create a folder with a GUID inside — rename appropriately

Or via PowerShell:
```powershell
Backup-GPO -Name "IT-SEC-Firewall-Enforcement" -Path ".\GPO_Firewall_Enforcement"
```

---

## Included GPO Backups

| Folder                      | GPO Name                       | Description                                      |
|-----------------------------|--------------------------------|--------------------------------------------------|
| `GPO_Firewall_Enforcement/` | IT-SEC-Firewall-Enforcement    | Forces firewall ON, prevents user disable         |
| `GPO_Defender_Enforcement/` | IT-SEC-Defender-Enforcement    | Forces Defender ON with cloud protection          |
| `GPO_Password_Policy/`      | IT-SEC-Password-Policy         | 14-char min, 90-day max, 24 history, lockout=5    |
| `GPO_USB_Control/`          | IT-SEC-USB-Removable-Control   | Disables AutoRun, blocks write to USB             |
| `GPO_Software_Restriction/` | IT-SEC-Software-Restriction    | AppLocker / SRP to block unauthorized executables |
| `GPO_Audit_Policy/`         | IT-SEC-Audit-Logging-Policy    | Full audit trail — logon, account, policy changes |
| `GPO_Screen_Lock/`          | IT-SEC-Screen-Lock-Policy      | 10-min screen lock, password-protected screensaver|
| `GPO_User_Rights/`          | IT-SEC-User-Rights-Assignment  | Least privilege — restricts elevation rights      |

---

## How to Import GPO Backups

```powershell
# Import a single GPO
Import-GPO -BackupGpoName "IT-SEC-Firewall-Enforcement" `
           -Path ".\GPO_Firewall_Enforcement" `
           -TargetName "IT-SEC-Firewall-Enforcement" `
           -CreateIfNeeded

# Import ALL GPOs and link to an OU
.\deploy\deploy_all_gpos.ps1 -OUPath "OU=Workstations,DC=company,DC=local"
```

---

## Note on Backup Folder Contents

After running `Backup-GPO`, each folder will contain:
```
GPO_Firewall_Enforcement/
└── {GUID}/
    ├── Backup.xml
    ├── bkupInfo.xml
    └── DomainSysvol/
        └── GPO/
            ├── Machine/
            │   └── registry.pol
            └── User/
```

The scripts in `deploy/` handle GUID discovery automatically.
