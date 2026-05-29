# ============================================================
#  GROUP POLICY MANAGEMENT - IT ORGANIZATION HARDENING SUITE
# ============================================================
#  Author       : IT Security Team
#  Organization : [Your Organization Name]
#  Version      : 1.0.0
#  Last Updated : 2026-05-29
#  Compliance   : CIS Benchmark, NIST SP 800-53, ISO 27001
# ============================================================

## Overview

This directory contains all Group Policy Objects (GPOs), ADMX templates,
PowerShell deployment scripts, and documentation for enforcing enterprise-grade
security policies across all Windows endpoints in the organization.

These policies follow the **Principle of Least Privilege** and ensure:
- Users CANNOT disable Windows Defender / Firewall
- USB and removable media access is controlled
- Screen lock and password policies are enforced
- Software installation is restricted
- Audit logging is mandatory
- Remote access is tightly controlled

---

## Folder Structure

```
group policy/
├── README.md                        ← This file
│
├── gpo_templates/                   ← ADMX/ADML custom policy templates
│   ├── Security_Baseline.admx
│   ├── Security_Baseline.adml
│   └── Custom_AppControl.admx
│
├── gpo_policies/                    ← Exported GPO backup folders (importable)
│   ├── GPO_Firewall_Enforcement/
│   ├── GPO_Defender_Enforcement/
│   ├── GPO_Password_Policy/
│   ├── GPO_USB_Control/
│   ├── GPO_Software_Restriction/
│   ├── GPO_Audit_Policy/
│   ├── GPO_Screen_Lock/
│   └── GPO_User_Rights/
│
├── deploy/                          ← Scripts to import and link GPOs
│   ├── deploy_all_gpos.ps1
│   ├── import_gpo_backup.ps1
│   ├── link_gpo_to_ou.ps1
│   └── verify_gpo_application.ps1
│
├── registry/                        ← Registry-based policy enforcement
│   ├── enforce_firewall_registry.reg
│   ├── enforce_defender_registry.reg
│   ├── enforce_uac_registry.reg
│   └── enforce_usb_registry.reg
│
├── local_policy/                    ← Local Security Policy scripts (non-domain)
│   ├── apply_local_security_policy.ps1
│   ├── apply_local_security_policy.bat
│   ├── password_policy.inf
│   └── audit_policy.inf
│
├── secedit/                         ← Security templates for secedit
│   ├── security_baseline.inf
│   └── apply_secedit_template.bat
│
└── reports/                         ← GPO compliance and audit reports
    ├── generate_gpo_report.ps1
    └── gpo_compliance_check.ps1
```

---

## Quick Start

### For Domain Environments (Active Directory)
```powershell
# Run as Domain Admin on a Domain Controller
cd "group policy\deploy"
.\deploy_all_gpos.ps1 -OUPath "OU=Workstations,DC=company,DC=local"
```

### For Standalone / Workgroup Machines
```powershell
# Run as Local Administrator
cd "group policy\local_policy"
.\apply_local_security_policy.ps1
```

### For Registry-Based Enforcement (No AD Required)
```cmd
:: Run as Administrator
regedit /s "group policy\registry\enforce_firewall_registry.reg"
regedit /s "group policy\registry\enforce_defender_registry.reg"
regedit /s "group policy\registry\enforce_uac_registry.reg"
regedit /s "group policy\registry\enforce_usb_registry.reg"
```

---

## Policies Enforced

| Policy Area              | GPO Name                     | Priority |
|--------------------------|------------------------------|----------|
| Windows Firewall         | GPO_Firewall_Enforcement     | CRITICAL |
| Windows Defender         | GPO_Defender_Enforcement     | CRITICAL |
| Password & Lockout       | GPO_Password_Policy          | HIGH     |
| USB / Removable Media    | GPO_USB_Control              | HIGH     |
| Software Restriction     | GPO_Software_Restriction     | HIGH     |
| Audit & Event Logging    | GPO_Audit_Policy             | HIGH     |
| Screen Lock / Screensaver| GPO_Screen_Lock              | MEDIUM   |
| User Rights Assignment   | GPO_User_Rights              | CRITICAL |

---

## Compliance References

- **CIS Microsoft Windows Benchmark** (v3.0)
- **NIST SP 800-53** - Security and Privacy Controls
- **ISO/IEC 27001:2022** - Information Security Management
- **DISA STIG** - Windows 10/11 Security Technical Implementation Guide

---

## Notes

- Always test GPOs in a **test OU** before applying to production.
- Use `gpresult /H report.html` to audit applied policies on any machine.
- GPO backups in `gpo_policies/` can be imported via `Group Policy Management Console`.
- Registry `.reg` files are suitable for non-domain machines and MDM-managed devices.
