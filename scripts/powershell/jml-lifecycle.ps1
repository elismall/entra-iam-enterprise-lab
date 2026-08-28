<#
.SYNOPSIS
Demonstrates Joiner-Mover-Leaver identity lifecycle operations in Microsoft Entra ID.

.DESCRIPTION
Uses Microsoft Graph to perform basic IAM lifecycle actions:

Joiner:
Creates a user from users.csv if the identity does not already exist.

Mover:
Updates an existing user's department and job title.

Leaver:
Disables the user's account and removes direct group memberships.

Designed for the Small Studios IAM lab.

.EXAMPLE
.\scripts\powershell\jml-lifecycle.ps1 `
    -Action Joiner `
    -EmployeeID "3003" `
    -TenantDomain "example.onmicrosoft.com" `
    -WhatIf

.EXAMPLE
.\scripts\powershell\jml-lifecycle.ps1 `
    -Action Mover `
    -EmployeeID "3003" `
    -NewDepartment "Information Technology" `
    -NewJobTitle "Cloud Financial Analyst" `
    -WhatIf

.EXAMPLE
.\scripts\powershell\jml-lifecycle.ps1 `
    -Action Leaver `
    -EmployeeID "2002" `
    -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true)]

param(

    [Parameter(Mandatory = $true)]
    [ValidateSet("Joiner","Mover","Leaver")]
    [string]$Action,

    [Parameter(Mandatory = $true)]
    [string]$EmployeeID,

    [string]$TenantDomain,

    [string]$NewDepartment,

    [string]$NewJobTitle,

    [string]$CompanyName = "Small Studios"
)

# ------------------------------------------------------------
# Locate repository
# ------------------------------------------------------------

$ScriptsFolder = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptsFolder

$UsersCsv = Join-Path $RepoRoot "data\users.csv"

if (-not (Test-Path $UsersCsv)) {
    Write-Error "users.csv was not found."
    exit 1
}

# ------------------------------------------------------------
# Verify Graph connection
# ------------------------------------------------------------

$Context = Get-MgContext

if (-not $Context) {
    Write-Error "No Microsoft Graph connection detected."
    exit 1
}

Write-Host ""
Write-Host "Microsoft Graph connection verified."
Write-Host "Tenant: $($Context.TenantId)"
Write-Host ""

# ------------------------------------------------------------
# Load identity source
# ------------------------------------------------------------

$CsvUsers = Import-Csv $UsersCsv

$SourceUser = $CsvUsers |
    Where-Object { $_.EmployeeID -eq $EmployeeID } |
    Select-Object -First 1

if (-not $SourceUser) {
    Write-Error "EmployeeID $EmployeeID was not found in users.csv."
    exit 1
}

$DisplayName = "$($SourceUser.FirstName) $($SourceUser.LastName)"

Write-Host "Lifecycle Action: $Action"
Write-Host "Employee: $DisplayName"
Write-Host "Employee ID: $EmployeeID"
Write-Host ""

# ------------------------------------------------------------
# Find Entra user by Employee ID
# ------------------------------------------------------------

$EntraUser = Get-MgUser `
    -All `
    -Property Id,DisplayName,UserPrincipalName,EmployeeId,Department,JobTitle,AccountEnabled |
    Where-Object { $_.EmployeeId -eq $EmployeeID } |
    Select-Object -First 1

# ============================================================
# JOINER
# ============================================================

if ($Action -eq "Joiner") {

    if ($EntraUser) {

        Write-Host "[UNCHANGED] User already exists:"
        Write-Host "$($EntraUser.UserPrincipalName)"
        exit 0
    }

    if (-not $TenantDomain) {
        Write-Error "TenantDomain is required for Joiner actions."
        exit 1
    }

    $MailNickname = (
        "$($SourceUser.FirstName).$($SourceUser.LastName)"
    ).ToLowerInvariant()

    $UPN = "$MailNickname@$TenantDomain"

    $RandomValue = [guid]::NewGuid().ToString("N").Substring(0,12)

    $TemporaryPassword = "Aa!9$RandomValue"

    $NewUser = @{
        accountEnabled    = $true
        displayName       = $DisplayName
        givenName         = $SourceUser.FirstName
        surname           = $SourceUser.LastName
        userPrincipalName = $UPN
        mailNickname      = $MailNickname
        employeeId        = $EmployeeID
        department        = $SourceUser.Department
        jobTitle          = $SourceUser.JobTitle
        companyName       = $CompanyName
        usageLocation     = "US"

        passwordProfile = @{
            password = $TemporaryPassword
            forceChangePasswordNextSignIn = $true
        }
    }

    if ($PSCmdlet.ShouldProcess(
        $UPN,
        "Provision Joiner account"
    )) {

        try {

            New-MgUser `
                -BodyParameter $NewUser `
                -ErrorAction Stop |
                Out-Null

            Write-Host "[JOINER CREATED] $UPN"
        }
        catch {

            Write-Host "[FAILED] Joiner provisioning"
            Write-Host $_.Exception.Message
            exit 1
        }
    }
}

