# 🚀 Elevate360 Performance Management System

## 📋 Overview

Elevate360 is a comprehensive performance management system designed for modern software companies. It implements refined role-based access control, realistic organizational hierarchy, and detailed performance tracking for Q1 & Q2 2025.

## 🔐 Role-Based Access Control

### User Roles & Permissions

| Role | Responsibilities | Access Scope |
|------|------------------|--------------|
| **Employee** | • View & update self goals<br>• Perform self-reviews | **Own Data Only** |
| **Manager** | • Assign goals to reportees<br>• Review reportees<br>• Manage own goals and reviews | **Self + Direct Reportees** |
| **HR Manager** | • View all team goals<br>• Assign & review goals for all employees & managers<br>• Perform self-review | **All Teams + Self** |
| **HR (Non-Manager)** | • View goals of other teams<br>• View and manage own goals<br>• Self-review only | **Cross-Team (Read-Only) + Self** |

### Goal Management Rules

| Action | Employee | Manager | HR Manager | HR |
|--------|----------|---------|------------|-----|
| Set own goals | ✅ | ✅ | ✅ | ✅ |
| Assign goals to others | ❌ | ✅ (to reportees) | ✅ (to anyone) | ❌ |
| View goals of others | ❌ | ✅ (reportees only) | ✅ (all) | ✅ (all) |
| Edit goals of others | ❌ | ✅ (reportees only) | ✅ (all) | ❌ |

## 🏢 Organizational Structure

### Departments
- **Engineering** (ENG) - Software Development and Engineering
- **Quality Assurance** (QA) - Quality Assurance and Testing
- **DevOps & Infrastructure** (DEVOPS) - DevOps, Infrastructure and Site Reliability
- **Product Management** (PM) - Product Management and Strategy
- **Human Resources** (HR) - Human Resources and People Operations
- **Sales & Marketing** (SALES) - Sales, Marketing and Business Development

### Teams
- **Frontend Development Team** (8 members)
- **Backend Development Team** (10 members)
- **Quality Engineering Team** (6 members)
- **Infrastructure Team** (5 members)
- **People Operations Team** (4 members)
- **Sales Team** (6 members)

## 👥 User Hierarchy

### Engineering Team
- **Malai Vijay** (EMP001) - Engineering Manager
  - Manages both Frontend and Backend teams
  - **Frontend Team Members:**
    - Gautam Sharma (EMP002) - Senior Software Engineer
    - Priya Patel (EMP003) - Software Engineer
    - Raj Kumar (EMP004) - Software Engineer
  - **Backend Team Members:**
    - Mukilan Kumar (EMP005) - Senior Software Engineer
    - Karthi Raj (EMP006) - Senior Software Engineer
    - Alex Chen (EMP007) - Software Engineer

### QA Team
- **James Taylor** (EMP008) - QA Manager
  - **QA Team Members:**
    - Ramiz Khan (EMP009) - Senior QA Engineer
    - Lingesh Reddy (EMP010) - QA Engineer
    - Gomathi Priya (EMP011) - QA Engineer

### DevOps Team
- **Maria Rodriguez** (EMP012) - DevOps Manager
  - **DevOps Team Members:**
    - Niranjan Patel (EMP013) - Senior DevOps Engineer
    - Chris Lee (EMP014) - DevOps Engineer

### HR Team
- **Jennifer Smith** (EMP015) - HR Manager (Full oversight)
  - **HR Team Members:**
    - Sarah Wilson (EMP016) - HR Executive (Read-only access)

### Sales Team
- **David Brown** (EMP017) - Sales Manager
  - **Sales Team Members:**
    - Emily Davis (EMP018) - Sales Executive
    - Michael Johnson (EMP019) - Sales Executive

## 📅 Performance Data Periods

### Q1 2025 (Jan 1, 2025 – Mar 31, 2025)
- Goals assigned and their status
- Reviews submitted (self, manager, HR)
- Feedback notes and ratings

### Q2 2025 (Apr 1, 2025 – Jun 30, 2025)
- Goals assigned and their status
- Reviews submitted (self, manager, HR)
- Feedback notes and ratings

## 🎯 Goal Categories

1. **Productivity** - Goals related to improving work output and efficiency
2. **Skill Development** - Goals related to learning new technologies and skills
3. **Team Collaboration** - Goals related to improving teamwork and communication
4. **Quality** - Goals related to improving work quality and standards
5. **Customer Satisfaction** - Goals related to improving customer experience and satisfaction

## 📊 Sample Goals (Q1 & Q2 2025)

### Q1 2025 Goals
- **Improve Code Quality Score** - Achieve 90% code coverage and reduce technical debt by 20%
- **Complete Advanced React Course** - Complete advanced React patterns and state management course
- **Lead Code Review Sessions** - Conduct 20 code review sessions and mentor junior developers
- **Implement CI/CD Pipeline** - Set up automated CI/CD pipeline for the project
- **Reduce Bug Count by 50%** - Implement better testing practices to reduce production bugs

### Q2 2025 Goals
- **Complete Microservices Architecture** - Implement microservices architecture for the e-commerce platform
- **Improve Team Collaboration** - Increase team collaboration score by 25% through better communication
- **Customer Satisfaction Improvement** - Improve customer satisfaction score to 4.5/5
- **Performance Optimization** - Improve application performance by 40%

## 📝 Review System

### Review Types
1. **Self Review** - All users perform self-reviews
2. **Manager Review** - Managers review their direct reportees
3. **HR Manager Review** - HR Managers can review anyone (employees & managers)
4. **HR Review** - HR personnel can only perform self-reviews

