class RoleConstants {
  // System Roles
  static const String SUPER_ADMIN = 'super_admin';
  static const String HR_ADMIN = 'hr_admin';
  static const String MANAGER = 'manager';
  static const String EMPLOYEE = 'employee';
  static const String PROJECT_MANAGER = 'project_manager';

  // Role Display Names
  static const Map<String, String> ROLE_DISPLAY_NAMES = {
    SUPER_ADMIN: 'Super Administrator',
    HR_ADMIN: 'HR Administrator',
    MANAGER: 'Manager',
    EMPLOYEE: 'Employee',
    PROJECT_MANAGER: 'Project Manager',
  };

  // Role Descriptions
  static const Map<String, String> ROLE_DESCRIPTIONS = {
    SUPER_ADMIN: 'Full system access with user management capabilities',
    HR_ADMIN: 'HR operations and employee management',
    MANAGER: 'Team management and performance tracking',
    EMPLOYEE: 'Basic employee access',
    PROJECT_MANAGER: 'Project-specific management',
  };

  // Permissions for each role
  static const Map<String, List<String>> ROLE_PERMISSIONS = {
    SUPER_ADMIN: [
      'all',
      'manage_users',
      'approve_hr_signups',
      'view_all_data',
      'manage_system_settings',
    ],
    HR_ADMIN: [
      'view_all_employees',
      'manage_reviews',
      'manage_goals',
      'view_reports',
      'manage_departments',
      'manage_employee_data',
    ],
    MANAGER: [
      'view_team_employees',
      'manage_team_goals',
      'conduct_reviews',
      'view_team_reports',
      'manage_team_performance',
    ],
    EMPLOYEE: [
      'view_own_data',
      'update_own_goals',
      'submit_reviews',
      'view_own_reports',
    ],
    PROJECT_MANAGER: [
      'view_project_team',
      'manage_project_goals',
      'view_project_reports',
      'manage_project_performance',
    ],
  };

  // Roles that can sign up (only HR for now)
  static const List<String> SIGNUP_ALLOWED_ROLES = [
    HR_ADMIN,
  ];

  // Roles that can approve HR signups
  static const List<String> APPROVAL_ALLOWED_ROLES = [
    SUPER_ADMIN,
  ];

  // Check if role can sign up
  static bool canSignUp(String role) {
    return SIGNUP_ALLOWED_ROLES.contains(role);
  }

  // Check if role can approve HR signups
  static bool canApproveHrSignups(String role) {
    return APPROVAL_ALLOWED_ROLES.contains(role);
  }

  // Get role display name
  static String getDisplayName(String role) {
    return ROLE_DISPLAY_NAMES[role] ?? role;
  }

  // Get role description
  static String getDescription(String role) {
    return ROLE_DESCRIPTIONS[role] ?? 'No description available';
  }

  // Get role permissions
  static List<String> getPermissions(String role) {
    return ROLE_PERMISSIONS[role] ?? [];
  }

  // Check if user has permission
  static bool hasPermission(String userRole, String permission) {
    final permissions = getPermissions(userRole);
    return permissions.contains('all') || permissions.contains(permission);
  }
} 