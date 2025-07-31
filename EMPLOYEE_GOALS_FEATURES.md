# Employee & Goals Management Features

## Overview
This document describes the Employee and Goals management functionality implemented for HR users in the Elevate-360 system.

## Features Implemented

### 1. Employee Management Screen

#### Key Features:
- **Employee Grid View**: Displays employee cards in a responsive grid layout
- **Search Functionality**: Search employees by name, email, or employee ID
- **Filter Options**: Filter by employment status (Active, On Leave, Probation, Inactive)
- **Employee Cards**: Each card shows:
  - Profile picture (initials)
  - Full name
  - Job title and department
  - Performance score (mock data)
  - Employment status with color-coded badges
- **Add Employee**: Button to create new employees (placeholder for future implementation)
- **Pagination**: Navigate through employee lists
- **Responsive Design**: Works on desktop and mobile

#### Employee Data Model:
- Employee ID, name, email, phone
- Department and role information
- Employment status and type
- Work location and salary
- Hire date and probation information
- Profile picture and social links

### 2. Goals Management Screen

#### Key Features:
- **Goals List View**: Displays goals in a card-based layout
- **Search Functionality**: Search goals by title or description
- **Status Filtering**: Filter by goal status (Not Started, In Progress, Completed, Overdue)
- **Category Filtering**: Filter by goal categories (Technical, Business Growth, Design & UX, etc.)
- **Progress Tracking**: Visual progress bars for each goal
- **Goal Details**: Click to view detailed information
- **Progress Updates**: Update goal progress with slider interface
- **Add Goal**: Button to create new goals (placeholder for future implementation)

#### Goal Data Model:
- Goal title, description, and category
- Employee assignment and manager
- Priority levels (Critical, High, Medium, Low)
- Progress tracking with percentages
- Due dates and completion status
- Target values and measurement units

### 3. Database Schema Integration

The implementation is based on the PostgreSQL schema provided in `grow360_schema.sql`:

#### Employee Tables:
- `employees`: Core employee information
- `departments`: Department structure
- `roles`: Job roles and levels
- `teams`: Team assignments
- `employment_history`: Career progression tracking

#### Goal Tables:
- `goals`: Goal definitions and progress
- `goal_categories`: Goal categorization
- `goal_milestones`: Goal milestone tracking
- `goal_progress_logs`: Progress history

### 4. Mock Data

For demonstration purposes, the system includes comprehensive mock data:

#### Employee Mock Data:
- 10 sample employees across different departments
- Various employment statuses (Active, On Leave, Probation)
- Different roles and departments
- Realistic salary ranges and hire dates

#### Goal Mock Data:
- 10 sample goals across different categories
- Various progress levels and statuses
- Different priorities and due dates
- Employee assignments and managers

### 5. UI/UX Features

#### Dark Theme Consistency:
- Matches the dashboard's dark theme
- Consistent color scheme and typography
- Professional appearance with teal accents

#### Responsive Design:
- Desktop: Full sidebar navigation
- Mobile: Bottom navigation and hamburger menu
- Adaptive grid layouts for different screen sizes

#### Interactive Elements:
- Hover effects on cards and buttons
- Loading states and error handling
- Smooth animations and transitions
- Toast notifications for user feedback

## Technical Implementation

### Architecture:
- **Models**: `EmployeeModel`, `GoalModel`, `GoalCategoryModel`
- **Services**: `EmployeeService`, `GoalService`
- **Screens**: `EmployeesScreen`, `GoalsScreen`
- **Integration**: Updated `DashboardScreen` for navigation

### State Management:
- Uses Riverpod for state management
- Local state for filtering and search
- Async data loading with error handling

### API Integration:
- HTTP service layer for API calls
- Mock data fallback for development
- Structured for easy backend integration

## Future Enhancements

### Planned Features:
1. **Employee Creation/Editing**: Full CRUD operations
2. **Goal Creation/Editing**: Complete goal management
3. **Performance Reviews**: Review cycle management
4. **Reports & Analytics**: Data visualization
5. **Notifications**: Real-time updates
6. **File Attachments**: Document management
7. **Advanced Filtering**: More filter options
8. **Export Functionality**: Data export capabilities

### Backend Integration:
- Connect to actual PostgreSQL database
- Implement authentication and authorization
- Add real-time updates with WebSockets
- Implement file upload/download
- Add email notifications

## Usage Instructions

### For HR Users:

1. **Accessing Employee Management**:
   - Login to the system
   - Navigate to "Employees" tab
   - Use search to find specific employees
   - Filter by status to view different employee groups

2. **Accessing Goals Management**:
   - Navigate to "Goals" tab
   - Search for specific goals
   - Filter by status or category
   - Click on goals to view details
   - Update progress using the slider interface

3. **Navigation**:
   - Desktop: Use sidebar navigation
   - Mobile: Use bottom navigation bar
   - Search functionality available in top bar

### Mock Data Access:
- All functionality works with mock data
- No backend connection required for testing
- Realistic data for demonstration purposes

## Development Notes

### Dependencies Added:
- `http: ^1.1.0` for API calls
- `uuid: ^4.2.1` for ID generation

### File Structure:
```
lib/
├── models/
│   ├── employee_model.dart
│   └── goal_model.dart
├── services/
│   ├── employee_service.dart
│   └── goal_service.dart
├── screens/
│   ├── employees_screen.dart
│   └── goals_screen.dart
└── core/utils/app_theme.dart
```

### Testing:
- All screens are fully functional with mock data
- Responsive design tested on different screen sizes
- Error handling implemented for network issues
- Loading states and user feedback included

This implementation provides a solid foundation for the HR management system and can be easily extended with additional features and backend integration. 