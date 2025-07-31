import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/employee_model.dart';
import '../models/goal_model.dart';

class Elevate360DataSetup {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get userAccounts => _firestore.collection('user_accounts');
  CollectionReference get departments => _firestore.collection('departments');
  CollectionReference get roles => _firestore.collection('roles');
  CollectionReference get teams => _firestore.collection('teams');
  CollectionReference get employees => _firestore.collection('employees');
  CollectionReference get goals => _firestore.collection('goals');
  CollectionReference get goalCategories => _firestore.collection('goal_categories');
  CollectionReference get reviews => _firestore.collection('reviews');
  CollectionReference get projects => _firestore.collection('projects');

  // Create all Elevate360 data
  Future<void> setupElevate360Data() async {
    try {
      print('🚀 Starting Elevate360 data setup...');
      
      // Step 1: Create system roles with refined permissions
      await _createSystemRoles();
      
      // Step 2: Create departments
      await _createDepartments();
      
      // Step 3: Create roles
      await _createRoles();
      
      // Step 4: Create teams
      await _createTeams();
      
      // Step 5: Create goal categories
      await _createGoalCategories();
      
      // Step 6: Create projects
      await _createProjects();
      
      // Step 7: Create users and employees with proper hierarchy
      await _createUsersAndEmployees();
      
      // Step 8: Create Q1 & Q2 2025 goals
      await _createGoals();
      
      // Step 9: Create reviews for Q1 & Q2 2025
      await _createReviews();
      
      print('✅ Elevate360 data setup completed successfully!');
    } catch (e) {
      print('❌ Error during Elevate360 data setup: $e');
      rethrow;
    }
  }

  // Create refined system roles
  Future<void> _createSystemRoles() async {
    print('📋 Creating system roles...');
    
    final roles = [
      {
        'role_name': 'employee',
        'description': 'Regular employee with self-management capabilities',
        'permissions': ['view_own_data', 'update_own_goals', 'submit_self_review', 'view_own_reports'],
        'created_at': Timestamp.now(),
      },
      {
        'role_name': 'manager',
        'description': 'Team manager with reportee oversight',
        'permissions': ['view_own_data', 'update_own_goals', 'submit_self_review', 'view_own_reports', 'view_reportees', 'assign_goals_to_reportees', 'review_reportees', 'manage_reportee_goals'],
        'created_at': Timestamp.now(),
      },
      {
        'role_name': 'hr_manager',
        'description': 'HR Manager with full employee oversight',
        'permissions': ['view_all_employees', 'manage_all_goals', 'conduct_all_reviews', 'view_all_reports', 'assign_goals_to_anyone', 'review_anyone', 'manage_salary_data'],
        'created_at': Timestamp.now(),
      },
      {
        'role_name': 'hr',
        'description': 'HR personnel with read-only cross-team access',
        'permissions': ['view_own_data', 'update_own_goals', 'submit_self_review', 'view_own_reports', 'view_cross_team_goals_readonly'],
        'created_at': Timestamp.now(),
      },
    ];

    for (final role in roles) {
      await _firestore.collection('system_roles').add(role);
    }
    
    print('✅ System roles created');
  }

