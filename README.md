# Microsoft Entra ID Enterprise IAM Lab

## Project Overview

- This project simulates the design and implementation of an enterprise Identity and Access Management environment for a fictional organization, Small Studios.

- Microsoft Entra ID is used as the primary identity platform to manage users, groups, access permissions, authentication, and identity lifecycle processes.

- The project focuses on applying real-world IAM concepts including least privilege, role-based access control, group-based access management, Joiner-Mover-Leaver processes, and identity automation.

## Project Objectives

- Design an enterprise identity architecture
- Manage users and security groups with Microsoft Entra ID
- Implement group-based access control
- Apply least privilege principles
- Design role-based access assignments
- Implement Joiner-Mover-Leaver processes
- Configure multi-factor authentication
- Manage Azure access using RBAC
- Automate identity administration with PowerShell and Microsoft Graph
- Review and audit identity activity

## Environment

- **Organization:** Small Studios
- **Identity Provider:** Microsoft Entra ID
- **Environment Type:** Cloud-first
- **Departments:**
  - Information Technology
  - Human Resources
  - Finance
  - Sales
  - Operations

## IAM Architecture

- The environment follows a group-based access model:
  
    - User > Security Group > Role/Permission > Resource

- Users receive baseline access based on department and additional permissions based on job responsibilities.

- Direct permission assignments to individual users are minimized whenever possible.

## Core IAM Principles

- Least Privilege
    - Users receive only the permissions required to perform their current job responsibilities.
- Group-Based Access
    - Permissions are assigned through security groups instead of directly to individual users whenever possible.
- Role-Based Access Control
    - Access is assigned according to business responsibilities and job roles.
- Identity Lifecycle Management
    - User access is managed through Joiner-Mover-Leaver processes.
- Privileged Access
    - Administrative permissions are separated from normal user access and limited to authorized personnel.

## Technologies

- Microsoft Entra ID
- Microsoft Azure
- Azure RBAC
- Microsoft Graph
- Microsoft Graph PowerShell
- PowerShell
- Git
- GitHub

## Repository Structure

### data/
Contains the structured identity and access data used throughout the lab.

- `users.csv` - Fictional employee identity data
- `groups.csv` - Security group definitions
- `group-memberships.csv` - Maps users to security groups
- `access-matrix.csv` - Defines access levels by job role

### docs/
Contains the design and process documentation for the IAM environment.

- `company-overview.md` - Business and organizational overview
- `identity-design.md` - IAM architecture and access-control design
- `access-control.md` - Access and authorization model
- `joiner-mover-leaver.md` - Identity lifecycle management procedures

### diagrams/
- Contains visual documentation of the IAM architecture and identity workflows.

### screenshots/
- Contains screenshots of Microsoft Entra ID configurations, testing, and implementation results.

### scripts/
- Contains PowerShell and Microsoft Graph scripts used to automate IAM operations.

### README.md
- Provides the main project overview, objectives, technologies, progress, and navigation.
## Identity Data

The lab contains fictional employee identities representing several business departments.

Identity information includes:

- Employee ID
- Name
- Department
- Job title
- Group membership
- Access requirements

The identity dataset is stored in:

`data/users.csv`

## Security Group Design

- Security groups follow the naming convention:

`SG-[Department or Resource]-[Purpose]`

Examples:

- `SG-IT-Users`
- `SG-HR-Users`
- `SG-IT-HelpDesk`
- `SG-Azure-Readers`
- `SG-Azure-Contributors`

Group definitions can be found in:

`data/groups.csv`

## Joiner-Mover-Leaver

The project implements three major identity lifecycle processes.

1. **Joiner** - Provision a new employee identity and assign appropriate access based on department and job role.
2. **Mover** - Modify an employee's identity and permissions when responsibilities change while removing access that is no longer required.
3. **Leaver** - Disable access, revoke sessions, remove permissions, and securely offboard employees leaving the organization.

Full documentation:

`docs/joiner-mover-leaver.md`

## PowerShell Automation

PowerShell is used throughout the lab to reduce repetitive administrative tasks and automate identity operations.

Automation includes:

- Microsoft Graph authentication
- User provisioning
- Security group creation
- Group membership management
- Joiner, mover, and leaver workflows
- Project evidence management

A reusable screenshot publishing utility was also developed to automatically organize implementation evidence, stage changes with Git, commit the evidence, and push it to GitHub.

See [`scripts/`](scripts/) for implementation details.

## Project Phases

### Phase 1 - IAM Design

- [x] Define fictional organization
- [x] Create employee dataset
- [x] Design security groups
- [x] Create access matrix
- [x] Document identity architecture
- [x] Design Joiner-Mover-Leaver processes

### Phase 2 - Microsoft Entra ID Implementation

- [ ] Create Entra ID environment
- [ ] Create users
- [ ] Create security groups
- [ ] Configure group memberships
- [ ] Configure identity attributes
- [ ] Test access assignments

### Phase 3 - Authentication and Authorization

- [ ] Configure MFA
- [ ] Implement Azure RBAC
- [ ] Validate least privilege
- [ ] Test user access

### Phase 4 - Identity Automation

- [ ] Connect to Microsoft Graph with PowerShell
- [ ] Automate user provisioning
- [ ] Automate group creation
- [ ] Automate group membership assignments
- [ ] Automate user offboarding

### Phase 5 - Application Identity

- [ ] Create an Entra App Registration
- [ ] Configure OAuth 2.0 / OpenID Connect
- [ ] Implement Microsoft authentication
- [ ] Explore Enterprise Applications and SSO

### Phase 6 - Advanced Identity Security

Future improvements may include:

- Conditional Access
- Privileged Identity Management
- Access Reviews
- Entitlement Management
- Microsoft Sentinel integration
- Hybrid Active Directory
- Microsoft Entra Cloud Sync

## Current Status

- The IAM architecture and identity datasets have been completed.

- The next phase of the project focuses on implementing the documented design within Microsoft Entra ID.

## Future Architecture

- A future version of the lab will introduce Windows Server Active Directory and hybrid identity.

  - On-Premises Active Directory > Microsoft Entra Cloud Sync > Microsoft Entra ID

- This will extend the project from a cloud-first IAM environment into a hybrid enterprise identity architecture.
