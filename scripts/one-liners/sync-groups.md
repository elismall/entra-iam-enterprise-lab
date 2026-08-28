# Sync Entra Groups

Use case: Read security groups from `data/groups.csv`, create missing groups, update existing groups, and prevent duplicates.

## Test First

```powershell
& .\scripts\powershell\sync-entra-groups.ps1 -WhatIf
```

Use `-WhatIf` to preview group creation or updates without making changes.

## Run Group Sync

```powershell
& .\scripts\powershell\sync-entra-groups.ps1
```

## Verify Groups

```powershell
Get-MgGroup -All |
Where-Object {$_.DisplayName -like "SG-*"} |
Sort-Object DisplayName |
Select-Object DisplayName
```

A second sync should ideally return all groups as:

```text
[UNCHANGED]
```