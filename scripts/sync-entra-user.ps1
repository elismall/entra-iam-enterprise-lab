<#
.SYNOPSIS
Synchronizes IAM lab users from users.csv into Microsoft Entra ID.

.DESCRIPTION
Reads identity data from data/users.csv and creates missing Microsoft
Entra ID users through Microsoft Graph.

Existing users are detected by User Principal Name and skipped to prevent
duplicate account creation.

Temporary passwords are generated at runtime and are not written to the
repository or displayed in the console.

.PARAMETER TenantDomain
The Microsoft Entra tenant domain used to construct user principal names.

Example:
smallstudios.onmicrosoft.com

.EXAMPLE
.\scripts\Sync-Entra-User.ps1 `
    -TenantDomain "smallstudios.onmicrosoft.com" `
    -WhatIf

.EXAMPLE
.\scripts\Sync-Entra-User.ps1 `
    -TenantDomain "smallstudios.onmicrosoft.com"
#>

[CmdletBinding(SupportsShouldProcess = $true)]

param(
    [Parameter(Mandatory = $true)]
    [string]$TenantDomain
)

# ------------------------------------------------------------
# Locate repository files
# ------------------------------------------------------------

$RepoRoot = Split-Path -Parent $PSScriptRoot
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

$ExistingUsers = Get-MgUser -All -Property Id,UserPrincipalName

$ExistingUpns = @{}

foreach ($ExistingUser in $ExistingUsers) {

    if ($ExistingUser.UserPrincipalName) {
        $ExistingUpns[$ExistingUser.UserPrincipalName.ToLower()] = $true
    }
}

Write-Host "Existing users loaded."
Write-Host ""

# ------------------------------------------------------------
# Results counters
# ------------------------------------------------------------

$CreatedCount = 0
$SkippedCount = 0
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
    ).ToLower()

    $UserPrincipalName = "$MailNickname@$TenantDomain"

    Write-Host "Processing: $DisplayName"

    # --------------------------------------------------------
    # Skip existing accounts
    # --------------------------------------------------------

    if ($ExistingUpns.ContainsKey($UserPrincipalName.ToLower())) {

        Write-Host "  [SKIP] User already exists: $UserPrincipalName"
        Write-Host ""

        $SkippedCount++
        continue
    }

    # --------------------------------------------------------
    # Generate temporary password
    # --------------------------------------------------------

    $RandomValue = [guid]::NewGuid().ToString("N").Substring(0,12)

    $TemporaryPassword = "Aa!9$RandomValue"

    # --------------------------------------------------------
    # Build Graph user object
    # --------------------------------------------------------

    $NewUser = @{
        accountEnabled = $true

        displayName = $DisplayName

        givenName = $FirstName

        surname = $LastName

        mailNickname = $MailNickname

        userPrincipalName = $UserPrincipalName

        department = $User.Department

        jobTitle = $User.JobTitle

        employeeId = $User.EmployeeID

        usageLocation = "US"

        passwordProfile = @{
            password = $TemporaryPassword
            forceChangePasswordNextSignIn = $true
        }
    }

    # --------------------------------------------------------
    # Create Entra user
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

            $ExistingUpns[$UserPrincipalName.ToLower()] = $true

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

Write-Host "Created: $CreatedCount"
Write-Host "Skipped: $SkippedCount"
Write-Host "Failed:  $FailedCount"

Write-Host "----------------------------------------"