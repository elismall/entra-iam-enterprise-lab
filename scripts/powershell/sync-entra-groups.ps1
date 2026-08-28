<#
.SYNOPSIS
Synchronizes security groups from groups.csv into Microsoft Entra ID.

.DESCRIPTION
Reads group definitions from data/groups.csv and synchronizes them
with Microsoft Entra ID through Microsoft Graph.

If a group does not exist, it is created.
If a group already exists, its managed description is updated when needed.
If the group already matches the CSV data, no changes are made.

The script is designed to be safely rerun without creating duplicates.

.EXAMPLE
.\scripts\powershell\sync-entra-groups.ps1 -WhatIf

.EXAMPLE
.\scripts\powershell\sync-entra-groups.ps1
#>

[CmdletBinding(SupportsShouldProcess = $true)]

param()

# ------------------------------------------------------------
# Locate repository files
# ------------------------------------------------------------

# Current script location:
# repo\scripts\powershell\sync-entra-groups.ps1
#
# Move up two directories to reach repository root.

$ScriptsFolder = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptsFolder

$CsvPath = Join-Path $RepoRoot "data\groups.csv"

if (-not (Test-Path $CsvPath -PathType Leaf)) {
    Write-Error "groups.csv was not found at: $CsvPath"
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

if ($Context.Scopes -notcontains "Group.ReadWrite.All") {
    Write-Error "The current Graph session does not include Group.ReadWrite.All."
    exit 1
}

Write-Host ""
Write-Host "Microsoft Graph connection verified."
Write-Host "Tenant: $($Context.TenantId)"
Write-Host ""

# ------------------------------------------------------------
# Import group data
# ------------------------------------------------------------

$Groups = Import-Csv -Path $CsvPath

Write-Host "Loaded $($Groups.Count) groups from groups.csv."
Write-Host ""

# ------------------------------------------------------------
# Retrieve existing Entra groups
# ------------------------------------------------------------

Write-Host "Checking existing Microsoft Entra groups..."

$ExistingGroups = Get-MgGroup `
    -All `
    -Property Id,DisplayName,Description,SecurityEnabled,MailEnabled

$ExistingGroupsByName = @{}

foreach ($ExistingGroup in $ExistingGroups) {

    if ($ExistingGroup.DisplayName) {

        $Key = $ExistingGroup.DisplayName.ToLowerInvariant()

        $ExistingGroupsByName[$Key] = $ExistingGroup
    }
}

Write-Host "Existing groups loaded."
Write-Host ""

# ------------------------------------------------------------
# Results counters
# ------------------------------------------------------------

$CreatedCount = 0
$UpdatedCount = 0
$UnchangedCount = 0
$FailedCount = 0

# ------------------------------------------------------------
# Process groups
# ------------------------------------------------------------

foreach ($Group in $Groups) {

    $GroupName = $Group.GroupName.Trim()
    $GroupType = $Group.GroupType.Trim()
    $Category = $Group.Category.Trim()
    $Purpose = $Group.Purpose.Trim()

    Write-Host "Processing: $GroupName"

    # --------------------------------------------------------
    # Validate supported group type
    # --------------------------------------------------------

    if ($GroupType -ne "Security") {

        Write-Host "  [FAILED] Unsupported group type: $GroupType"
        Write-Host ""

        $FailedCount++
        continue
    }

    # Store Category and Purpose together in Entra Description.

    $Description = "$Category | $Purpose"

    $GroupKey = $GroupName.ToLowerInvariant()

    # --------------------------------------------------------
    # Existing group
    # --------------------------------------------------------

    if ($ExistingGroupsByName.ContainsKey($GroupKey)) {

        $ExistingGroup = $ExistingGroupsByName[$GroupKey]

        # Ensure the existing object is actually a security group.

        if (-not $ExistingGroup.SecurityEnabled) {

            Write-Host "  [FAILED] Existing object is not a security group."
            Write-Host ""

            $FailedCount++
            continue
        }

        # ----------------------------------------------------
        # No update required
        # ----------------------------------------------------

        if ($ExistingGroup.Description -eq $Description) {

            Write-Host "  [UNCHANGED] Group already matches CSV data."
            Write-Host ""

            $UnchangedCount++
            continue
        }

        # ----------------------------------------------------
        # Update existing group
        # ----------------------------------------------------

        if ($PSCmdlet.ShouldProcess(
            $GroupName,
            "Update Microsoft Entra group description"
        )) {

            try {

                Update-MgGroup `
                    -GroupId $ExistingGroup.Id `
                    -Description $Description `
                    -ErrorAction Stop

                Write-Host "  [UPDATED] $GroupName"
                Write-Host ""

                $UpdatedCount++
            }
            catch {

                Write-Host "  [FAILED] $GroupName"
                Write-Host "  Error: $($_.Exception.Message)"
                Write-Host ""

                $FailedCount++
            }
        }

        continue
    }

    # --------------------------------------------------------
    # Create new security group
    # --------------------------------------------------------

    # Convert SG-IT-Users into something safe for mailNickname.
    # Example: sgitusers

    $MailNickname = [regex]::Replace(
        $GroupName.ToLowerInvariant(),
        "[^a-z0-9]",
        ""
    )

    $NewGroup = @{
        displayName     = $GroupName
        description     = $Description
        mailEnabled     = $false
        mailNickname    = $MailNickname
        securityEnabled = $true
        groupTypes      = @()
    }

    if ($PSCmdlet.ShouldProcess(
        $GroupName,
        "Create Microsoft Entra security group"
    )) {

        try {

            $CreatedGroup = New-MgGroup `
                -BodyParameter $NewGroup `
                -ErrorAction Stop

            Write-Host "  [CREATED] $GroupName"
            Write-Host "  Object ID: $($CreatedGroup.Id)"
            Write-Host ""

            $ExistingGroupsByName[$GroupKey] = $CreatedGroup

            $CreatedCount++
        }
        catch {

            Write-Host "  [FAILED] $GroupName"
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
Write-Host "Group Synchronization Complete"
Write-Host "----------------------------------------"
Write-Host "Created:   $CreatedCount"
Write-Host "Updated:   $UpdatedCount"
Write-Host "Unchanged: $UnchangedCount"
Write-Host "Failed:    $FailedCount"
Write-Host "----------------------------------------"