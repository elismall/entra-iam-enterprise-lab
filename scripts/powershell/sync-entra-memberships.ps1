<#
.SYNOPSIS
Synchronizes user-to-group memberships in Microsoft Entra ID.

.DESCRIPTION
Reads group membership assignments from CSV and ensures each user belongs
to the required Microsoft Entra security groups.

Users are matched by EmployeeID.
Groups are matched by GroupName.

Existing memberships are left unchanged.
Missing memberships are created.
#>

[CmdletBinding(SupportsShouldProcess = $true)]

param()

# ------------------------------------------------------------
# Locate repository
# ------------------------------------------------------------

$ScriptsFolder = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptsFolder

# Support either filename while the repo is being organized.

$CsvCandidates = @(
    (Join-Path $RepoRoot "data\group-memberships.csv"),
    (Join-Path $RepoRoot "data\group-membership.csv")
)

$CsvPath = $CsvCandidates |
    Where-Object { Test-Path $_ } |
    Select-Object -First 1

if (-not $CsvPath) {

    Write-Error "Could not find group-memberships.csv or group-membership.csv."
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

$HasMembershipPermission = (
    $Context.Scopes -contains "GroupMember.ReadWrite.All" -or
    $Context.Scopes -contains "Group.ReadWrite.All"
)

if (-not $HasMembershipPermission) {

    Write-Error "Graph session requires GroupMember.ReadWrite.All or Group.ReadWrite.All."
    exit 1
}

Write-Host ""
Write-Host "Microsoft Graph connection verified."
Write-Host ""

# ------------------------------------------------------------
# Import assignments
# ------------------------------------------------------------

$Assignments = Import-Csv $CsvPath

Write-Host "Loaded $($Assignments.Count) membership assignments."
Write-Host ""

# ------------------------------------------------------------
# Load users
# ------------------------------------------------------------

Write-Host "Loading Entra users..."

$Users = Get-MgUser `
    -All `
    -Property Id,DisplayName,UserPrincipalName,EmployeeId

$UsersByEmployeeId = @{}

foreach ($User in $Users) {

    if ($User.EmployeeId) {

        $UsersByEmployeeId[
            $User.EmployeeId.ToString()
        ] = $User
    }
}

# ------------------------------------------------------------
# Load groups
# ------------------------------------------------------------

Write-Host "Loading Entra groups..."

$Groups = Get-MgGroup `
    -All `
    -Property Id,DisplayName

$GroupsByName = @{}

foreach ($Group in $Groups) {

    if ($Group.DisplayName) {

        $GroupsByName[
            $Group.DisplayName.ToLowerInvariant()
        ] = $Group
    }
}

Write-Host "Users and groups loaded."
Write-Host ""

# ------------------------------------------------------------
# Membership cache
# ------------------------------------------------------------

$MembershipCache = @{}

# ------------------------------------------------------------
# Counters
# ------------------------------------------------------------

$AddedCount = 0
$UnchangedCount = 0
$FailedCount = 0

# ------------------------------------------------------------
# Process assignments
# ------------------------------------------------------------

foreach ($Assignment in $Assignments) {

    $EmployeeId = $Assignment.EmployeeID.Trim()
    $UserName = $Assignment.UserName.Trim()
    $GroupName = $Assignment.GroupName.Trim()

    Write-Host "Processing: $UserName -> $GroupName"

    # --------------------------------------------------------
    # Find user
    # --------------------------------------------------------

    if (-not $UsersByEmployeeId.ContainsKey($EmployeeId)) {

        Write-Host "  [FAILED] EmployeeID not found: $EmployeeId"
        Write-Host ""

        $FailedCount++
        continue
    }

    $User = $UsersByEmployeeId[$EmployeeId]

    # --------------------------------------------------------
    # Find group
    # --------------------------------------------------------

    $GroupKey = $GroupName.ToLowerInvariant()

    if (-not $GroupsByName.ContainsKey($GroupKey)) {

        Write-Host "  [FAILED] Group not found: $GroupName"
        Write-Host ""

        $FailedCount++
        continue
    }

    $Group = $GroupsByName[$GroupKey]

    # --------------------------------------------------------
    # Load group memberships once
    # --------------------------------------------------------

    if (-not $MembershipCache.ContainsKey($Group.Id)) {

        $ExistingMembers = Get-MgGroupMember `
            -GroupId $Group.Id `
            -All

        $MemberIds = [System.Collections.Generic.HashSet[string]]::new()

        foreach ($Member in $ExistingMembers) {
            [void]$MemberIds.Add($Member.Id)
        }

        $MembershipCache[$Group.Id] = $MemberIds
    }

    $GroupMemberIds = $MembershipCache[$Group.Id]

    # --------------------------------------------------------
    # Existing membership
    # --------------------------------------------------------

    if ($GroupMemberIds.Contains($User.Id)) {

        Write-Host "  [UNCHANGED] Membership already exists."
        Write-Host ""

        $UnchangedCount++
        continue
    }

    # --------------------------------------------------------
    # Add membership
    # --------------------------------------------------------

    if ($PSCmdlet.ShouldProcess(
        "$UserName -> $GroupName",
        "Add Microsoft Entra group membership"
    )) {

        try {

            $MembershipBody = @{
                "@odata.id" =
                    "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)"
            }

            New-MgGroupMemberByRef `
                -GroupId $Group.Id `
                -BodyParameter $MembershipBody `
                -ErrorAction Stop

            [void]$GroupMemberIds.Add($User.Id)

            Write-Host "  [ADDED] $UserName -> $GroupName"
            Write-Host ""

            $AddedCount++
        }
        catch {

            Write-Host "  [FAILED] $UserName -> $GroupName"
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
Write-Host "Membership Synchronization Complete"
Write-Host "----------------------------------------"
Write-Host "Added:     $AddedCount"
Write-Host "Unchanged: $UnchangedCount"
Write-Host "Failed:    $FailedCount"
Write-Host "----------------------------------------"