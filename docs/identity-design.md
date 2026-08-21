# Small Studios Identity Design

## 1. Overview

Small Studios uses Microsoft Entra ID as its primary cloud identity and access management platform.

The IAM environment is designed around the principles of:

- Least privilege
- Role-based access control
- Group-based access assignment
- Separation of standard and privileged access
- Multi-factor authentication
- Identity lifecycle management
- Auditable access changes

The initial environment is cloud-first. Hybrid identity with Windows Server Active Directory may be added in a future phase.

## 2. Identity Source

Microsoft Entra ID is the authoritative identity platform for the initial deployment.

All employee identities are created and managed within Microsoft Entra ID.

Future architecture may include:

On-Premises Active Directory
        |
Microsoft Entra Cloud Sync
        |
Microsoft Entra ID

## 3. User Account Structure

Each employee receives an individual user account.

User accounts contain identity attributes including:

- Employee ID
- First name
- Last name
- Display name
- Job title
- Department
- Manager
- User principal name

Shared user accounts should not be used for normal employee access.

## 4. Group Naming Convention

Security groups use the following naming convention:

SG-[Department or Resource]-[Purpose]

Examples:

SG-IT-Users
SG-HR-Users
SG-IT-HelpDesk
SG-Azure-Readers
SG-Azure-Contributors

The SG prefix identifies the object as a security group.

## 5. Access Control Model

Northstar Technologies primarily assigns access through security groups.

The preferred access model is:

User
  |
  v
Security Group
  |
  v
Role or Permission
  |
  v
Resource

Direct permission assignments to individual users should be minimized.

This improves:

- Access consistency
- Administration
- Auditing
- Offboarding
- Role changes

## 6. Department-Based Access

Employees receive membership in the security group associated with their department.

Examples:

Human Resources
-> SG-HR-Users

Finance
-> SG-Finance-Users

Information Technology
-> SG-IT-Users

Sales
-> SG-Sales-Users

Operations
-> SG-Operations-Users

Department membership provides baseline access associated with the employee's business unit.

## 7. Job-Based Access

Additional access may be granted based on job responsibilities.

Examples:

Help Desk Analyst
-> SG-IT-HelpDesk

Cloud Engineer
-> SG-IT-CloudEngineers

Security Analyst
-> SG-IT-Security

IT Administrator
-> SG-IT-Admins

Department membership alone does not automatically provide administrative privileges.

## 8. Azure Resource Access

Azure permissions are separated from department and job-role groups.

Examples:

SG-Azure-Readers
-> Azure Reader permissions

SG-Azure-Contributors
-> Azure Contributor permissions

This allows Azure access to be assigned according to job requirements without directly assigning permissions to individual users.

## 9. Least Privilege

Users receive only the access necessary to perform their assigned job responsibilities.

Access should not be granted solely because another employee in the same department has that permission.

Elevated access must have a documented business requirement.

## 10. Privileged Access

Privileged administrative permissions are separated from normal employee access wherever practical.

Privileged access should:

- Be limited to authorized personnel
- Require multi-factor authentication
- Be reviewed regularly
- Avoid unnecessary permanent assignments
- Be monitored through audit logs

Future phases may implement Microsoft Entra Privileged Identity Management for just-in-time administrative access.

## 11. Authentication

Multi-factor authentication will be used to reduce the risk of account compromise.

The project will initially use the authentication controls available within the lab's Microsoft Entra licensing.

More advanced Conditional Access policies may be implemented in a future phase.

## 12. Identity Lifecycle

Northstar Technologies follows a Joiner-Mover-Leaver model.

Joiner:
A new identity is created and receives access based on department and job responsibilities.

Mover:
Existing access is reviewed, unnecessary permissions are removed, and new permissions are assigned.

Leaver:
Access is disabled and removed when an employee leaves the organization.

## 13. Logging and Auditing

Identity-related administrative activity should be auditable.

Relevant events include:

- User creation
- User modification
- User disablement
- Group membership changes
- Role assignments
- Authentication activity
- Administrative changes

Microsoft Entra audit and sign-in logs will be used during later phases of the project.

## 14. Future Improvements

Future phases of the project may include:

- Windows Server Active Directory
- Hybrid identity
- Microsoft Entra Cloud Sync
- Conditional Access
- Privileged Identity Management
- Access Reviews
- Entitlement Management
- Automated provisioning with Microsoft Graph PowerShell
- SIEM integration with Microsoft Sentinel
