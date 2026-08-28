<#
.SYNOPSIS
Synchronizes IAM lab users from users.csv into Microsoft Entra ID.

.DESCRIPTION
Reads identity data from data/users.csv and synchronizes users with
Microsoft Entra ID through Microsoft Graph.

If a user does not exist, the script creates the account.

If a user already exists, the script compares the user's identity
attributes and updates them when necessary.

The script is designed to be safely re-run without creating duplicate
accounts.

Temporary passwords are generated at runtime and are never written to
the repository or displayed in the console.

.PARAMETER TenantDomain
The Microsoft Entra tenant domain used to construct user principal names.

.PARAMETER CompanyName
The company name assigned to synchronized users.

.EXAMPLE
.\scripts\powershell\sync-entra-users.ps1 `
    -TenantDomain "example.onmicrosoft.com" `
    -WhatIf

.EXAMPLE
.\scripts\powershell\sync-entra-users.ps1 `
    -TenantDomain "example.onmicrosoft.com"
#>

[CmdletBinding(SupportsShouldProcess = $true)]

param(
    [Parameter(Mandatory = $true)]
    [string]$TenantDomain,

    [string]$CompanyName = "Small Studios"
)

# ------------------------------------------------------------
# Locate repository files
# ------------------------------------------------------------

# Script location:
# repo\scripts\powershell\sync-entra-users.ps1
#
# Move up two folders to reach repository root.

$ScriptsFolder = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptsFolder

$CsvPath = Join-Path $RepoRoot "data\users.csv"

if (-not (Test-Path $CsvPath -PathType Leaf)) {
    Write-Error "users.csv was not found at: $CsvPath"
    exit 1
}

# ------------------------------------------------------------
# Verify Microsoft Graph connection
# ------------------------------------------------------------

$Context = Get-MgContext

if (-not $Context) {
    Write-Error "No Microsoft Graph connection detected."
    Write-Host "Connect to Microsoft Graph before running this script."
    exit 1
}

if ($Context.Scopes -notcontains "User.ReadWrite.All") {
    Write-Error "The current Graph session does not include User.ReadWrite.All."
    exit 1
}

Write-Host ""
Write-Host "Microsoft Graph connection verified."
Write-Host "Tenant: $($Context.TenantId)"
Write-Host ""

# ------------------------------------------------------------
# Import identity data
# ------------------------------------------------------------

$Users = Import-Csv -Path $CsvPath

Write-Host "Loaded $($Users.Count) users from users.csv."
Write-Host ""

# ------------------------------------------------------------
# Retrieve existing Entra users
# ------------------------------------------------------------

Write-Host "Checking existing Microsoft Entra users..."

$ExistingUsers = Get-MgUser `
    -All `
    -Property Id,DisplayName,GivenName,Surname,UserPrincipalName,Department,JobTitle,EmployeeId,CompanyName,UsageLocation

$ExistingUsersByUpn = @{}

foreach ($ExistingUser in $ExistingUsers) {

    if ($ExistingUser.UserPrincipalName) {

        $Key = $ExistingUser.UserPrincipalName.ToLowerInvariant()

        $ExistingUsersByUpn[$Key] = $ExistingUser
    }
}

Write-Host "Existing users loaded."
Write-Host ""

# ------------------------------------------------------------
# Results counters
# ------------------------------------------------------------

$CreatedCount = 0
$UpdatedCount = 0
$UnchangedCount = 0
$FailedCount = 0

# ------------------------------------------------------------
# Process users
# ------------------------------------------------------------

foreach ($User in $Users) {

    $FirstName = $User.FirstName.Trim()
    $LastName = $User.LastName.Trim()

    $DisplayName = "$FirstName $LastName"

    $MailNickname = (
        "$FirstName.$LastName"
    ).ToLowerInvariant()

    $UserPrincipalName = "$MailNickname@$TenantDomain"

    $UpnKey = $UserPrincipalName.ToLowerInvariant()

    Write-Host "Processing: $DisplayName"

    # --------------------------------------------------------
    # Existing user
    # --------------------------------------------------------

    if ($ExistingUsersByUpn.ContainsKey($UpnKey)) {

        $ExistingUser = $ExistingUsersByUpn[$UpnKey]

        # Determine whether any managed attributes need updating.

        $NeedsUpdate = (
            $ExistingUser.DisplayName   -ne $DisplayName -or
            $ExistingUser.GivenName     -ne $FirstName -or
            $ExistingUser.Surname       -ne $LastName -or
            $ExistingUser.Department    -ne $User.Department -or
            $ExistingUser.JobTitle      -ne $User.JobTitle -or
            $ExistingUser.EmployeeId    -ne $User.EmployeeID -or
            $ExistingUser.CompanyName   -ne $CompanyName -or
            $ExistingUser.UsageLocation -ne "US"
        )

        if (-not $NeedsUpdate) {

            Write-Host "  [UNCHANGED] User already matches identity data."
            Write-Host ""

            $UnchangedCount++
            continue
        }

        # ----------------------------------------------------
        # Build update object
        # ----------------------------------------------------

        $UpdateBody = @{
            displayName   = $DisplayName
            givenName     = $FirstName
            surname       = $LastName
            department    = $User.Department
            jobTitle      = $User.JobTitle
            employeeId    = $User.EmployeeID
            companyName   = $CompanyName
            usageLocation = "US"
        }

        # ----------------------------------------------------
        # Update existing user
        # ----------------------------------------------------

        if ($PSCmdlet.ShouldProcess(
            $UserPrincipalName,
            "Update Microsoft Entra ID user attributes"
        )) {

            try {

                Update-MgUser `
                    -UserId $ExistingUser.Id `
                    -BodyParameter $UpdateBody `
                    -ErrorAction Stop

                Write-Host "  [UPDATED] $UserPrincipalName"
                Write-Host ""

                $UpdatedCount++
            }
            catch {

                Write-Host "  [FAILED] $UserPrincipalName"
                Write-Host "  Error: $($_.Exception.Message)"
                Write-Host ""

                $FailedCount++
            }
        }

        continue
    }

    # --------------------------------------------------------
    # Generate temporary password for new user
    # --------------------------------------------------------

    $RandomValue = [guid]::NewGuid().ToString("N").Substring(0,12)

    $TemporaryPassword = "Aa!9$RandomValue"

    # --------------------------------------------------------
    # Build new user object
    # --------------------------------------------------------

    $NewUser = @{
        accountEnabled    = $true
        displayName       = $DisplayName
        givenName         = $FirstName
        surname           = $LastName
        mailNickname      = $MailNickname
        userPrincipalName = $UserPrincipalName
        department        = $User.Department
        jobTitle          = $User.JobTitle
        employeeId        = $User.EmployeeID
        companyName       = $CompanyName
        usageLocation     = "US"

        passwordProfile = @{
            password                      = $TemporaryPassword
            forceChangePasswordNextSignIn = $true
        }
    }

    # --------------------------------------------------------
    # Create new user
    # --------------------------------------------------------

    if ($PSCmdlet.ShouldProcess(
        $UserPrincipalName,
        "Create Microsoft Entra ID user"
    )) {

        try {

            $CreatedUser = New-MgUser `
                -BodyParameter $NewUser `
                -ErrorAction Stop

            Write-Host "  [CREATED] $UserPrincipalName"
            Write-Host "  Object ID: $($CreatedUser.Id)"
            Write-Host ""

            $ExistingUsersByUpn[$UpnKey] = $CreatedUser

            $CreatedCount++
        }
        catch {

            Write-Host "  [FAILED] $UserPrincipalName"
            Write-Host "  Error: $($_.Exception.Message)"
            Write-Host ""

            $FailedCount++
        }
    }
}

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "----------------------------------------"
Write-Host "User Synchronization Complete"
Write-Host "----------------------------------------"
Write-Host "Created:   $CreatedCount"
Write-Host "Updated:   $UpdatedCount"
Write-Host "Unchanged: $UnchangedCount"
Write-Host "Failed:    $FailedCount"
Write-Host "----------------------------------------"