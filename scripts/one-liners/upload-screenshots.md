# PowerShell One-Liners

## Publish Screenshot

Template:

`.\scripts\powershell\ss-automation.ps1 -Name "PHOTO-NAME" -Category "FOLDER"`

Example:

`.\scripts\powershell\ss-automation.ps1 -Name "groups-01" -Category "groups"`

# Git Workflow

Use this workflow after making changes in VS Code that you want to publish to GitHub.

## 1. Add

Stage the changes you want included in the next commit.

Use case: You created or updated files inside the `one-liners` folder.

```powershell
git add scripts/one-liners/
```

## 2. Status

Check that the correct changes are staged before committing.

```powershell
git status
```

Look for the files under:

```text
Changes to be committed:
```

## 3. Commit

Save the staged changes as a Git commit.

Use case: You updated your one-liner scripts and documentation.

```powershell
git commit -m "Update one-liner scripts"
```

## 4. Push

Send the new commit from your local repository to GitHub.

```powershell
git push
```

## Quick Workflow

```powershell
git add scripts/one-liners/
git status
git commit -m "Update one-liner scripts"
git push
```