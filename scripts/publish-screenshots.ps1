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

# GitHub repository
$RepoRoot = "C:\Users\elija\OneDrive\Documents\github repo\entra-iam-enterprise-lab"

# Windows screenshot location
$SourceFolder = "C:\Users\elija\OneDrive\Pictures\Screenshots"

# Add .png automatically if not provided
if (-not $Name.EndsWith(".png")) {
    $Name = "$Name.png"
}

$SourcePath = Join-Path $SourceFolder $Name
$DestinationFolder = Join-Path $RepoRoot "screenshots\$Category"
$DestinationPath = Join-Path $DestinationFolder $Name
$RelativePath = "screenshots/$Category/$Name"

# Make sure screenshot exists
if (-not (Test-Path $SourcePath -PathType Leaf)) {
    Write-Error "Screenshot not found: $SourcePath"
    exit 1
}

# Make sure GitHub destination folder exists
if (-not (Test-Path $DestinationFolder -PathType Container)) {
    Write-Error "GitHub folder does not exist: $DestinationFolder"
    exit 1
}

# Copy screenshot into GitHub repo
Copy-Item $SourcePath $DestinationPath -Force

Write-Host "Copied screenshot to:"
Write-Host $DestinationPath

# Move into repository
Set-Location $RepoRoot

# Add only this screenshot
git add -- $RelativePath

# Default commit message
if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    $CommitMessage = "Add $Category screenshot: $Name"
}

# Commit only this screenshot
git commit --only $RelativePath -m $CommitMessage

# Push to GitHub
git push

Write-Host ""
Write-Host "Screenshot published to GitHub successfully."
Write-Host $RelativePath
