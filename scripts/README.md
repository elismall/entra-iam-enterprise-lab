# PowerShell Automation

This directory contains PowerShell scripts developed during the Small Srudios Enterprise IAM Lab.

The scripts are used to automate identity administration, Microsoft Graph operations, lifecycle management, and project evidence management.

## Scripts

### Publish-Screenshot.ps1

Utility script used to organize and publish implementation evidence.

The script:

- Locates screenshots stored in the Windows Screenshots directory
- Validates the requested evidence category
- Copies the screenshot into the appropriate repository folder
- Stages the file with Git
- Creates a Git commit
- Pushes the evidence to GitHub

Example:

`.\scripts\Publish-Screenshot.ps1 -Name "groups-01" -Category "groups"`

## Skills Practiced

- PowerShell parameterization
- Input validation
- File system operations
- Path management
- Error handling
- Git CLI integration
- Workflow automation