  // Create departments
  Future<void> _createDepartments() async {
    print('🏢 Creating departments...');
    
    final deptData = [
      {'name': 'Engineering', 'code': 'ENG', 'description': 'Software Development and Engineering'},
      {'name': 'Quality Assurance', 'code': 'QA', 'description': 'Quality Assurance and Testing'},
      {'name': 'DevOps & Infrastructure', 'code': 'DEVOPS', 'description': 'DevOps, Infrastructure and Site Reliability'},
      {'name': 'Product Management', 'code': 'PM', 'description': 'Product Management and Strategy'},
      {'name': 'Human Resources', 'code': 'HR', 'description': 'Human Resources and People Operations'},
      {'name': 'Sales & Marketing', 'code': 'SALES', 'description': 'Sales, Marketing and Business Development'},
    ];

    for (final dept in deptData) {
      await departments.add({
        ...dept,
        'is_active': true,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    }
    
    print('✅ Departments created');
  }

  // Create roles
  Future<void> _createRoles() async {
    print('👔 Creating roles...');
    
    // Get department IDs
    final engDept = await _getDepartmentByCode('ENG');
    final qaDept = await _getDepartmentByCode('QA');
    final devopsDept = await _getDepartmentByCode('DEVOPS');
    final pmDept = await _getDepartmentByCode('PM');
    final hrDept = await _getDepartmentByCode('HR');
    final salesDept = await _getDepartmentByCode('SALES');

    final rolesData = [
      // Engineering Roles
      {
        'title': 'Software Engineer',
        'department_id': engDept,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 800000,
        'salary_range_max': 1400000,
        'is_management_role': false,
        'skills_required': ['Full Stack Development', 'System Design', 'Testing', 'Agile'],
      },
      {
        'title': 'Senior Software Engineer',
        'department_id': engDept,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 7,
        'salary_range_min': 1400000,
        'salary_range_max': 2200000,
        'is_management_role': false,
        'skills_required': ['Advanced Programming', 'Architecture', 'Mentoring', 'Code Review'],
      },
      {
        'title': 'Engineering Manager',
        'department_id': engDept,
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 5,
        'max_experience': 12,
        'salary_range_min': 2500000,
        'salary_range_max': 4000000,
        'is_management_role': true,
        'skills_required': ['People Management', 'Technical Strategy', 'Delivery Management'],
      },

      // QA Roles
      {
        'title': 'QA Engineer',
        'department_id': qaDept,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 700000,
        'salary_range_max': 1200000,
        'is_management_role': false,
        'skills_required': ['Test Automation', 'API Testing', 'Performance Testing'],
      },
      {
        'title': 'Senior QA Engineer',
        'department_id': qaDept,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 7,
        'salary_range_min': 1200000,
        'salary_range_max': 2000000,
        'is_management_role': false,
        'skills_required': ['Test Strategy', 'Framework Development', 'Mentoring'],
      },
      {
        'title': 'QA Manager',
        'department_id': qaDept,
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 6,
        'max_experience': 12,
        'salary_range_min': 2200000,
        'salary_range_max': 3500000,
        'is_management_role': true,
        'skills_required': ['People Management', 'Quality Assurance Strategy'],
      },

      // DevOps Roles
      {
        'title': 'DevOps Engineer',
        'department_id': devopsDept,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 900000,
        'salary_range_max': 1500000,
        'is_management_role': false,
        'skills_required': ['AWS/Azure', 'Docker', 'Kubernetes', 'CI/CD'],
      },
      {
        'title': 'Senior DevOps Engineer',
        'department_id': devopsDept,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 7,
        'salary_range_min': 1500000,
        'salary_range_max': 2500000,
        'is_management_role': false,
        'skills_required': ['Infrastructure as Code', 'Monitoring', 'Security'],
      },
      {
        'title': 'DevOps Manager',
        'department_id': devopsDept,
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 5,
        'max_experience': 10,
        'salary_range_min': 2400000,
        'salary_range_max': 3800000,
        'is_management_role': true,
        'skills_required': ['Infrastructure Strategy', 'Team Leadership'],
      },

      // HR Roles
      {
        'title': 'HR Executive',
        'department_id': hrDept,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 5,
        'salary_range_min': 600000,
        'salary_range_max': 1000000,
        'is_management_role': false,
        'skills_required': ['Recruitment', 'Employee Relations', 'HR Operations'],
      },
      {
        'title': 'HR Manager',
        'department_id': hrDept,
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 5,
        'max_experience': 10,
        'salary_range_min': 1800000,
        'salary_range_max': 2800000,
        'is_management_role': true,
        'skills_required': ['People Strategy', 'Team Management', 'Policy Development'],
      },

      // Sales Roles
      {
        'title': 'Sales Executive',
        'department_id': salesDept,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 500000,
        'salary_range_max': 800000,
        'is_management_role': false,
        'skills_required': ['Sales Process', 'CRM', 'Negotiation', 'Client Management'],
      },
      {
        'title': 'Sales Manager',
        'department_id': salesDept,
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 4,
        'max_experience': 8,
        'salary_range_min': 1200000,
        'salary_range_max': 2000000,
        'is_management_role': true,
        'skills_required': ['Sales Strategy', 'Team Leadership', 'Revenue Management'],
      },
    ];

    for (final role in rolesData) {
      await roles.add({
        ...role,
        'is_active': true,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    }
    
    print('✅ Roles created');
  }

  // Helper method to get department by code
  Future<String> _getDepartmentByCode(String code) async {
    final query = await departments.where('code', isEqualTo: code).limit(1).get();
    return query.docs.first.id;
  }

  // Helper method to get role by title
  Future<String> _getRoleByTitle(String title) async {
    final query = await roles.where('title', isEqualTo: title).limit(1).get();
    return query.docs.first.id;
  }

  // Create teams
  Future<void> _createTeams() async {
    print('👥 Creating teams...');
    
    final engDept = await _getDepartmentByCode('ENG');
    final qaDept = await _getDepartmentByCode('QA');
    final devopsDept = await _getDepartmentByCode('DEVOPS');
    final hrDept = await _getDepartmentByCode('HR');
    final salesDept = await _getDepartmentByCode('SALES');

    final teamsData = [
      {
        'name': 'Frontend Development Team',
        'department_id': engDept,
        'team_type': 'Development',
        'max_capacity': 8,
      },
      {
        'name': 'Backend Development Team',
        'department_id': engDept,
        'team_type': 'Development',
        'max_capacity': 10,
      },
      {
        'name': 'Quality Engineering Team',
        'department_id': qaDept,
        'team_type': 'QA',
        'max_capacity': 6,
      },
      {
        'name': 'Infrastructure Team',
        'department_id': devopsDept,
        'team_type': 'DevOps',
        'max_capacity': 5,
      },
      {
        'name': 'People Operations Team',
        'department_id': hrDept,
        'team_type': 'Support',
        'max_capacity': 4,
      },
      {
        'name': 'Sales Team',
        'department_id': salesDept,
        'team_type': 'Sales',
        'max_capacity': 6,
      },
    ];

    for (final team in teamsData) {
      await teams.add({
        ...team,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    }
    
    print('✅ Teams created');
  }

  // Create goal categories
  Future<void> _createGoalCategories() async {
    print('🎯 Creating goal categories...');
    
    final categories = [
      {
        'name': 'Productivity',
        'description': 'Goals related to improving work output and efficiency',
        'category_type': 'Performance',
        'color_code': '#FF6B6B',
        'is_active': true,
      },
      {
        'name': 'Skill Development',
        'description': 'Goals related to learning new technologies and skills',
        'category_type': 'Learning',
        'color_code': '#4ECDC4',
        'is_active': true,
      },
      {
        'name': 'Team Collaboration',
        'description': 'Goals related to improving teamwork and communication',
        'category_type': 'Leadership',
        'color_code': '#45B7D1',
        'is_active': true,
      },
      {
        'name': 'Quality',
        'description': 'Goals related to improving work quality and standards',
        'category_type': 'Quality',
        'color_code': '#96CEB4',
        'is_active': true,
      },
      {
        'name': 'Customer Satisfaction',
        'description': 'Goals related to improving customer experience and satisfaction',
        'category_type': 'Customer',
        'color_code': '#FFEAA7',
        'is_active': true,
      },
    ];

    for (final category in categories) {
      await goalCategories.add({
        ...category,
        'created_at': Timestamp.now(),
      });
    }
    
    print('✅ Goal categories created');
  }

  // Create projects
  Future<void> _createProjects() async {
    print('📋 Creating projects...');
    
    final projectsData = [
      {
        'name': 'E-Commerce Platform Enhancement',
        'code': 'ECOM-2025',
        'description': 'Enhance existing e-commerce platform with new features',
        'client_name': 'Retail Corp',
        'technology_stack': ['React', 'Node.js', 'MongoDB', 'AWS'],
        'start_date': DateTime(2025, 1, 1),
        'expected_end_date': DateTime(2025, 6, 30),
        'project_status': 'Active',
        'priority': 'High',
        'budget': 5000000,
      },
      {
        'name': 'Mobile Banking App Development',
        'code': 'BANK-2025',
        'description': 'Develop new mobile banking application',
        'client_name': 'Finance Bank',
        'technology_stack': ['Flutter', 'Firebase', 'Node.js', 'PostgreSQL'],
        'start_date': DateTime(2025, 2, 1),
        'expected_end_date': DateTime(2025, 8, 31),
        'project_status': 'Active',
        'priority': 'Critical',
        'budget': 8000000,
      },
      {
        'name': 'AI Analytics Dashboard',
        'code': 'AI-2025',
        'description': 'Develop AI-powered analytics dashboard',
        'client_name': 'Data Corp',
        'technology_stack': ['Python', 'TensorFlow', 'React', 'PostgreSQL'],
        'start_date': DateTime(2025, 3, 1),
        'expected_end_date': DateTime(2025, 9, 30),
        'project_status': 'Planning',
        'priority': 'Medium',
        'budget': 3000000,
      },
    ];

    for (final project in projectsData) {
      await projects.add({
        ...project,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    }
    
    print('✅ Projects created');
  }

  // Create users and employees with proper hierarchy
  Future<void> _createUsersAndEmployees() async {
    print('👤 Creating users and employees...');
    
    // Get department and role IDs
    final engDept = await _getDepartmentByCode('ENG');
    final qaDept = await _getDepartmentByCode('QA');
    final devopsDept = await _getDepartmentByCode('DEVOPS');
    final hrDept = await _getDepartmentByCode('HR');
    final salesDept = await _getDepartmentByCode('SALES');
    
    final softwareEngineerRole = await _getRoleByTitle('Software Engineer');
    final seniorSERole = await _getRoleByTitle('Senior Software Engineer');
    final engineeringManagerRole = await _getRoleByTitle('Engineering Manager');
    final qaEngineerRole = await _getRoleByTitle('QA Engineer');
    final seniorQARole = await _getRoleByTitle('Senior QA Engineer');
    final qaManagerRole = await _getRoleByTitle('QA Manager');
    final devOpsEngineerRole = await _getRoleByTitle('DevOps Engineer');
    final seniorDevOpsRole = await _getRoleByTitle('Senior DevOps Engineer');
    final devOpsManagerRole = await _getRoleByTitle('DevOps Manager');
    final hrExecutiveRole = await _getRoleByTitle('HR Executive');
    final hrManagerRole = await _getRoleByTitle('HR Manager');
    final salesExecutiveRole = await _getRoleByTitle('Sales Executive');
    final salesManagerRole = await _getRoleByTitle('Sales Manager');

    // Get team IDs
    final frontendTeam = await _getTeamByName('Frontend Development Team');
    final backendTeam = await _getTeamByName('Backend Development Team');
    final qaTeam = await _getTeamByName('Quality Engineering Team');
    final devOpsTeam = await _getTeamByName('Infrastructure Team');
    final hrTeam = await _getTeamByName('People Operations Team');
    final salesTeam = await _getTeamByName('Sales Team');

    // User data with proper hierarchy and roles
    final usersData = [
      // ===== ENGINEERING TEAM =====
      
      // Engineering Manager (Manages both Frontend and Backend teams)
      {
        'email': 'malai@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'manager',
        'employee_data': {
          'employee_id': 'EMP001',
          'first_name': 'Malai',
          'last_name': 'Vijay',
          'department_id': engDept,
          'role_id': engineeringManagerRole,
          'team_id': backendTeam, // Primary team
          'current_salary': 3200000,
          'work_location': 'Office',
          'hire_date': DateTime(2023, 6, 15),
        }
      },

      // Frontend Team Members (Managed by Malai)
      {
        'email': 'gautam@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP002',
          'first_name': 'Gautam',
          'last_name': 'Sharma',
          'department_id': engDept,
          'role_id': seniorSERole,
          'team_id': frontendTeam,
          'manager_id': 'EMP001', // Managed by Malai
          'current_salary': 1800000,
          'work_location': 'Hybrid',
          'hire_date': DateTime(2023, 8, 20),
        }
      },
      {
        'email': 'priya@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP003',
          'first_name': 'Priya',
          'last_name': 'Patel',
          'department_id': engDept,
          'role_id': softwareEngineerRole,
          'team_id': frontendTeam,
          'manager_id': 'EMP001', // Managed by Malai
          'current_salary': 1200000,
          'work_location': 'Remote',
          'hire_date': DateTime(2024, 1, 15),
        }
      },
      {
        'email': 'raj@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP004',
          'first_name': 'Raj',
          'last_name': 'Kumar',
          'department_id': engDept,
          'role_id': softwareEngineerRole,
          'team_id': frontendTeam,
          'manager_id': 'EMP001', // Managed by Malai
          'current_salary': 1100000,
          'work_location': 'Office',
          'hire_date': DateTime(2024, 3, 10),
        }
      },

      // Backend Team Members (Managed by Malai)
      {
        'email': 'mukilan@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP005',
          'first_name': 'Mukilan',
          'last_name': 'Kumar',
          'department_id': engDept,
          'role_id': seniorSERole,
          'team_id': backendTeam,
          'manager_id': 'EMP001', // Managed by Malai
          'current_salary': 1900000,
          'work_location': 'Hybrid',
          'hire_date': DateTime(2023, 9, 5),
        }
      },
      {
        'email': 'karthi@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP006',
          'first_name': 'Karthi',
          'last_name': 'Raj',
          'department_id': engDept,
          'role_id': seniorSERole,
          'team_id': backendTeam,
          'manager_id': 'EMP001', // Managed by Malai
          'current_salary': 1850000,
          'work_location': 'Office',
          'hire_date': DateTime(2023, 11, 20),
        }
      },
      {
        'email': 'alex@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP007',
          'first_name': 'Alex',
          'last_name': 'Chen',
          'department_id': engDept,
          'role_id': softwareEngineerRole,
          'team_id': backendTeam,
          'manager_id': 'EMP001', // Managed by Malai
          'current_salary': 1300000,
          'work_location': 'Remote',
          'hire_date': DateTime(2024, 2, 15),
        }
      },

      // ===== QA TEAM =====
      
      // QA Manager
      {
        'email': 'james@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'manager',
        'employee_data': {
          'employee_id': 'EMP008',
          'first_name': 'James',
          'last_name': 'Taylor',
          'department_id': qaDept,
          'role_id': qaManagerRole,
          'team_id': qaTeam,
          'current_salary': 2500000,
          'work_location': 'Office',
          'hire_date': DateTime(2023, 5, 10),
        }
      },

      // QA Team Members (Managed by James)
      {
        'email': 'ramiz@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP009',
          'first_name': 'Ramiz',
          'last_name': 'Khan',
          'department_id': qaDept,
          'role_id': seniorQARole,
          'team_id': qaTeam,
          'manager_id': 'EMP008', // Managed by James
          'current_salary': 1600000,
          'work_location': 'Hybrid',
          'hire_date': DateTime(2023, 7, 20),
        }
      },
      {
        'email': 'lingesh@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP010',
          'first_name': 'Lingesh',
          'last_name': 'Reddy',
          'department_id': qaDept,
          'role_id': qaEngineerRole,
          'team_id': qaTeam,
          'manager_id': 'EMP008', // Managed by James
          'current_salary': 950000,
          'work_location': 'Office',
          'hire_date': DateTime(2024, 1, 25),
        }
      },
      {
        'email': 'gomathi@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP011',
          'first_name': 'Gomathi',
          'last_name': 'Priya',
          'department_id': qaDept,
          'role_id': qaEngineerRole,
          'team_id': qaTeam,
          'manager_id': 'EMP008', // Managed by James
          'current_salary': 900000,
          'work_location': 'Remote',
          'hire_date': DateTime(2024, 3, 15),
        }
      },

      // ===== DEVOPS TEAM =====
      
      // DevOps Manager
      {
        'email': 'maria@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'manager',
        'employee_data': {
          'employee_id': 'EMP012',
          'first_name': 'Maria',
          'last_name': 'Rodriguez',
          'department_id': devopsDept,
          'role_id': devOpsManagerRole,
          'team_id': devOpsTeam,
          'current_salary': 2800000,
          'work_location': 'Office',
          'hire_date': DateTime(2023, 4, 15),
        }
      },

      // DevOps Team Members (Managed by Maria)
      {
        'email': 'niranjan@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP013',
          'first_name': 'Niranjan',
          'last_name': 'Patel',
          'department_id': devopsDept,
          'role_id': seniorDevOpsRole,
          'team_id': devOpsTeam,
          'manager_id': 'EMP012', // Managed by Maria
          'current_salary': 2100000,
          'work_location': 'Hybrid',
          'hire_date': DateTime(2023, 8, 10),
        }
      },
      {
        'email': 'chris@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP014',
          'first_name': 'Chris',
          'last_name': 'Lee',
          'department_id': devopsDept,
          'role_id': devOpsEngineerRole,
          'team_id': devOpsTeam,
          'manager_id': 'EMP012', // Managed by Maria
          'current_salary': 1200000,
          'work_location': 'Office',
          'hire_date': DateTime(2024, 2, 20),
        }
      },

      // ===== HR TEAM =====
      
      // HR Manager (Full oversight)
      {
        'email': 'jennifer@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'hr_manager',
        'employee_data': {
          'employee_id': 'EMP015',
          'first_name': 'Jennifer',
          'last_name': 'Smith',
          'department_id': hrDept,
          'role_id': hrManagerRole,
          'team_id': hrTeam,
          'current_salary': 2800000,
          'work_location': 'Office',
          'hire_date': DateTime(2023, 3, 1),
        }
      },

      // HR Executive (Non-manager, read-only access)
      {
        'email': 'sarah@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'hr',
        'employee_data': {
          'employee_id': 'EMP016',
          'first_name': 'Sarah',
          'last_name': 'Wilson',
          'department_id': hrDept,
          'role_id': hrExecutiveRole,
          'team_id': hrTeam,
          'manager_id': 'EMP015', // Managed by Jennifer
          'current_salary': 800000,
          'work_location': 'Hybrid',
          'hire_date': DateTime(2024, 1, 10),
        }
      },

      // ===== SALES TEAM =====
      
      // Sales Manager
      {
        'email': 'david@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'manager',
        'employee_data': {
          'employee_id': 'EMP017',
          'first_name': 'David',
          'last_name': 'Brown',
          'department_id': salesDept,
          'role_id': salesManagerRole,
          'team_id': salesTeam,
          'current_salary': 1800000,
          'work_location': 'Office',
          'hire_date': DateTime(2023, 7, 1),
        }
      },

      // Sales Team Members (Managed by David)
      {
        'email': 'emily@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP018',
          'first_name': 'Emily',
          'last_name': 'Davis',
          'department_id': salesDept,
          'role_id': salesExecutiveRole,
          'team_id': salesTeam,
          'manager_id': 'EMP017', // Managed by David
          'current_salary': 600000,
          'work_location': 'Office',
          'hire_date': DateTime(2024, 2, 1),
        }
      },
      {
        'email': 'michael@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP019',
          'first_name': 'Michael',
          'last_name': 'Johnson',
          'department_id': salesDept,
          'role_id': salesExecutiveRole,
          'team_id': salesTeam,
          'manager_id': 'EMP017', // Managed by David
          'current_salary': 650000,
          'work_location': 'Remote',
          'hire_date': DateTime(2024, 3, 15),
        }
      },
    ];

    // Create users and employees
    for (final userData in usersData) {
      await _createUserAndEmployee(userData);
    }
    
    print('✅ Users and employees created');
  }

  // Helper method to get team by name
  Future<String> _getTeamByName(String name) async {
    final query = await teams.where('name', isEqualTo: name).limit(1).get();
    return query.docs.first.id;
  }

  // Create user and employee
  Future<void> _createUserAndEmployee(Map<String, dynamic> userData) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );

      final uid = userCredential.user!.uid;

      // Create user account in Firestore
      final userAccount = UserModel(
        uid: uid,
        username: userData['email'].split('@')[0],
        email: userData['email'],
        role: userData['role'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      await userAccounts.doc(uid).set(userAccount.toFirestore());

      // Create employee record
      final employeeData = userData['employee_data'] as Map<String, dynamic>;
      final employee = EmployeeModel(
        id: uid,
        employeeId: employeeData['employee_id'] as String,
        userAccountId: uid,
        email: userData['email'] as String,
        firstName: employeeData['first_name'] as String,
        lastName: employeeData['last_name'] as String,
        hireDate: employeeData['hire_date'] as DateTime,
        departmentId: employeeData['department_id'] as String,
        roleId: employeeData['role_id'] as String,
        teamId: employeeData['team_id'] as String?,
        managerId: employeeData['manager_id'] as String?,
        employmentStatus: 'Active',
        employeeType: 'Full-time',
        workLocation: employeeData['work_location'] as String,
        currentSalary: (employeeData['current_salary'] as int).toDouble(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await employees.doc(uid).set(employee.toJson());

      print('✅ Created user and employee: ${userData['email']}');
    } catch (e) {
      print('❌ Error creating user ${userData['email']}: $e');
    }
  }

  // Create Q1 & Q2 2025 goals
  Future<void> _createGoals() async {
    print('🎯 Creating Q1 & Q2 2025 goals...');
    
    // Get employees for goal creation
    final employeesSnapshot = await employees.get();
    final employeesList = employeesSnapshot.docs;
    
    if (employeesList.isEmpty) {
      print('⚠️ No employees found for goal creation');
      return;
    }

    // Get goal categories
    final categoriesSnapshot = await goalCategories.get();
    final categories = categoriesSnapshot.docs;

    // Q1 2025 Goals Data
    final q1GoalsData = [
      {
        'title': 'Improve Code Quality Score',
        'description': 'Achieve 90% code coverage and reduce technical debt by 20%',
        'goal_type': 'Quarterly',
        'priority': 'High',
        'weightage': 25.0,
        'target_value': 90.0,
        'current_value': 75.0,
        'unit': 'percent',
        'measurement_method': 'Code coverage reports and SonarQube analysis',
        'start_date': DateTime(2025, 1, 1),
        'due_date': DateTime(2025, 3, 31),
        'status': 'In Progress',
        'progress_percentage': 60.0,
        'is_stretch_goal': false,
      },
      {
        'title': 'Complete Advanced React Course',
        'description': 'Complete advanced React patterns and state management course',
        'goal_type': 'Learning',
        'priority': 'Medium',
        'weightage': 15.0,
        'target_value': 100.0,
        'current_value': 40.0,
        'unit': 'percent',
        'measurement_method': 'Course completion certificates and assessments',
        'start_date': DateTime(2025, 1, 1),
        'due_date': DateTime(2025, 3, 31),
        'status': 'In Progress',
        'progress_percentage': 40.0,
        'is_stretch_goal': false,
      },
      {
        'title': 'Lead Code Review Sessions',
        'description': 'Conduct 20 code review sessions and mentor junior developers',
        'goal_type': 'Leadership',
        'priority': 'High',
        'weightage': 20.0,
        'target_value': 20.0,
        'current_value': 8.0,
        'unit': 'sessions',
        'measurement_method': 'Code review logs and feedback from team members',
        'start_date': DateTime(2025, 1, 1),
        'due_date': DateTime(2025, 3, 31),
        'status': 'In Progress',
        'progress_percentage': 40.0,
        'is_stretch_goal': false,
      },
      {
        'title': 'Implement CI/CD Pipeline',
        'description': 'Set up automated CI/CD pipeline for the project',
        'goal_type': 'Project-based',
        'priority': 'Critical',
        'weightage': 30.0,
        'target_value': 100.0,
        'current_value': 70.0,
        'unit': 'percent',
        'measurement_method': 'Pipeline success rate and deployment frequency',
        'start_date': DateTime(2025, 1, 1),
        'due_date': DateTime(2025, 3, 31),
        'status': 'In Progress',
        'progress_percentage': 70.0,
        'is_stretch_goal': false,
      },
      {
        'title': 'Reduce Bug Count by 50%',
        'description': 'Implement better testing practices to reduce production bugs',
        'goal_type': 'Quality',
        'priority': 'High',
        'weightage': 25.0,
        'target_value': 50.0,
        'current_value': 30.0,
        'unit': 'percent_reduction',
        'measurement_method': 'Bug tracking system and production incident reports',
        'start_date': DateTime(2025, 1, 1),
        'due_date': DateTime(2025, 3, 31),
        'status': 'In Progress',
        'progress_percentage': 60.0,
        'is_stretch_goal': false,
      },
    ];

    // Q2 2025 Goals Data
    final q2GoalsData = [
      {
        'title': 'Complete Microservices Architecture',
        'description': 'Implement microservices architecture for the e-commerce platform',
        'goal_type': 'Project-based',
        'priority': 'Critical',
        'weightage': 30.0,
        'target_value': 100.0,
        'current_value': 20.0,
        'unit': 'percent',
        'measurement_method': 'Architecture completion and deployment success',
        'start_date': DateTime(2025, 4, 1),
        'due_date': DateTime(2025, 6, 30),
        'status': 'In Progress',
        'progress_percentage': 20.0,
        'is_stretch_goal': false,
      },
      {
        'title': 'Improve Team Collaboration',
        'description': 'Increase team collaboration score by 25% through better communication',
        'goal_type': 'Team Collaboration',
        'priority': 'Medium',
        'weightage': 20.0,
        'target_value': 25.0,
        'current_value': 10.0,
        'unit': 'percent_increase',
        'measurement_method': 'Team feedback surveys and collaboration metrics',
        'start_date': DateTime(2025, 4, 1),
        'due_date': DateTime(2025, 6, 30),
        'status': 'In Progress',
        'progress_percentage': 40.0,
        'is_stretch_goal': false,
      },
      {
        'title': 'Customer Satisfaction Improvement',
        'description': 'Improve customer satisfaction score to 4.5/5',
        'goal_type': 'Customer Satisfaction',
        'priority': 'High',
        'weightage': 25.0,
        'target_value': 4.5,
        'current_value': 3.8,
        'unit': 'rating',
        'measurement_method': 'Customer feedback surveys and support tickets',
        'start_date': DateTime(2025, 4, 1),
        'due_date': DateTime(2025, 6, 30),
        'status': 'In Progress',
        'progress_percentage': 50.0,
        'is_stretch_goal': false,
      },
      {
        'title': 'Performance Optimization',
        'description': 'Improve application performance by 40%',
        'goal_type': 'Productivity',
        'priority': 'High',
        'weightage': 25.0,
        'target_value': 40.0,
        'current_value': 15.0,
        'unit': 'percent_improvement',
        'measurement_method': 'Performance monitoring tools and load testing',
        'start_date': DateTime(2025, 4, 1),
        'due_date': DateTime(2025, 6, 30),
        'status': 'In Progress',
        'progress_percentage': 35.0,
        'is_stretch_goal': false,
      },
    ];

    // Create goals for each employee for both quarters
    for (int i = 0; i < employeesList.length; i++) {
      final employee = employeesList[i];
      final employeeId = employee.id;
      
      // Get manager ID (use the first employee as manager for demo)
      final managerId = i == 0 ? employeeId : employeesList[0].id;
      
      // Create Q1 2025 goals (3-4 goals per employee)
      for (int j = 0; j < 4 && j < q1GoalsData.length; j++) {
        final goalData = q1GoalsData[j];
        final categoryId = categories.isNotEmpty ? categories[j % categories.length].id : null;
        
        final goal = GoalModel(
          id: 'q1_goal_${employeeId}_$j',
          employeeId: employeeId,
          managerId: managerId,
          categoryId: categoryId,
          title: goalData['title'] as String,
          description: goalData['description'] as String?,
          goalType: goalData['goal_type'] as String,
          priority: goalData['priority'] as String,
          weightage: (goalData['weightage'] as num).toDouble(),
          targetValue: (goalData['target_value'] as num?)?.toDouble(),
          currentValue: (goalData['current_value'] as num).toDouble(),
          unit: goalData['unit'] as String?,
          measurementMethod: goalData['measurement_method'] as String?,
          startDate: goalData['start_date'] as DateTime,
          dueDate: goalData['due_date'] as DateTime,
          status: goalData['status'] as String,
          progressPercentage: (goalData['progress_percentage'] as num).toDouble(),
          isStretchGoal: goalData['is_stretch_goal'] as bool,
          createdBy: managerId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await goals.doc(goal.id).set(goal.toJson());
      }

      // Create Q2 2025 goals (3-4 goals per employee)
      for (int j = 0; j < 4 && j < q2GoalsData.length; j++) {
        final goalData = q2GoalsData[j];
        final categoryId = categories.isNotEmpty ? categories[j % categories.length].id : null;
        
        final goal = GoalModel(
          id: 'q2_goal_${employeeId}_$j',
          employeeId: employeeId,
          managerId: managerId,
          categoryId: categoryId,
          title: goalData['title'] as String,
          description: goalData['description'] as String?,
          goalType: goalData['goal_type'] as String,
          priority: goalData['priority'] as String,
          weightage: (goalData['weightage'] as num).toDouble(),
          targetValue: (goalData['target_value'] as num?)?.toDouble(),
          currentValue: (goalData['current_value'] as num).toDouble(),
          unit: goalData['unit'] as String?,
          measurementMethod: goalData['measurement_method'] as String?,
          startDate: goalData['start_date'] as DateTime,
          dueDate: goalData['due_date'] as DateTime,
          status: goalData['status'] as String,
          progressPercentage: (goalData['progress_percentage'] as num).toDouble(),
          isStretchGoal: goalData['is_stretch_goal'] as bool,
          createdBy: managerId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await goals.doc(goal.id).set(goal.toJson());
      }
    }
    
    print('✅ Q1 & Q2 2025 goals created');
  }

  // Create reviews for Q1 & Q2 2025
  Future<void> _createReviews() async {
    print('📝 Creating Q1 & Q2 2025 reviews...');
    
    // Get employees for review creation
    final employeesSnapshot = await employees.get();
    final employeesList = employeesSnapshot.docs;
    
    if (employeesList.isEmpty) {
      print('⚠️ No employees found for review creation');
      return;
    }

    // Review data for Q1 2025
    final q1ReviewsData = [
      {
        'review_type': 'self_review',
        'rating': 4.0,
        'overall_rating': 4.2,
        'comments': 'Good progress on technical goals. Need to improve team collaboration.',
        'status': 'Completed',
        'submitted_date': DateTime(2025, 3, 25),
      },
      {
        'review_type': 'manager_review',
        'rating': 4.2,
        'overall_rating': 4.3,
        'comments': 'Strong technical performance. Shows good leadership potential.',
        'status': 'Completed',
        'submitted_date': DateTime(2025, 3, 28),
      },
      {
        'review_type': 'hr_review',
        'rating': 4.1,
        'overall_rating': 4.2,
        'comments': 'Well-rounded performance. Good alignment with company values.',
        'status': 'Completed',
        'submitted_date': DateTime(2025, 3, 30),
      },
    ];

    // Review data for Q2 2025
    final q2ReviewsData = [
      {
        'review_type': 'self_review',
        'rating': 4.3,
        'overall_rating': 4.4,
        'comments': 'Improved collaboration skills. Better project delivery.',
        'status': 'In Progress',
        'submitted_date': DateTime(2025, 6, 20),
      },
      {
        'review_type': 'manager_review',
        'rating': 4.4,
        'overall_rating': 4.5,
        'comments': 'Excellent growth in leadership. Strong technical contributions.',
        'status': 'Pending',
        'submitted_date': null,
      },
      {
        'review_type': 'hr_review',
        'rating': 4.2,
        'overall_rating': 4.3,
        'comments': 'Consistent performance. Good team player.',
        'status': 'Pending',
        'submitted_date': null,
      },
    ];

    // Create reviews for each employee for both quarters
    for (int i = 0; i < employeesList.length; i++) {
      final employee = employeesList[i];
      final employeeId = employee.id;
      
      // Get manager ID (use the first employee as manager for demo)
      final managerId = i == 0 ? employeeId : employeesList[0].id;
      
      // Create Q1 2025 reviews
      for (int j = 0; j < q1ReviewsData.length; j++) {
        final reviewData = q1ReviewsData[j];
        
        final review = {
          'id': 'q1_review_${employeeId}_$j',
          'employee_id': employeeId,
          'reviewer_id': j == 0 ? employeeId : managerId, // Self review or manager review
          'review_type': reviewData['review_type'] as String,
          'quarter': 'Q1 2025',
          'year': 2025,
          'rating': (reviewData['rating'] as num).toDouble(),
          'overall_rating': (reviewData['overall_rating'] as num).toDouble(),
          'comments': reviewData['comments'] as String,
          'status': reviewData['status'] as String,
          'submitted_date': reviewData['submitted_date'] as DateTime?,
          'created_at': DateTime.now(),
          'updated_at': DateTime.now(),
        };

        await reviews.doc(review['id'] as String).set(review);
      }

      // Create Q2 2025 reviews
      for (int j = 0; j < q2ReviewsData.length; j++) {
        final reviewData = q2ReviewsData[j];
        
        final review = {
          'id': 'q2_review_${employeeId}_$j',
          'employee_id': employeeId,
          'reviewer_id': j == 0 ? employeeId : managerId, // Self review or manager review
          'review_type': reviewData['review_type'] as String,
          'quarter': 'Q2 2025',
          'year': 2025,
          'rating': (reviewData['rating'] as num).toDouble(),
          'overall_rating': (reviewData['overall_rating'] as num).toDouble(),
          'comments': reviewData['comments'] as String,
          'status': reviewData['status'] as String,
          'submitted_date': reviewData['submitted_date'] as DateTime?,
          'created_at': DateTime.now(),
          'updated_at': DateTime.now(),
        };

        await reviews.doc(review['id'] as String).set(review);
      }
    }
    
    print('✅ Q1 & Q2 2025 reviews created');
  }
} 