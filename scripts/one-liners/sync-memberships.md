# Sync Entra Group Memberships

Use case: Read `data/group-memberships.csv`, match users and security groups, add missing memberships, and skip memberships that already exist.

## Test First

```powershell
& .\scripts\powershell\sync-entra-memberships.ps1 -WhatIf
```

Use `-WhatIf` to preview membership changes without modifying Entra ID.

## Run Membership Sync

```powershell
& .\scripts\powershell\sync-entra-memberships.ps1
```

## Expected Final Reconciliation

Running the script again after synchronization should ideally return:

```text
Added:     0
Unchanged: 23
Failed:    0
```

This confirms that all defined memberships already exist and the script can be safely rerun.