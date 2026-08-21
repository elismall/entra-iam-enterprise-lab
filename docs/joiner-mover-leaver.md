# Joiner-Mover-Leaver Process

## Overview

Small Studios follows a **Joiner-Mover-Leaver (JML) process** to manage user identities throughout the employee lifecycle.

The process ensures that users:

- Receive appropriate access when joining the organization
- Have access updated when changing roles
- Do not accumulate unnecessary permissions
- Lose access promptly when leaving the organization
- Have identity changes documented and auditable


# Joiner Process
## Purpose

The Joiner process provisions a new employee identity and assigns access based on the employee's department and job responsibilities.

## Trigger

An approved new-hire request is received from Human Resources.

## Example Scenario

- **Employee:** Taylor Wilson
- **Employee ID:** 3003
- **Department:** Finance
- **Job Title:** Financial Analyst

## Provisioning Workflow

1. **Create Entra ID Account**
   - Create the employee's Microsoft Entra ID user account.
2. **Configure Identity Attributes**
   - Employee ID
   - Department
   - Job title
3. **Assign Department Access**
   - Add Taylor to `SG-Finance-Users`.
4. **Assign Role-Based Access**
   - Grant any additional access required for the Financial Analyst role.
5. **Configure Authentication**
   - Require MFA registration.
6. **Verify Access**
   - Confirm access to approved resources.
   - Confirm unauthorized resources remain inaccessible.
7. **Document Completion**
   - Record the completed provisioning request and any access assigned.

## Expected Result

Taylor Wilson receives only the access required to perform the Financial Analyst role.


# Mover Process

## Purpose

The Mover process updates an employee's identity and permissions when their department, job title, or responsibilities change.

## Trigger

An approved employee transfer, promotion, or role-change request is received from Human Resources.

## Example Scenario

- **Employee:** Taylor Wilson
- **Previous Department:** Finance
- **Previous Job Title:** Financial Analyst
- **New Department:** Information Technology
- **New Job Title:** Cloud Financial Analyst

## Access Change Workflow

1. **Review Existing Access**
   - Identify Taylor's current groups, roles, and resource permissions.
2. **Remove Obsolete Access**
   - Remove Taylor from `SG-Finance-Users`.
   - Remove any Finance-only permissions that are no longer required.
3. **Update Identity Attributes**
   - Change department.
   - Change job title.
   - Update manager if applicable.
4. **Assign New Access**
   - Add Taylor to `SG-IT-Users`.
   - Assign appropriate job-specific groups.
   - Review Azure RBAC requirements.
5. **Verify Permissions**
   - Confirm access to newly required resources.
   - Confirm old Finance access has been removed.
6. **Document Changes**
   - Record the role change and resulting permission changes.

## Security Consideration

A Mover process must remove obsolete permissions before or while granting new permissions.

Failing to remove previous access can cause ***access creep***, where users accumulate permissions that are no longer required.

## Expected Result

Taylor Wilson receives access appropriate for the new position without retaining unnecessary Finance permissions.


# Leaver Process

## Purpose

The Leaver process prevents former employees from accessing company resources while preserving required business data.

## Trigger

An approved termination or separation request is received from Human Resources.

## Example Scenario

- **Employee:** Marcus Reed
- **Employee ID:** 2002
- **Department:** Human Resources
- **Job Title:** HR Specialist

## Offboarding Workflow

1. **Disable Account**
   - Block the employee from signing in.
2. **Revoke Sessions**
   - Revoke active authentication sessions and tokens.
3. **Remove Access**
   - Remove security group memberships.
   - Remove application assignments.
   - Remove Azure RBAC assignments.
   - Remove privileged access.
4. **Review Data Ownership**
   - Identify company resources or data owned by the employee.
   - Transfer ownership where required.
5. **Document Offboarding**
   - Record all actions performed during termination.
6. **Retain or Delete Account**
   - Follow the organization's retention policy before permanent deletion.
  
## Expected Result


Marcus Reed can no longer authenticate to or access Northstar Technologies resources.


# JML Security Principles

**1. Least Privilege**
    - Users receive only the permissions required for their current responsibilities.
    
**2. Group-Based Access**
     - Access should be assigned through security groups whenever possible instead of directly to individual users.
     
**3. Access Removal**
     - Old permissions must be reviewed and removed whenever an employee changes roles.
     
**4. Separation of Duties**
     - Privileged permissions should only be assigned when required by the employee's responsibilities.
     
**5. Verification**
    - IAM administrators must verify that provisioning, access changes, and offboarding actions produced the expected results.
  
**6. Auditability** - Identity lifecycle changes should provide enough information to determine:
- Who was affected
- What changed
- Who performed the change
- When the change occurred
- Why the change occurred

# Future Automation

The initial JML processes will be completed manually to validate the workflow.

Future versions of the project will automate repetitive identity operations using:

- PowerShell
- Microsoft Graph
- CSV-based identity data

Future Workflow:

HR Identity Data
->
PowerShell
->
Microsoft Graph
->
Microsoft Entra ID
->
User Provisioning and Access Management
