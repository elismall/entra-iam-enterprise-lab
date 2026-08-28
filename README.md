# Microsoft Entra ID Enterprise IAM Lab

## Project Overview

This project simulates the design and implementation of an enterprise Identity and Access Management (IAM) environment for a fictional organization, **Small Studios**.

Microsoft Entra ID is used as the primary identity platform for managing users, security groups, role-based access, identity lifecycle processes, and Azure resource permissions.

The project combines IAM design with hands-on administration and PowerShell automation using Microsoft Graph.

The environment demonstrates several real-world IAM concepts, including:

- Identity provisioning
- Group-based access control
- Role-Based Access Control (RBAC)
- Least privilege
- Joiner-Mover-Leaver lifecycle management
- Microsoft Graph automation
- Identity data synchronization
- Access reconciliation
- Idempotent PowerShell automation

---

## Project Objectives

- Design an enterprise IAM architecture
- Build structured identity datasets
- Provision users in Microsoft Entra ID
- Create and manage security groups
- Implement group-based access control
- Apply least privilege principles
- Implement Azure RBAC
- Automate identity administration with PowerShell
- Integrate PowerShell with Microsoft Graph
- Automate user provisioning and updates
- Automate security group creation
- Automate group membership assignments
- Demonstrate Joiner-Mover-Leaver workflows
- Validate identity and access assignments
- Document implementation evidence through GitHub

---

## Environment

- **Organization:** Small Studios
- **Identity Provider:** Microsoft Entra ID
- **Cloud Platform:** Microsoft Azure
- **Environment Type:** Cloud-first

### Departments

- Information Technology
- Human Resources
- Finance
- Sales
- Operations

---

## IAM Architecture

The environment follows a group-based access model:

```text
User
  |
  v
Security Group
  |
  v
Role / Permission
  |
  v
Resource
```

Users receive baseline access through department-based security groups and additional permissions based on job responsibilities.

Direct access assignments to individual users are minimized whenever possible.

---

## Core IAM Principles

### Least Privilege

Users receive only the permissions required to perform their current job responsibilities.

### Group-Based Access

Permissions are assigned through security groups instead of directly to individual users whenever possible.

### Role-Based Access Control

Access is assigned according to business responsibilities and job roles.

### Identity Lifecycle Management

Identity changes are managed through Joiner-Mover-Leaver workflows.

### Access Reconciliation

PowerShell automation compares source identity data with Microsoft Entra ID and creates, updates, or preserves objects based on their current state.

### Idempotent Automation

Automation scripts are designed to be safely rerun without creating duplicate users, groups, or memberships.

---

## Technologies

- Microsoft Entra ID
- Microsoft Azure
- Azure RBAC
- Microsoft Graph
- Microsoft Graph PowerShell SDK
- PowerShell 7
- CSV
- Git
- GitHub
- Visual Studio Code

---

## Repository Structure

```text
entra-iam-enterprise-lab/
|
+-- data/
|   +-- users.csv
|   +-- groups.csv
|   +-- group-memberships.csv
|   +-- access-matrix.csv
|
+-- docs/
|   +-- company-overview.md
|   +-- identity-design.md
|   +-- access-control.md
|   +-- joiner-mover-leaver.md
|
+-- diagrams/
|
+-- screenshots/
|   +-- authentication/
|   +-- automation/
|   +-- groups/
|   +-- logs/
|   +-- memberships/
|   +-- rbac/
|   +-- users/
|
+-- scripts/
|   |
|   +-- powershell/
|   |   +-- ss-automation.ps1
|   |   +-- sync-entra-users.ps1
|   |   +-- sync-entra-groups.ps1
|   |   +-- sync-entra-memberships.ps1
|   |   +-- jml-lifecycle.ps1
|   |
|   +-- one-liners/
|       +-- upload-screenshots.md
|       +-- sync-users.md
|
+-- README.md
```

---

## Identity Data

The lab contains fictional employee identities representing multiple business departments.

Identity attributes include:

- Employee ID
- First name
- Last name
- Department
- Job title
- Company
- Group membership
- Access requirements

The primary identity dataset is stored in:

```text
data/users.csv
```

This dataset acts as a source of identity information for PowerShell automation.

---

## Security Group Design

Security groups follow the naming convention:

```text
SG-[Department or Resource]-[Purpose]
```

Examples include:

```text
SG-IT-Users
SG-HR-Users
SG-IT-HelpDesk
SG-IT-CloudEngineers
SG-IT-Security
SG-Azure-Readers
SG-Azure-Contributors
```

Group definitions are stored in:

```text
data/groups.csv
```

The environment includes:

- Department groups
- Job-role groups
- Privileged groups
- Azure RBAC groups

---

## Azure RBAC

Azure resource access is assigned through Microsoft Entra security groups.

Example assignments include:

```text
SG-Azure-Readers
        |
        v
Azure Reader

SG-Azure-Contributors
        |
        v
Azure Contributor
```

RBAC assignments are scoped to approved Azure resources instead of assigning elevated access directly to individual users.

This supports centralized access management and least privilege.

---

## Microsoft Graph Integration

A Microsoft Entra App Registration was configured for PowerShell automation.

Microsoft Graph delegated permissions are used to automate identity administration.

The automation environment supports operations including:

- Reading users
- Creating users
- Updating user attributes
- Reading groups
- Creating security groups
- Updating security groups
- Reading group memberships
- Adding group memberships

