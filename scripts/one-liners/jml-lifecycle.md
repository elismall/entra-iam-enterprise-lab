# Joiner-Mover-Leaver Lifecycle

Use case: Perform identity lifecycle actions against Microsoft Entra ID using `jml-lifecycle.ps1`.

## Joiner - Test

```powershell
& .\scripts\powershell\jml-lifecycle.ps1 -Action Joiner -EmployeeID "EMPLOYEE-ID" -TenantDomain "YOUR-TENANT.onmicrosoft.com" -WhatIf
```

## Joiner - Run

```powershell
& .\scripts\powershell\jml-lifecycle.ps1 -Action Joiner -EmployeeID "EMPLOYEE-ID" -TenantDomain "YOUR-TENANT.onmicrosoft.com"
```

Creates the employee account if it does not already exist.

## Mover - Test

```powershell
& .\scripts\powershell\jml-lifecycle.ps1 -Action Mover -EmployeeID "EMPLOYEE-ID" -NewDepartment "NEW-DEPARTMENT" -NewJobTitle "NEW-JOB-TITLE" -WhatIf
```

Example:

```powershell
& .\scripts\powershell\jml-lifecycle.ps1 -Action Mover -EmployeeID "3003" -NewDepartment "Information Technology" -NewJobTitle "Cloud Financial Analyst" -WhatIf
```

## Mover - Run

```powershell
& .\scripts\powershell\jml-lifecycle.ps1 -Action Mover -EmployeeID "EMPLOYEE-ID" -NewDepartment "NEW-DEPARTMENT" -NewJobTitle "NEW-JOB-TITLE"
```

Updates the employee's department and job title.

## Leaver - Test

```powershell
& .\scripts\powershell\jml-lifecycle.ps1 -Action Leaver -EmployeeID "EMPLOYEE-ID" -WhatIf
```

Example:

```powershell
& .\scripts\powershell\jml-lifecycle.ps1 -Action Leaver -EmployeeID "2002" -WhatIf
```

## Leaver - Run

```powershell
& .\scripts\powershell\jml-lifecycle.ps1 -Action Leaver -EmployeeID "EMPLOYEE-ID"
```

Disables the employee account and removes direct group memberships.