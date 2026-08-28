## Sync Entra Users

Use case: Read users from `data/users.csv`, skip users that already exist, and create the missing users in Microsoft Entra ID through Microsoft Graph.

### Test First With WhatIf

```powershell
& .\scripts\Sync-Entra-user.ps1 -TenantDomain "YOUR-TENANT.onmicrosoft.com" -WhatIf
```

Example:

```powershell
& .\scripts\Sync-Entra-user.ps1 -TenantDomain "elidukelabsproton.onmicrosoft.com" -WhatIf
```

Use `-WhatIf` first to preview which users would be created without making any changes.

### Run The User Sync

```powershell
& .\scripts\Sync-Entra-user.ps1 -TenantDomain "YOUR-TENANT.onmicrosoft.com"
```

Example:

```powershell
& .\scripts\Sync-Entra-user.ps1 -TenantDomain "elidukelabsproton.onmicrosoft.com"
```

This will:

- Read `data/users.csv`
- Skip existing users
- Create missing users
- Assign identity attributes from the CSV
- Display a synchronization summary