Microsoft Graph provides the connection between the PowerShell automation layer and Microsoft Entra ID.

---

## PowerShell Automation

### User Synchronization

```text
scripts/powershell/sync-entra-users.ps1
```

The user synchronization script:

- Reads identities from `users.csv`
- Generates User Principal Names
- Detects existing users
- Creates missing identities
- Updates existing identity attributes
- Assigns company, department, job title, and employee ID
- Generates temporary passwords at runtime
- Prevents duplicate account creation
- Supports `-WhatIf`
- Provides synchronization results

Example workflow:

```text
users.csv
    |
    v
sync-entra-users.ps1
    |
    v
Microsoft Graph
    |
    v
Microsoft Entra ID
```

---

### Security Group Synchronization

```text
scripts/powershell/sync-entra-groups.ps1
```

The group synchronization script:

- Reads group definitions from `groups.csv`
- Detects existing security groups
- Creates missing groups
- Updates managed group attributes
- Prevents duplicate groups
- Supports `-WhatIf`
- Provides synchronization results

---

### Group Membership Synchronization

```text
scripts/powershell/sync-entra-memberships.ps1
```

The membership synchronization script:

- Reads assignments from `group-memberships.csv`
- Matches users by Employee ID
- Matches groups by group name
- Detects existing memberships
- Adds missing memberships
- Prevents duplicate assignments
- Supports repeatable access reconciliation

Example:

```text
group-memberships.csv
        |
        v
sync-entra-memberships.ps1
        |
        v
User + Security Group
        |
        v
Microsoft Entra ID
```

---

## Joiner-Mover-Leaver Lifecycle

Identity lifecycle management is demonstrated through:

```text
scripts/powershell/jml-lifecycle.ps1
```

### Joiner

The Joiner process demonstrates:

- User provisioning
- Identity attribute assignment
- Department assignment
- Job-role assignment
- Group-based access

Bulk user provisioning through `sync-entra-users.ps1` also demonstrates the Joiner process.

### Mover

The Mover process demonstrates:

- Department changes
- Job-title changes
- Removal of obsolete access
- Assignment of new access
- Prevention of access creep

Example scenario:

```text
Finance
   |
   | Mover
   v
Information Technology

Old Finance access removed
New IT access assigned
Identity attributes updated
```

### Leaver

The Leaver workflow demonstrates:

- Account disablement
- Removal of group memberships
- Access revocation
- Controlled identity offboarding

The project documentation also includes additional offboarding considerations such as session revocation, data ownership transfer, and account retention.

Full lifecycle documentation is available in:

```text
docs/joiner-mover-leaver.md
```

---

## Screenshot Automation

A reusable PowerShell utility was also created to organize project evidence:

```text
scripts/powershell/ss-automation.ps1
```

The script:

- Copies screenshots into the correct repository category
- Renames evidence consistently
- Stages the screenshot with Git
- Creates a Git commit
- Pushes the evidence to GitHub

This utility was created to reduce repetitive project administration while documenting the IAM implementation.

---

## Implementation Results

The completed lab includes:

- [x] Enterprise IAM architecture
- [x] Structured employee identity dataset
- [x] Security group design
- [x] Access matrix
- [x] Microsoft Entra ID environment
- [x] Microsoft Graph App Registration
- [x] Microsoft Graph PowerShell authentication
- [x] User provisioning
- [x] User attribute synchronization
- [x] Security group creation
- [x] Security group synchronization
- [x] Group membership synchronization
- [x] Azure RBAC assignments
- [x] Least-privilege access model
- [x] Joiner workflow
- [x] Mover workflow
- [x] Leaver workflow
- [x] Idempotent automation
- [x] Implementation screenshots
- [x] Git/GitHub project documentation

---

## Key Skills Demonstrated

This project demonstrates hands-on experience with:

- Identity and Access Management
- Microsoft Entra ID administration
- Microsoft Graph
- PowerShell automation
- User provisioning
- Identity lifecycle management
- Security group administration
- Group-based access control
- Azure RBAC
- Least privilege
- Access reconciliation
- Joiner-Mover-Leaver processes
- API permissions
- App Registrations
- Git version control
- Technical documentation
- Troubleshooting

---

## Security Considerations

The project follows several security practices:

- No passwords are stored in the repository
- Temporary passwords are generated at runtime
- Secrets and authentication tokens are excluded from source control
- Group-based access is preferred over direct user assignments
- Privileged access is separated from standard access
- Azure RBAC is scoped to approved resources
- Identity lifecycle changes include removal of obsolete access

---

## Project Status

**Status: Complete**

The core cloud IAM environment has been implemented and automated.

The project demonstrates identity design, Microsoft Entra administration, Microsoft Graph integration, PowerShell automation, Azure RBAC, group-based access management, and Joiner-Mover-Leaver lifecycle processes.

---

## Future Enhancements

Potential future improvements include:

- Multi-Factor Authentication policy testing
- Conditional Access
- Privileged Identity Management
- Access Reviews
- Entitlement Management
- Enterprise Application SSO
- Microsoft Sentinel integration
- Automated audit reporting
- Windows Server Active Directory
- Microsoft Entra Cloud Sync
- Hybrid identity

A future hybrid version could extend the architecture to:

```text
Windows Server Active Directory
            |
            v
Microsoft Entra Cloud Sync
            |
            v
Microsoft Entra ID
```