# Firebase Data Setup Guide for Grow360

## Overview

This guide explains how to set up Firebase data for the Grow360 Employee Performance Tracker application. The setup creates all necessary collections and sample data for a software company environment.

## Prerequisites

1. Firebase project configured with Authentication and Firestore
2. Flutter app with Firebase dependencies installed
3. Firebase configuration files properly set up

## Setup Process

### Method 1: Using the App Interface (Recommended)

1. **Launch the App**
   - Run the Flutter app: `flutter run`
   - Navigate to the login screen

2. **Access Setup Screen**
   - On the login screen, you'll see a "Setup Firebase Data" button
   - Click this button to open the Firebase setup screen

3. **Run Setup**
   - Click the "Setup Firebase Data" button in the setup screen
   - Monitor the logs to see the progress
   - Wait for completion message

### Method 2: Programmatic Setup

You can also run the setup programmatically by calling:

```dart
final setup = FirebaseDataSetup();
await setup.setupCompleteData();
```

## What Gets Created

### 1. System Roles
- `super_admin` - Full access
- `hr_admin` - HR Administrator
- `manager` - Team Manager
- `employee` - Regular Employee
- `project_manager` - Project Manager

### 2. Departments
- Engineering (ENG)
- Quality Assurance (QA)
- DevOps & Infrastructure (DEVOPS)
- Product Management (PM)
- User Experience (UX)
- Data & Analytics (DATA)
- Human Resources (HR)
- Sales & Marketing (SALES)
- Finance & Operations (FIN)
- Research & Development (RND)
- Customer Success (CS)

### 3. Roles (Sample)
- Software Engineer Intern
- Junior Software Engineer
- Software Engineer
- Senior Software Engineer
- Lead Software Engineer
- Engineering Manager
- Director of Engineering
- QA Engineer
- Senior QA Engineer
- QA Lead
- DevOps Engineer
- Senior DevOps Engineer
- DevOps Lead
- HR Manager
- And many more...

### 4. Teams
- Frontend Platform Team
- Backend Services Team
- Mobile Development Team
- DevOps & Infrastructure
- Quality Engineering
- People Operations

### 5. Users and Employees

#### Backend Senior Developers
- **mukilan@ideas2it.com** (Admin@1234)
- **karthi@ideas2it.com** (Admin@1234)

#### Frontend Senior Developer
- **gautam@ideas2it.com** (Admin@1234)

#### DevOps Engineer
- **niranjan@ideas2it.com** (Admin@1234)

#### QA Engineers
- **ramiz@ideas2it.com** (Admin@1234) - Senior QA
- **lingesh@ideas2it.com** (Admin@1234) - QA Engineer
- **gomathi@ideas2it.com** (Admin@1234) - QA Engineer

#### Manager (Multi-team)
- **malai@ideas2it.com** (Admin@1234) - Engineering Manager
  - Manages both Frontend and Backend teams
  - Team members: Priya, Alex, Raj, Emily

#### HR Manager
- **jennifer@ideas2it.com** (Admin@1234)

#### Additional Team Members
- **priya@ideas2it.com** (Admin@1234) - Software Engineer
- **alex@ideas2it.com** (Admin@1234) - Software Engineer
- **raj@ideas2it.com** (Admin@1234) - Junior Software Engineer
- **emily@ideas2it.com** (Admin@1234) - Junior Software Engineer

### 6. Goal Categories
- Technical Skills
- Project Delivery
- Code Quality
- Leadership
- Learning & Growth
- Process Improvement

### 7. Projects
- E-Commerce Platform
- Mobile Banking App
- AI Analytics Dashboard

### 8. Goals
Sample goals created for each employee including:
- Code quality improvements
- Learning objectives
- Leadership development
- Project delivery milestones

## Collections Created

1. `system_roles` - System access roles
2. `departments` - Company departments
3. `roles` - Job roles and positions
4. `teams` - Team structures
5. `employees` - Employee records
6. `user_accounts` - User authentication data
7. `goals` - Employee goals and objectives
8. `goal_categories` - Goal classification
9. `projects` - Project information

## Test Scenarios

### Scenario 1: Single Manager, Multiple Teams
- **Manager**: Malai Vijay (malai@ideas2it.com)
- **Teams**: Frontend Platform Team, Backend Services Team
- **Team Members**: Priya, Alex, Raj, Emily
- **Use Case**: Demonstrates how one manager can oversee multiple teams

### Scenario 2: Different User Roles
- **Employees**: Regular employees with limited access
- **Managers**: Team managers with team oversight
- **HR Admin**: Jennifer Smith with HR privileges
- **Use Case**: Role-based access control demonstration

### Scenario 3: Goal Management
- Each employee has 2-3 goals
- Goals span different categories (Technical, Leadership, Learning)
- Progress tracking and measurement methods
- **Use Case**: Goal setting and tracking functionality

## Security Rules

Ensure your Firestore security rules allow:
- Read/write access for authenticated users
- Role-based access control
- Data validation

Example rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read their own data
    match /employees/{employeeId} {
      allow read: if request.auth != null && 
        (request.auth.uid == employeeId || 
         get(/databases/$(database)/documents/user_accounts/$(request.auth.uid)).data.role in ['manager', 'hr_admin', 'super_admin']);
    }
    
    // Allow managers to read team data
    match /employees/{employeeId} {
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/user_accounts/$(request.auth.uid)).data.role in ['manager', 'hr_admin', 'super_admin'];
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Check Firebase Authentication is enabled
   - Verify Firestore security rules
   - Ensure user is authenticated

2. **Collection Not Found**
   - Run setup only once
   - Check Firebase project configuration
   - Verify collection names in security rules

3. **User Creation Failed**
   - Check email format
   - Ensure password meets requirements
   - Verify Firebase Auth is properly configured

### Verification Steps

1. **Check Collections**
   ```bash
   # In Firebase Console
   Firestore Database > Collections
   ```

2. **Verify Users**
   ```bash
   # In Firebase Console
   Authentication > Users
   ```

3. **Test Login**
   - Try logging in with any test account
   - Verify role-based navigation works

## Data Structure

The setup creates a realistic software company structure with:
- **Hierarchical Organization**: Departments → Teams → Employees
- **Role-based Access**: Different permission levels
- **Goal Management**: Structured goal setting and tracking
- **Project Integration**: Goals linked to projects
- **Performance Tracking**: Progress measurement and reporting

## Next Steps

After setup:
1. Test login with different user accounts
2. Explore different dashboards based on user roles
3. Test goal creation and management
4. Verify team management functionality
5. Test reporting and analytics features

## Support

If you encounter issues:
1. Check Firebase Console for errors
2. Verify network connectivity
3. Review security rules
4. Check Flutter console for detailed logs
5. Ensure all Firebase dependencies are properly configured 