### Review Status
- **Pending** - Review not yet submitted
- **In Progress** - Review being worked on
- **Completed** - Review submitted and finalized
- **Approved** - Review approved by higher authority

## 🚀 Setup Instructions

### Method 1: App Interface
1. Run the Flutter app: `flutter run`
2. Navigate to the login screen
3. Click "Setup Elevate360 Data" button
4. Monitor the setup progress in the logs
5. Wait for completion confirmation

### Method 2: Command Line
```bash
# Navigate to the project directory
cd elevate-360

# Run the setup script
flutter run -d chrome --target lib/scripts/elevate360_setup_script.dart
```

## 👤 Test Accounts

### Managers (Multi-team Access)
- **malai@ideas2it.com** (Admin@1234) - Engineering Manager
  - Manages both Frontend and Backend teams
  - Can assign goals and review 6 employees

### HR Managers (Full Access)
- **jennifer@ideas2it.com** (Admin@1234) - HR Manager
  - Can view and manage all goals and reviews
  - Full oversight of all teams

### Team Managers
- **james@ideas2it.com** (Admin@1234) - QA Manager
- **maria@ideas2it.com** (Admin@1234) - DevOps Manager
- **david@ideas2it.com** (Admin@1234) - Sales Manager

### HR Personnel (Read-only)
- **sarah@ideas2it.com** (Admin@1234) - HR Executive
  - Can view cross-team goals (read-only)
  - Can only manage own goals and reviews

### Employees
- **gautam@ideas2it.com** (Admin@1234) - Senior Software Engineer
- **mukilan@ideas2it.com** (Admin@1234) - Senior Software Engineer
- **karthi@ideas2it.com** (Admin@1234) - Senior Software Engineer
- **ramiz@ideas2it.com** (Admin@1234) - Senior QA Engineer
- **niranjan@ideas2it.com** (Admin@1234) - Senior DevOps Engineer
- And 9 more employees...

## 🔧 Technical Implementation

### Firebase Collections
- `user_accounts` - User authentication and role information
- `departments` - Department information
- `roles` - Job roles and responsibilities
- `teams` - Team information and structure
- `employees` - Employee profiles and hierarchy
- `goals` - Performance goals and tracking
- `goal_categories` - Goal categorization
- `reviews` - Performance reviews and feedback
- `projects` - Project information

### Data Models
- **UserModel** - User authentication and role management
- **EmployeeModel** - Employee profile and hierarchy
- **GoalModel** - Goal tracking and performance metrics

### Key Features
- **Role-based Access Control** - Granular permissions based on user roles
- **Multi-team Management** - Single manager covering multiple teams
- **Quarterly Performance Tracking** - Q1 & Q2 2025 data with realistic scenarios
- **Comprehensive Review System** - Self, manager, and HR reviews
- **Goal Categories** - 5 categories with measurable metrics

## 🎯 Testing Scenarios

### Scenario 1: Multi-team Manager
- Login as `malai@ideas2it.com`
- Verify access to both Frontend and Backend team members
- Assign goals to employees from both teams
- Review performance across teams

### Scenario 2: HR Manager Oversight
- Login as `jennifer@ideas2it.com`
- View all goals and reviews across all teams
- Assign goals to any employee or manager
- Review performance of managers and employees

### Scenario 3: HR Read-only Access
- Login as `sarah@ideas2it.com`
- View cross-team goals (read-only)
- Manage own goals and reviews only
- Verify limited access to other data

### Scenario 4: Team Manager
- Login as `james@ideas2it.com` (QA Manager)
- Manage QA team goals and reviews
- Verify access limited to QA team only

## 📈 Performance Metrics

### Goal Progress Tracking
- **Progress Percentage** - Real-time progress updates
- **Target vs Current Values** - Measurable goal tracking
- **Status Updates** - Not Started, In Progress, Completed, etc.

### Review Ratings
- **Individual Goal Ratings** - 1-5 scale per goal
- **Overall Performance Rating** - 1-5 scale overall
- **Comments and Feedback** - Detailed performance notes

## 🔒 Security Considerations

### Data Access Control
- **Employee Data** - Only HR Managers can view salary and sensitive data
- **Cross-team Access** - HR personnel have read-only access to other teams
- **Manager Hierarchy** - Managers can only access their direct reportees
- **Self-management** - All users can manage their own goals and reviews

### Authentication
- Firebase Authentication for secure login
- Role-based permissions enforced at application level
- Session management and secure token handling

## 🚀 Future Enhancements

### Planned Features
- **Advanced Analytics** - Performance trend analysis and reporting
- **Goal Templates** - Predefined goal templates for different roles
- **Automated Reviews** - Scheduled review reminders and notifications
- **Performance Calendars** - Visual timeline for goals and reviews
- **Mobile App** - Native mobile application for performance tracking
- **Integration APIs** - Connect with HRIS and project management tools

### Scalability
- **Multi-tenant Support** - Support for multiple organizations
- **Advanced Permissions** - More granular role-based access control
- **Real-time Notifications** - Push notifications for goal updates and reviews
- **Advanced Reporting** - Customizable dashboards and reports

## 📞 Support

For technical support or questions about the Elevate360 system:
- Check the setup logs for detailed error information
- Verify Firebase configuration and permissions
- Ensure all required dependencies are installed
- Review the role-based access implementation

---

**Elevate360 Performance Management System** - Empowering organizations with comprehensive performance tracking and role-based access control. 