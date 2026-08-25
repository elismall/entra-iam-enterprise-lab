<#
.SYNOPSIS
Publishes IAM lab screenshots to the appropriate GitHub repository folder.

.DESCRIPTION
Copies a PNG screenshot from the current user's Windows Screenshots
directory into the appropriate evidence folder within the IAM lab repository.

The script dynamically determines:
- The repository root using $PSScriptRoot
- The current user's Pictures directory using the Windows environment

After copying the screenshot, the script:
- Stages the screenshot with Git
- Creates a Git commit
- Pushes the commit to GitHub

This design avoids hardcoded user-specific paths and allows the repository
to be moved or cloned to another compatible Windows environment.

.PARAMETER Name
The screenshot filename.

The .png extension is automatically added if it is not provided.

.PARAMETER Category
The evidence category where the screenshot should be stored.

Supported categories:
- authentication
- automation
- groups
- logs
- memberships
- rbac
- users

.PARAMETER CommitMessage
Optional custom Git commit message.

If no message is provided, the script automatically creates one.

.EXAMPLE
.\scripts\Publish-Screenshots.ps1 -Name "groups-01" -Category "groups"

.EXAMPLE
.\scripts\Publish-Screenshots.ps1 `
    -Name "rbac-01" `
    -Category "rbac" `
    -CommitMessage "Add Azure RBAC configuration evidence"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet(
        "authentication",
        "automation",
        "groups",
        "logs",
        "memberships",
        "rbac",
        "users"
    )]
    [string]$Category,

    [string]$CommitMessage = ""
)

# ------------------------------------------------------------
# Determine project locations dynamically
# ------------------------------------------------------------

# $PSScriptRoot points to:
# entra-iam-enterprise-lab\scripts
#
# Moving up one level gives us the repository root.
$RepoRoot = Split-Path -Parent $PSScriptRoot

# Dynamically locate the current user's Windows Pictures folder.
$PicturesFolder = [Environment]::GetFolderPath("MyPictures")

# Build the Windows Screenshots folder path.
$SourceFolder = Join-Path $PicturesFolder "Screenshots"

# ------------------------------------------------------------
# Prepare screenshot filename
# ------------------------------------------------------------

# Automatically add .png if the user did not include it.
if (-not $Name.EndsWith(".png", [System.StringComparison]::OrdinalIgnoreCase)) {
    $Name = "$Name.png"
}

# Build the complete source path.
$SourcePath = Join-Path $SourceFolder $Name

# Build the destination folder inside the repository.
$DestinationFolder = Join-Path $RepoRoot "screenshots\$Category"

# Build the complete destination path.
$DestinationPath = Join-Path $DestinationFolder $Name

# Git uses forward slashes for the repository-relative path.
$RelativePath = "screenshots/$Category/$Name"

# ------------------------------------------------------------
# Validate source screenshot
# ------------------------------------------------------------

if (-not (Test-Path $SourcePath -PathType Leaf)) {
    Write-Error "Screenshot not found: $SourcePath"
    exit 1
}

# ------------------------------------------------------------
# Validate destination folder
# ------------------------------------------------------------

if (-not (Test-Path $DestinationFolder -PathType Container)) {
    Write-Error "Destination folder does not exist: $DestinationFolder"
    exit 1
}

# ------------------------------------------------------------
# Copy screenshot into repository
# ------------------------------------------------------------

try {
    Copy-Item `
        -Path $SourcePath `
        -Destination $DestinationPath `
        -Force `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "Screenshot copied successfully."
    Write-Host "Source:      $SourcePath"
    Write-Host "Destination: $DestinationPath"
}
catch {
    Write-Error "Failed to copy screenshot: $($_.Exception.Message)"
    exit 1
}

# ------------------------------------------------------------
# Publish screenshot with Git
# ------------------------------------------------------------

Push-Location $RepoRoot

try {

    # Verify that this directory is actually a Git repository.
    git rev-parse --is-inside-work-tree *> $null

    if ($LASTEXITCODE -ne 0) {
        Write-Error "The repository root is not recognized as a Git repository."
        exit 1
    }

    # Stage only the screenshot being published.
    git add -- $RelativePath

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Git failed to stage the screenshot."
        exit 1
    }

    # Check whether the screenshot actually produced a Git change.
    git diff --cached --quiet -- $RelativePath

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "No Git changes detected for $RelativePath."
        Write-Host "The screenshot may already be up to date."
        exit 0
    }

    # Generate a commit message if one was not provided.
    if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
        $CommitMessage = "Add $Category screenshot: $Name"
    }

    # Commit only this screenshot.
    git commit --only -m $CommitMessage -- $RelativePath

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Git commit failed."
        exit 1
    }

    # Push the commit to GitHub.
    git push

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Git push failed."
        exit 1
    }

    Write-Host ""
    Write-Host "Screenshot published to GitHub successfully."
    Write-Host "File: $RelativePath"
    Write-Host "Commit: $CommitMessage"
}
finally {
    Pop-Location
}