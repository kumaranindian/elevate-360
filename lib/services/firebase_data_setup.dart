import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/employee_model.dart';
import '../models/goal_model.dart';

class FirebaseDataSetup {
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
  CollectionReference get projects => _firestore.collection('projects');

  // Create all master data and users
  Future<void> setupCompleteData() async {
    try {
      print('🚀 Starting Firebase data setup...');
      
      // Step 1: Create system roles
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
      
      // Step 7: Create users and employees
      await _createUsersAndEmployees();
      
      // Step 8: Create goals
      await _createGoals();
      
      print('✅ Firebase data setup completed successfully!');
    } catch (e) {
      print('❌ Error during Firebase data setup: $e');
      rethrow;
    }
  }

  // Create system roles
  Future<void> _createSystemRoles() async {
    print('📋 Creating system roles...');
    
    final roles = [
      {
        'role_name': 'super_admin',
        'description': 'Super Administrator with full access',
        'permissions': ['all'],
        'created_at': Timestamp.now(),
      },
      {
        'role_name': 'hr_admin',
        'description': 'HR Administrator',
        'permissions': ['view_all_employees', 'manage_reviews', 'manage_goals', 'view_reports', 'manage_departments'],
        'created_at': Timestamp.now(),
      },
      {
        'role_name': 'manager',
        'description': 'Team Manager',
        'permissions': ['view_team_employees', 'manage_team_goals', 'conduct_reviews', 'view_team_reports'],
        'created_at': Timestamp.now(),
      },
      {
        'role_name': 'employee',
        'description': 'Regular Employee',
        'permissions': ['view_own_data', 'update_own_goals', 'submit_reviews', 'view_own_reports'],
        'created_at': Timestamp.now(),
      },
      {
        'role_name': 'project_manager',
        'description': 'Project Manager',
        'permissions': ['view_project_team', 'manage_project_goals', 'view_project_reports'],
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
      {'name': 'User Experience', 'code': 'UX', 'description': 'UI/UX Design and User Research'},
      {'name': 'Data & Analytics', 'code': 'DATA', 'description': 'Data Science and Analytics'},
      {'name': 'Human Resources', 'code': 'HR', 'description': 'Human Resources and People Operations'},
      {'name': 'Sales & Marketing', 'code': 'SALES', 'description': 'Sales, Marketing and Business Development'},
      {'name': 'Finance & Operations', 'code': 'FIN', 'description': 'Finance, Operations and Administration'},
      {'name': 'Research & Development', 'code': 'RND', 'description': 'Research and Development'},
      {'name': 'Customer Success', 'code': 'CS', 'description': 'Customer Success and Support'},
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
    final uxDept = await _getDepartmentByCode('UX');
    final dataDept = await _getDepartmentByCode('DATA');
    final hrDept = await _getDepartmentByCode('HR');

    final rolesData = [
      // Engineering Roles
      {
        'title': 'Software Engineer Intern',
        'department_id': engDept,
        'level': 'Intern',
        'grade': 'L0',
        'min_experience': 0,
        'max_experience': 1,
        'salary_range_min': 20000,
        'salary_range_max': 35000,
        'is_management_role': false,
        'skills_required': ['Programming Basics', 'Git', 'Problem Solving'],
      },
      {
        'title': 'Junior Software Engineer',
        'department_id': engDept,
        'level': 'Junior',
        'grade': 'L1',
        'min_experience': 0,
        'max_experience': 2,
        'salary_range_min': 400000,
        'salary_range_max': 800000,
        'is_management_role': false,
        'skills_required': ['Java/Python/JavaScript', 'Git', 'Databases', 'Problem Solving'],
      },
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
        'title': 'Lead Software Engineer',
        'department_id': engDept,
        'level': 'Lead',
        'grade': 'L4',
        'min_experience': 6,
        'max_experience': 10,
        'salary_range_min': 2000000,
        'salary_range_max': 3000000,
        'is_management_role': true,
        'skills_required': ['Technical Leadership', 'Architecture', 'Team Management'],
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
      {
        'title': 'Director of Engineering',
        'department_id': engDept,
        'level': 'Director',
        'grade': 'D1',
        'min_experience': 12,
        'max_experience': 20,
        'salary_range_min': 5000000,
        'salary_range_max': 8000000,
        'is_management_role': true,
        'skills_required': ['Executive Leadership', 'Strategic Planning', 'Organizational Development'],
      },

      // QA Roles
      {
        'title': 'QA Intern',
        'department_id': qaDept,
        'level': 'Intern',
        'grade': 'L0',
        'min_experience': 0,
        'max_experience': 1,
        'salary_range_min': 18000,
        'salary_range_max': 30000,
        'is_management_role': false,
        'skills_required': ['Manual Testing', 'Bug Reporting', 'Test Cases'],
      },
      {
        'title': 'Junior QA Engineer',
        'department_id': qaDept,
        'level': 'Junior',
        'grade': 'L1',
        'min_experience': 0,
        'max_experience': 2,
        'salary_range_min': 350000,
        'salary_range_max': 700000,
        'is_management_role': false,
        'skills_required': ['Manual Testing', 'Automation Basics', 'SQL'],
      },
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
        'title': 'QA Lead',
        'department_id': qaDept,
        'level': 'Lead',
        'grade': 'L4',
        'min_experience': 5,
        'max_experience': 10,
        'salary_range_min': 1800000,
        'salary_range_max': 2800000,
        'is_management_role': true,
        'skills_required': ['Team Leadership', 'Quality Strategy', 'Process Improvement'],
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
        'title': 'DevOps Lead',
        'department_id': devopsDept,
        'level': 'Lead',
        'grade': 'L4',
        'min_experience': 5,
        'max_experience': 10,
        'salary_range_min': 2200000,
        'salary_range_max': 3200000,
        'is_management_role': true,
        'skills_required': ['Infrastructure Strategy', 'Team Leadership'],
      },
      {
        'title': 'Site Reliability Engineer',
        'department_id': devopsDept,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 3,
        'max_experience': 6,
        'salary_range_min': 1600000,
        'salary_range_max': 2600000,
        'is_management_role': false,
        'skills_required': ['System Reliability', 'Incident Management', 'Automation'],
      },

      // HR Roles
      {
        'title': 'HR Executive',
        'department_id': hrDept,
        'level': 'Junior',
        'grade': 'L1',
        'min_experience': 0,
        'max_experience': 2,
        'salary_range_min': 400000,
        'salary_range_max': 700000,
        'is_management_role': false,
        'skills_required': ['Recruitment', 'Employee Relations', 'HR Operations'],
      },
      {
        'title': 'HR Business Partner',
        'department_id': hrDept,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 5,
        'salary_range_min': 800000,
        'salary_range_max': 1400000,
        'is_management_role': false,
        'skills_required': ['Strategic HR', 'Performance Management', 'Organization Development'],
      },
      {
        'title': 'Senior HR Business Partner',
        'department_id': hrDept,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 8,
        'salary_range_min': 1400000,
        'salary_range_max': 2200000,
        'is_management_role': false,
        'skills_required': ['HR Strategy', 'Change Management', 'Leadership Development'],
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
      {
        'title': 'Director of People Operations',
        'department_id': hrDept,
        'level': 'Director',
        'grade': 'D1',
        'min_experience': 8,
        'max_experience': 15,
        'salary_range_min': 3000000,
        'salary_range_max': 5000000,
        'is_management_role': true,
        'skills_required': ['Strategic HR Leadership', 'Organizational Development'],
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

    final teamsData = [
      {
        'name': 'Frontend Platform Team',
        'department_id': engDept,
        'team_type': 'Development',
        'max_capacity': 8,
      },
      {
        'name': 'Backend Services Team',
        'department_id': engDept,
        'team_type': 'Development',
        'max_capacity': 10,
      },
      {
        'name': 'Mobile Development Team',
        'department_id': engDept,
        'team_type': 'Development',
        'max_capacity': 6,
      },
      {
        'name': 'DevOps & Infrastructure',
        'department_id': devopsDept,
        'team_type': 'DevOps',
        'max_capacity': 5,
      },
      {
        'name': 'Quality Engineering',
        'department_id': qaDept,
        'team_type': 'QA',
        'max_capacity': 8,
      },
      {
        'name': 'People Operations',
        'department_id': hrDept,
        'team_type': 'Support',
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
        'name': 'Technical Skills',
        'description': 'Goals related to technical skill development',
        'category_type': 'Technical',
        'color_code': '#FF6B6B',
        'is_active': true,
      },
      {
        'name': 'Project Delivery',
        'description': 'Goals related to project delivery and milestones',
        'category_type': 'Delivery',
        'color_code': '#4ECDC4',
        'is_active': true,
      },
      {
        'name': 'Code Quality',
        'description': 'Goals related to code quality and best practices',
        'category_type': 'Quality',
        'color_code': '#45B7D1',
        'is_active': true,
      },
      {
        'name': 'Leadership',
        'description': 'Goals related to leadership and mentoring',
        'category_type': 'Leadership',
        'color_code': '#96CEB4',
        'is_active': true,
      },
      {
        'name': 'Learning & Growth',
        'description': 'Goals related to learning new technologies',
        'category_type': 'Learning',
        'color_code': '#FFEAA7',
        'is_active': true,
      },
      {
        'name': 'Process Improvement',
        'description': 'Goals related to improving development processes',
        'category_type': 'Process',
        'color_code': '#DDA0DD',
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
        'name': 'E-Commerce Platform',
        'code': 'ECOM-001',
        'description': 'Modern e-commerce platform with React and Node.js',
        'client_name': 'Retail Corp',
        'technology_stack': ['React', 'Node.js', 'MongoDB', 'AWS'],
        'start_date': DateTime.now().subtract(const Duration(days: 30)),
        'expected_end_date': DateTime.now().add(const Duration(days: 90)),
        'project_status': 'Active',
        'priority': 'High',
        'budget': 5000000,
      },
      {
        'name': 'Mobile Banking App',
        'code': 'BANK-002',
        'description': 'Secure mobile banking application',
        'client_name': 'Finance Bank',
        'technology_stack': ['Flutter', 'Firebase', 'Node.js', 'PostgreSQL'],
        'start_date': DateTime.now().subtract(const Duration(days: 60)),
        'expected_end_date': DateTime.now().add(const Duration(days: 120)),
        'project_status': 'Active',
        'priority': 'Critical',
        'budget': 8000000,
      },
      {
        'name': 'AI Analytics Dashboard',
        'code': 'AI-003',
        'description': 'AI-powered analytics dashboard',
        'client_name': 'Data Corp',
        'technology_stack': ['Python', 'TensorFlow', 'React', 'PostgreSQL'],
        'start_date': DateTime.now().subtract(const Duration(days: 15)),
        'expected_end_date': DateTime.now().add(const Duration(days: 150)),
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

  // Create users and employees
  Future<void> _createUsersAndEmployees() async {
    print('👤 Creating users and employees...');
    
    // Get department and role IDs
    final engDept = await _getDepartmentByCode('ENG');
    final qaDept = await _getDepartmentByCode('QA');
    final devopsDept = await _getDepartmentByCode('DEVOPS');
    final hrDept = await _getDepartmentByCode('HR');
    
    final seniorSERole = await _getRoleByTitle('Senior Software Engineer');
    final leadSERole = await _getRoleByTitle('Lead Software Engineer');
    final engineeringManagerRole = await _getRoleByTitle('Engineering Manager');
    final seniorQARole = await _getRoleByTitle('Senior QA Engineer');
    final qaManagerRole = await _getRoleByTitle('QA Manager');
    final seniorDevOpsRole = await _getRoleByTitle('Senior DevOps Engineer');
    final devOpsLeadRole = await _getRoleByTitle('DevOps Lead');
    final hrManagerRole = await _getRoleByTitle('HR Manager');
    final directorHrRole = await _getRoleByTitle('Director of People Operations');

    // Get team IDs
    final frontendTeam = await _getTeamByName('Frontend Platform Team');
    final backendTeam = await _getTeamByName('Backend Services Team');
    final qaTeam = await _getTeamByName('Quality Engineering');
    final devOpsTeam = await _getTeamByName('DevOps & Infrastructure');
    final hrTeam = await _getTeamByName('People Operations');

    // User data with specified emails and password
    final usersData = [
      // Backend Senior Developers
      {
        'email': 'mukilan@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP001',
          'first_name': 'Mukilan',
          'last_name': 'Kumar',
          'department_id': engDept,
          'role_id': seniorSERole,
          'team_id': backendTeam,
          'current_salary': 1800000,
          'work_location': 'Hybrid',
          'hire_date': DateTime.now().subtract(const Duration(days: 365)),
        }
      },
      {
        'email': 'karthi@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP002',
          'first_name': 'Karthi',
          'last_name': 'Raj',
          'department_id': engDept,
          'role_id': seniorSERole,
          'team_id': backendTeam,
          'current_salary': 1900000,
          'work_location': 'Office',
          'hire_date': DateTime.now().subtract(const Duration(days: 400)),
        }
      },

      // Frontend Senior Developer
      {
        'email': 'gautam@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP003',
          'first_name': 'Gautam',
          'last_name': 'Sharma',
          'department_id': engDept,
          'role_id': seniorSERole,
          'team_id': frontendTeam,
          'current_salary': 1750000,
          'work_location': 'Remote',
          'hire_date': DateTime.now().subtract(const Duration(days: 320)),
        }
      },

      // DevOps Engineer
      {
        'email': 'niranjan@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP004',
          'first_name': 'Niranjan',
          'last_name': 'Patel',
          'department_id': devopsDept,
          'role_id': seniorDevOpsRole,
          'team_id': devOpsTeam,
          'current_salary': 2100000,
          'work_location': 'Hybrid',
          'hire_date': DateTime.now().subtract(const Duration(days: 280)),
        }
      },

      // QA Engineers
      {
        'email': 'ramiz@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP005',
          'first_name': 'Ramiz',
          'last_name': 'Khan',
          'department_id': qaDept,
          'role_id': seniorQARole,
          'team_id': qaTeam,
          'current_salary': 1600000,
          'work_location': 'Office',
          'hire_date': DateTime.now().subtract(const Duration(days: 450)),
        }
      },
      {
        'email': 'lingesh@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP006',
          'first_name': 'Lingesh',
          'last_name': 'Reddy',
          'department_id': qaDept,
          'role_id': 'qa_engineer_role_id', // Will be replaced
          'team_id': qaTeam,
          'current_salary': 950000,
          'work_location': 'Hybrid',
          'hire_date': DateTime.now().subtract(const Duration(days: 180)),
        }
      },
      {
        'email': 'gomathi@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'employee',
        'employee_data': {
          'employee_id': 'EMP007',
          'first_name': 'Gomathi',
          'last_name': 'Priya',
          'department_id': qaDept,
          'role_id': 'qa_engineer_role_id', // Will be replaced
          'team_id': qaTeam,
          'current_salary': 900000,
          'work_location': 'Remote',
          'hire_date': DateTime.now().subtract(const Duration(days: 150)),
        }
      },

      // Manager (covering multiple teams)
      {
        'email': 'malai@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'manager',
        'employee_data': {
          'employee_id': 'EMP008',
          'first_name': 'Malai',
          'last_name': 'Vijay',
          'department_id': engDept,
          'role_id': engineeringManagerRole,
          'team_id': backendTeam, // Primary team
          'current_salary': 3200000,
          'work_location': 'Office',
          'hire_date': DateTime.now().subtract(const Duration(days: 600)),
        }
      },

      // Additional team members for scenario
             {
         'email': 'priya@ideas2it.com',
         'password': 'Admin@1234',
         'role': 'employee',
         'employee_data': {
           'employee_id': 'EMP009',
           'first_name': 'Priya',
           'last_name': 'Sharma',
           'department_id': engDept,
           'role_id': 'software_engineer_role_id', // Will be replaced
           'team_id': frontendTeam,
           'manager_id': 'EMP008', // Managed by Malai
           'current_salary': 1100000,
           'work_location': 'Hybrid',
           'hire_date': DateTime.now().subtract(const Duration(days: 200)),
         }
       },
       {
         'email': 'alex@ideas2it.com',
         'password': 'Admin@1234',
         'role': 'employee',
         'employee_data': {
           'employee_id': 'EMP010',
           'first_name': 'Alex',
           'last_name': 'Chen',
           'department_id': engDept,
           'role_id': 'software_engineer_role_id', // Will be replaced
           'team_id': backendTeam,
           'manager_id': 'EMP008', // Managed by Malai
           'current_salary': 1200000,
           'work_location': 'Office',
           'hire_date': DateTime.now().subtract(const Duration(days: 180)),
         }
       },
       {
         'email': 'raj@ideas2it.com',
         'password': 'Admin@1234',
         'role': 'employee',
         'employee_data': {
           'employee_id': 'EMP011',
           'first_name': 'Raj',
           'last_name': 'Patel',
           'department_id': engDept,
           'role_id': 'junior_se_role_id', // Will be replaced
           'team_id': frontendTeam,
           'manager_id': 'EMP008', // Managed by Malai
           'current_salary': 650000,
           'work_location': 'Hybrid',
           'hire_date': DateTime.now().subtract(const Duration(days: 90)),
         }
       },
       {
         'email': 'emily@ideas2it.com',
         'password': 'Admin@1234',
         'role': 'employee',
         'employee_data': {
           'employee_id': 'EMP012',
           'first_name': 'Emily',
           'last_name': 'Davis',
           'department_id': engDept,
           'role_id': 'junior_se_role_id', // Will be replaced
           'team_id': backendTeam,
           'manager_id': 'EMP008', // Managed by Malai
           'current_salary': 700000,
           'work_location': 'Remote',
           'hire_date': DateTime.now().subtract(const Duration(days: 75)),
         }
       },

      // HR Manager
      {
        'email': 'jennifer@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'hr_admin',
        'employee_data': {
          'employee_id': 'EMP013',
          'first_name': 'Jennifer',
          'last_name': 'Smith',
          'department_id': hrDept,
          'role_id': hrManagerRole,
          'team_id': hrTeam,
          'current_salary': 2800000,
          'work_location': 'Office',
          'hire_date': DateTime.now().subtract(const Duration(days: 500)),
        }
      },

      // DevOps Lead
      {
        'email': 'maria@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'manager',
        'employee_data': {
          'employee_id': 'EMP014',
          'first_name': 'Maria',
          'last_name': 'Rodriguez',
          'department_id': devopsDept,
          'role_id': devOpsLeadRole,
          'team_id': devOpsTeam,
          'current_salary': 2800000,
          'work_location': 'Office',
          'hire_date': DateTime.now().subtract(const Duration(days: 400)),
        }
      },

      // QA Manager
      {
        'email': 'james@ideas2it.com',
        'password': 'Admin@1234',
        'role': 'manager',
        'employee_data': {
          'employee_id': 'EMP015',
          'first_name': 'James',
          'last_name': 'Taylor',
          'department_id': qaDept,
          'role_id': qaManagerRole,
          'team_id': qaTeam,
          'current_salary': 2500000,
          'work_location': 'Office',
          'hire_date': DateTime.now().subtract(const Duration(days: 350)),
        }
      },
    ];

          // Get additional role IDs
      final qaEngineerRole = await _getRoleByTitle('QA Engineer');
      final softwareEngineerRole = await _getRoleByTitle('Software Engineer');
      final juniorSERole = await _getRoleByTitle('Junior Software Engineer');

      // Create users and employees
      for (final userData in usersData) {
        // Replace placeholder role IDs
        final employeeData = userData['employee_data'] as Map<String, dynamic>;
        if (employeeData['role_id'] == 'qa_engineer_role_id') {
          employeeData['role_id'] = qaEngineerRole;
        } else if (employeeData['role_id'] == 'software_engineer_role_id') {
          employeeData['role_id'] = softwareEngineerRole;
        } else if (employeeData['role_id'] == 'junior_se_role_id') {
          employeeData['role_id'] = juniorSERole;
        }
        
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

  // Create goals
  Future<void> _createGoals() async {
    print('🎯 Creating goals...');
    
    // Get some employees for goal creation
    final employeesSnapshot = await employees.limit(10).get();
    final employeesList = employeesSnapshot.docs;
    
    if (employeesList.isEmpty) {
      print('⚠️ No employees found for goal creation');
      return;
    }

    // Get goal categories
    final categoriesSnapshot = await goalCategories.get();
    final categories = categoriesSnapshot.docs;

    final goalsData = [
      {
        'title': 'Improve Code Quality Score',
        'description': 'Achieve 90% code coverage and reduce technical debt',
        'goal_type': 'Quarterly',
        'priority': 'High',
        'weightage': 25.0,
        'target_value': 90.0,
        'current_value': 75.0,
        'unit': 'percent',
        'measurement_method': 'Code coverage reports and SonarQube analysis',
        'start_date': DateTime.now().subtract(const Duration(days: 30)),
        'due_date': DateTime.now().add(const Duration(days: 60)),
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
        'start_date': DateTime.now().subtract(const Duration(days: 45)),
        'due_date': DateTime.now().add(const Duration(days: 30)),
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
        'start_date': DateTime.now().subtract(const Duration(days: 60)),
        'due_date': DateTime.now().add(const Duration(days: 90)),
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
        'start_date': DateTime.now().subtract(const Duration(days: 20)),
        'due_date': DateTime.now().add(const Duration(days: 40)),
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
        'start_date': DateTime.now().subtract(const Duration(days: 15)),
        'due_date': DateTime.now().add(const Duration(days: 75)),
        'status': 'In Progress',
        'progress_percentage': 60.0,
        'is_stretch_goal': false,
      },
    ];

    // Create goals for each employee
    for (int i = 0; i < employeesList.length; i++) {
      final employee = employeesList[i];
      final employeeId = employee.id;
      
      // Get manager ID (use the first employee as manager for demo)
      final managerId = i == 0 ? employeeId : employeesList[0].id;
      
      // Create 2-3 goals per employee
      for (int j = 0; j < 3 && j < goalsData.length; j++) {
        final goalData = goalsData[j];
        final categoryId = categories.isNotEmpty ? categories[j % categories.length].id : null;
        
                 final goal = GoalModel(
           id: 'goal_${employeeId}_$j',
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
    
    print('✅ Goals created');
  }
} 