# ============================================================
# MOVER
# ============================================================

elseif ($Action -eq "Mover") {

    if (-not $EntraUser) {
        Write-Error "User does not exist in Entra ID."
        exit 1
    }

    if (-not $NewDepartment -or -not $NewJobTitle) {

        Write-Error "Mover requires NewDepartment and NewJobTitle."
        exit 1
    }

    Write-Host "Current Department: $($EntraUser.Department)"
    Write-Host "New Department:     $NewDepartment"
    Write-Host ""
    Write-Host "Current Job Title:  $($EntraUser.JobTitle)"
    Write-Host "New Job Title:      $NewJobTitle"
    Write-Host ""

    $UpdateBody = @{
        department = $NewDepartment
        jobTitle    = $NewJobTitle
    }

    if ($PSCmdlet.ShouldProcess(
        $EntraUser.UserPrincipalName,
        "Update Mover identity attributes"
    )) {

        try {

            Update-MgUser `
                -UserId $EntraUser.Id `
                -BodyParameter $UpdateBody `
                -ErrorAction Stop

            Write-Host "[MOVER UPDATED]"
            Write-Host "$($EntraUser.UserPrincipalName)"
        }
        catch {

            Write-Host "[FAILED] Mover update"
            Write-Host $_.Exception.Message
            exit 1
        }
    }
}

# ============================================================
# LEAVER
# ============================================================

elseif ($Action -eq "Leaver") {

    if (-not $EntraUser) {
        Write-Error "User does not exist in Entra ID."
        exit 1
    }

    # --------------------------------------------------------
    # Disable account
    # --------------------------------------------------------

    if ($PSCmdlet.ShouldProcess(
        $EntraUser.UserPrincipalName,
        "Disable Leaver account"
    )) {

        try {

            Update-MgUser `
                -UserId $EntraUser.Id `
                -AccountEnabled:$false `
                -ErrorAction Stop

            Write-Host "[DISABLED] $($EntraUser.UserPrincipalName)"
        }
        catch {

            Write-Host "[FAILED] Could not disable account."
            Write-Host $_.Exception.Message
            exit 1
        }
    }

    # --------------------------------------------------------
    # Remove group memberships
    # --------------------------------------------------------

    $Memberships = Get-MgUserMemberOf `
        -UserId $EntraUser.Id `
        -All

    foreach ($Membership in $Memberships) {

        $Group = Get-MgGroup `
            -GroupId $Membership.Id `
            -ErrorAction SilentlyContinue

        if (-not $Group) {
            continue
        }

        if ($PSCmdlet.ShouldProcess(
            "$DisplayName -> $($Group.DisplayName)",
            "Remove Leaver group membership"
        )) {

            try {

                Remove-MgGroupMemberByRef `
                    -GroupId $Group.Id `
                    -DirectoryObjectId $EntraUser.Id `
                    -ErrorAction Stop

                Write-Host "[REMOVED] $($Group.DisplayName)"
            }
            catch {

                Write-Host "[FAILED] Could not remove $($Group.DisplayName)"
                Write-Host $_.Exception.Message
            }
        }
    }
}

# ------------------------------------------------------------
# Complete
# ------------------------------------------------------------

Write-Host ""
Write-Host "----------------------------------------"
Write-Host "JML Lifecycle Action Complete"
Write-Host "----------------------------------------"
Write-Host "Action:     $Action"
Write-Host "Employee:   $DisplayName"
Write-Host "EmployeeID: $EmployeeID"
Write-Host "----------------------------------------"