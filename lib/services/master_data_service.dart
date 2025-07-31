import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MasterDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Insert master data from SQL schema into Firebase
  static Future<bool> insertMasterData() async {
    try {
      await _insertSystemRoles();
      await _insertDepartments();
      await _insertRoles();
      await _insertTeams();
      await _insertGoalCategories();
      await _insertSampleEmployees();
      await _insertSampleUserAccounts();
      
      return true;
    } catch (e) {
      throw Exception('Failed to insert master data: $e');
    }
  }

  static Future<void> _insertSystemRoles() async {
    final roles = [
      {
        'role_name': 'super_admin',
        'description': 'Super Administrator with full access',
        'permissions': ['all'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'role_name': 'hr_admin',
        'description': 'HR Administrator',
        'permissions': ['view_all_employees', 'manage_reviews', 'manage_goals', 'view_reports', 'manage_departments'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'role_name': 'manager',
        'description': 'Team Manager',
        'permissions': ['view_team_employees', 'manage_team_goals', 'conduct_reviews', 'view_team_reports'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'role_name': 'employee',
        'description': 'Regular Employee',
        'permissions': ['view_own_data', 'update_own_goals', 'submit_reviews', 'view_own_reports'],
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'role_name': 'project_manager',
        'description': 'Project Manager',
        'permissions': ['view_project_team', 'manage_project_goals', 'view_project_reports'],
        'created_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final role in roles) {
      await _firestore.collection('system_roles').add(role);
    }
  }

  static Future<void> _insertDepartments() async {
    final departments = [
      {
        'name': 'Engineering',
        'code': 'ENG',
        'description': 'Software Development and Engineering',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Quality Assurance',
        'code': 'QA',
        'description': 'Quality Assurance and Testing',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'DevOps & Infrastructure',
        'code': 'DEVOPS',
        'description': 'DevOps, Infrastructure and Site Reliability',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Product Management',
        'code': 'PM',
        'description': 'Product Management and Strategy',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'User Experience',
        'code': 'UX',
        'description': 'UI/UX Design and User Research',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Data & Analytics',
        'code': 'DATA',
        'description': 'Data Science and Analytics',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Human Resources',
        'code': 'HR',
        'description': 'Human Resources and People Operations',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sales & Marketing',
        'code': 'SALES',
        'description': 'Sales, Marketing and Business Development',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Finance & Operations',
        'code': 'FIN',
        'description': 'Finance, Operations and Administration',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Research & Development',
        'code': 'RND',
        'description': 'Research and Development',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Customer Success',
        'code': 'CS',
        'description': 'Customer Success and Support',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final dept in departments) {
      await _firestore.collection('departments').add(dept);
    }
  }

  static Future<void> _insertRoles() async {
    // Get department IDs first
    final deptSnapshot = await _firestore.collection('departments').get();
    final deptDocs = deptSnapshot.docs;
    
    final engDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'ENG');
    final qaDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'QA');
    final devopsDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'DEVOPS');
    final pmDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'PM');
    final uxDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'UX');
    final dataDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'DATA');
    final hrDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'HR');

    final roles = [
      // Engineering Roles
      {
        'title': 'Software Engineer Intern',
        'department_id': engDept.id,
        'level': 'Intern',
        'grade': 'L0',
        'min_experience': 0,
        'max_experience': 1,
        'salary_range_min': 20000,
        'salary_range_max': 35000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Junior Software Engineer',
        'department_id': engDept.id,
        'level': 'Junior',
        'grade': 'L1',
        'min_experience': 0,
        'max_experience': 2,
        'salary_range_min': 400000,
        'salary_range_max': 800000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Software Engineer',
        'department_id': engDept.id,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 800000,
        'salary_range_max': 1400000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Senior Software Engineer',
        'department_id': engDept.id,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 7,
        'salary_range_min': 1400000,
        'salary_range_max': 2200000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Lead Software Engineer',
        'department_id': engDept.id,
        'level': 'Lead',
        'grade': 'L4',
        'min_experience': 6,
        'max_experience': 10,
        'salary_range_min': 2000000,
        'salary_range_max': 3000000,
        'is_management_role': true,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Engineering Manager',
        'department_id': engDept.id,
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 5,
        'max_experience': 12,
        'salary_range_min': 2500000,
        'salary_range_max': 4000000,
        'is_management_role': true,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Director of Engineering',
        'department_id': engDept.id,
        'level': 'Director',
        'grade': 'D1',
        'min_experience': 12,
        'max_experience': 20,
        'salary_range_min': 5000000,
        'salary_range_max': 8000000,
        'is_management_role': true,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // QA Roles
      {
        'title': 'QA Engineer',
        'department_id': qaDept.id,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 700000,
        'salary_range_max': 1200000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Senior QA Engineer',
        'department_id': qaDept.id,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 7,
        'salary_range_min': 1200000,
        'salary_range_max': 2000000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'QA Manager',
        'department_id': qaDept.id,
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 6,
        'max_experience': 12,
        'salary_range_min': 2200000,
        'salary_range_max': 3500000,
        'is_management_role': true,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // DevOps Roles
      {
        'title': 'DevOps Engineer',
        'department_id': devopsDept.id,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 900000,
        'salary_range_max': 1500000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Senior DevOps Engineer',
        'department_id': devopsDept.id,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 7,
        'salary_range_min': 1500000,
        'salary_range_max': 2500000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'DevOps Lead',
        'department_id': devopsDept.id,
        'level': 'Lead',
        'grade': 'L4',
        'min_experience': 5,
        'max_experience': 10,
        'salary_range_min': 2200000,
        'salary_range_max': 3200000,
        'is_management_role': true,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // Product Management Roles
      {
        'title': 'Product Manager',
        'department_id': pmDept.id,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 5,
        'salary_range_min': 1200000,
        'salary_range_max': 2000000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Senior Product Manager',
        'department_id': pmDept.id,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 8,
        'salary_range_min': 2000000,
        'salary_range_max': 3200000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // UX Roles
      {
        'title': 'UI/UX Designer',
        'department_id': uxDept.id,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 1,
        'max_experience': 4,
        'salary_range_min': 600000,
        'salary_range_max': 1200000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Senior UI/UX Designer',
        'department_id': uxDept.id,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 3,
        'max_experience': 6,
        'salary_range_min': 1200000,
        'salary_range_max': 2000000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // Data & Analytics Roles
      {
        'title': 'Data Analyst',
        'department_id': dataDept.id,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 1,
        'max_experience': 3,
        'salary_range_min': 700000,
        'salary_range_max': 1300000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Data Scientist',
        'department_id': dataDept.id,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 2,
        'max_experience': 5,
        'salary_range_min': 1300000,
        'salary_range_max': 2200000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // HR Roles
      {
        'title': 'HR Executive',
        'department_id': hrDept.id,
        'level': 'Junior',
        'grade': 'L1',
        'min_experience': 0,
        'max_experience': 2,
        'salary_range_min': 400000,
        'salary_range_max': 700000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'HR Business Partner',
        'department_id': hrDept.id,
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 5,
        'salary_range_min': 800000,
        'salary_range_max': 1400000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Senior HR Business Partner',
        'department_id': hrDept.id,
        'level': 'Senior',
        'grade': 'L3',
        'min_experience': 4,
        'max_experience': 8,
        'salary_range_min': 1400000,
        'salary_range_max': 2200000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'HR Manager',
        'department_id': hrDept.id,
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 5,
        'max_experience': 10,
        'salary_range_min': 1800000,
        'salary_range_max': 2800000,
        'is_management_role': true,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Director of People Operations',
        'department_id': hrDept.id,
        'level': 'Director',
        'grade': 'D1',
        'min_experience': 8,
        'max_experience': 15,
        'salary_range_min': 3000000,
        'salary_range_max': 5000000,
        'is_management_role': true,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final role in roles) {
      await _firestore.collection('roles').add(role);
    }
  }

  static Future<void> _insertTeams() async {
    // Get department IDs
    final deptSnapshot = await _firestore.collection('departments').get();
    final deptDocs = deptSnapshot.docs;
    
    final engDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'ENG');
    final qaDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'QA');
    final devopsDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'DEVOPS');
    final dataDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'DATA');
    final pmDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'PM');
    final uxDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'UX');
    final hrDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'HR');

    final teams = [
      {
        'name': 'Frontend Platform Team',
        'department_id': engDept.id,
        'team_type': 'Development',
        'max_capacity': 8,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Backend Services Team',
        'department_id': engDept.id,
        'team_type': 'Development',
        'max_capacity': 10,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Mobile Development Team',
        'department_id': engDept.id,
        'team_type': 'Development',
        'max_capacity': 6,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'DevOps & Infrastructure',
        'department_id': devopsDept.id,
        'team_type': 'DevOps',
        'max_capacity': 5,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Quality Engineering',
        'department_id': qaDept.id,
        'team_type': 'QA',
        'max_capacity': 8,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Data Platform Team',
        'department_id': dataDept.id,
        'team_type': 'Development',
        'max_capacity': 6,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Product Strategy',
        'department_id': pmDept.id,
        'team_type': 'Cross-functional',
        'max_capacity': 4,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Design System Team',
        'department_id': uxDept.id,
        'team_type': 'Development',
        'max_capacity': 4,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'People Operations',
        'department_id': hrDept.id,
        'team_type': 'Support',
        'max_capacity': 6,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final team in teams) {
      await _firestore.collection('teams').add(team);
    }
  }

  static Future<void> _insertGoalCategories() async {
    final categories = [
      {
        'name': 'Technical Excellence',
        'description': 'Goals related to technical skills and code quality',
        'category_type': 'Technical',
        'color_code': '#3B82F6',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Business Growth',
        'description': 'Goals related to business development and market expansion',
        'category_type': 'Delivery',
        'color_code': '#10B981',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Design & UX',
        'description': 'Goals related to user experience and design improvements',
        'category_type': 'Quality',
        'color_code': '#8B5CF6',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Data & Analytics',
        'description': 'Goals related to data processing and analytics',
        'category_type': 'Technical',
        'color_code': '#F59E0B',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sales & Revenue',
        'description': 'Goals related to sales performance and revenue growth',
        'category_type': 'Delivery',
        'color_code': '#EF4444',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Process Improvement',
        'description': 'Goals related to operational efficiency and process optimization',
        'category_type': 'Process',
        'color_code': '#06B6D4',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Leadership Development',
        'description': 'Goals related to leadership skills and team management',
        'category_type': 'Leadership',
        'color_code': '#8B5CF6',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Learning & Development',
        'description': 'Goals related to skill development and training',
        'category_type': 'Learning',
        'color_code': '#10B981',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final category in categories) {
      await _firestore.collection('goal_categories').add(category);
    }
  }

  static Future<void> _insertSampleEmployees() async {
    // Get department and role IDs
    final deptSnapshot = await _firestore.collection('departments').get();
    final roleSnapshot = await _firestore.collection('roles').get();
    final teamSnapshot = await _firestore.collection('teams').get();
    
    final deptDocs = deptSnapshot.docs;
    final roleDocs = roleSnapshot.docs;
    final teamDocs = teamSnapshot.docs;
    
    final engDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'ENG');
    final qaDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'QA');
    final devopsDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'DEVOPS');
    final hrDept = deptDocs.firstWhere((doc) => doc.data()['code'] == 'HR');

    final directorRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'Director of Engineering');
    final engManagerRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'Engineering Manager');
    final seniorEngRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'Senior Software Engineer');
    final leadEngRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'Lead Software Engineer');
    final qaManagerRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'QA Manager');
    final seniorQARole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'Senior QA Engineer');
    final devopsLeadRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'DevOps Lead');
    final seniorDevopsRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'Senior DevOps Engineer');
    final hrDirectorRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'Director of People Operations');
    final seniorHRRole = roleDocs.firstWhere((doc) => doc.data()['title'] == 'Senior HR Business Partner');

    final frontendTeam = teamDocs.firstWhere((doc) => doc.data()['name'] == 'Frontend Platform Team');
    final backendTeam = teamDocs.firstWhere((doc) => doc.data()['name'] == 'Backend Services Team');
    final qaTeam = teamDocs.firstWhere((doc) => doc.data()['name'] == 'Quality Engineering');
    final devopsTeam = teamDocs.firstWhere((doc) => doc.data()['name'] == 'DevOps & Infrastructure');
    final hrTeam = teamDocs.firstWhere((doc) => doc.data()['name'] == 'People Operations');

    final employees = [
      // CEO/CTO Level
      {
        'employee_id': 'EMP001',
        'email': 'john.doe@company.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'hire_date': Timestamp.fromDate(DateTime(2020, 1, 15)),
        'department_id': engDept.id,
        'role_id': directorRole.id,
        'team_id': null,
        'manager_id': null,
        'current_salary': 6000000,
        'work_location': 'Office',
        'employment_status': 'Active',
        'employee_type': 'Full-time',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // Engineering Managers
      {
        'employee_id': 'EMP002',
        'email': 'sarah.wilson@company.com',
        'first_name': 'Sarah',
        'last_name': 'Wilson',
        'hire_date': Timestamp.fromDate(DateTime(2020, 3, 20)),
        'department_id': engDept.id,
        'role_id': engManagerRole.id,
        'team_id': frontendTeam.id,
        'manager_id': null, // Will be updated after EMP001 is created
        'current_salary': 3200000,
        'work_location': 'Hybrid',
        'employment_status': 'Active',
        'employee_type': 'Full-time',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // Senior Engineers
      {
        'employee_id': 'EMP004',
        'email': 'priya.sharma@company.com',
        'first_name': 'Priya',
        'last_name': 'Sharma',
        'hire_date': Timestamp.fromDate(DateTime(2021, 2, 15)),
        'department_id': engDept.id,
        'role_id': seniorEngRole.id,
        'team_id': frontendTeam.id,
        'manager_id': null, // Will be updated after EMP002 is created
        'current_salary': 1800000,
        'work_location': 'Remote',
        'employment_status': 'Active',
        'employee_type': 'Full-time',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // QA Team
      {
        'employee_id': 'EMP010',
        'email': 'james.taylor@company.com',
        'first_name': 'James',
        'last_name': 'Taylor',
        'hire_date': Timestamp.fromDate(DateTime(2021, 8, 20)),
        'department_id': qaDept.id,
        'role_id': qaManagerRole.id,
        'team_id': qaTeam.id,
        'manager_id': null, // Will be updated after EMP001 is created
        'current_salary': 2800000,
        'work_location': 'Office',
        'employment_status': 'Active',
        'employee_type': 'Full-time',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // DevOps Team
      {
        'employee_id': 'EMP013',
        'email': 'maria.rodriguez@company.com',
        'first_name': 'Maria',
        'last_name': 'Rodriguez',
        'hire_date': Timestamp.fromDate(DateTime(2021, 6, 15)),
        'department_id': devopsDept.id,
        'role_id': devopsLeadRole.id,
        'team_id': devopsTeam.id,
        'manager_id': null, // Will be updated after EMP001 is created
        'current_salary': 2800000,
        'work_location': 'Office',
        'employment_status': 'Active',
        'employee_type': 'Full-time',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },

      // HR Team
      {
        'employee_id': 'EMP015',
        'email': 'jennifer.smith@company.com',
        'first_name': 'Jennifer',
        'last_name': 'Smith',
        'hire_date': Timestamp.fromDate(DateTime(2020, 8, 1)),
        'department_id': hrDept.id,
        'role_id': hrDirectorRole.id,
        'team_id': hrTeam.id,
        'manager_id': null,
        'current_salary': 4200000,
        'work_location': 'Office',
        'employment_status': 'Active',
        'employee_type': 'Full-time',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final employee in employees) {
      await _firestore.collection('employees').add(employee);
    }

    // Update manager references after employees are created
    await _updateManagerReferences();
  }

  static Future<void> _updateManagerReferences() async {
    final employeeSnapshot = await _firestore.collection('employees').get();
    final employeeDocs = employeeSnapshot.docs;
    
    final emp001 = employeeDocs.firstWhere((doc) => doc.data()['employee_id'] == 'EMP001');
    final emp002 = employeeDocs.firstWhere((doc) => doc.data()['employee_id'] == 'EMP002');
    final emp010 = employeeDocs.firstWhere((doc) => doc.data()['employee_id'] == 'EMP010');
    final emp013 = employeeDocs.firstWhere((doc) => doc.data()['employee_id'] == 'EMP013');

    // Update manager references
    await _firestore.collection('employees').doc(emp002.id).update({
      'manager_id': emp001.id,
    });

    await _firestore.collection('employees').doc(emp010.id).update({
      'manager_id': emp001.id,
    });

    await _firestore.collection('employees').doc(emp013.id).update({
      'manager_id': emp001.id,
    });
  }

  static Future<void> _insertSampleUserAccounts() async {
    // Get system role IDs
    final roleSnapshot = await _firestore.collection('system_roles').get();
    final roleDocs = roleSnapshot.docs;
    
    final superAdminRole = roleDocs.firstWhere((doc) => doc.data()['role_name'] == 'super_admin');
    final hrAdminRole = roleDocs.firstWhere((doc) => doc.data()['role_name'] == 'hr_admin');
    final managerRole = roleDocs.firstWhere((doc) => doc.data()['role_name'] == 'manager');
    final employeeRole = roleDocs.firstWhere((doc) => doc.data()['role_name'] == 'employee');

    final userAccounts = [
      {
        'username': 'john.doe',
        'email': 'john.doe@company.com',
        'password_hash': '\$2b\$12\$hash_for_john',
        'system_role_id': superAdminRole.id,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'username': 'sarah.wilson',
        'email': 'sarah.wilson@company.com',
        'password_hash': '\$2b\$12\$hash_for_sarah',
        'system_role_id': managerRole.id,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'username': 'james.taylor',
        'email': 'james.taylor@company.com',
        'password_hash': '\$2b\$12\$hash_for_james',
        'system_role_id': managerRole.id,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'username': 'maria.rodriguez',
        'email': 'maria.rodriguez@company.com',
        'password_hash': '\$2b\$12\$hash_for_maria',
        'system_role_id': managerRole.id,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'username': 'jennifer.smith',
        'email': 'jennifer.smith@company.com',
        'password_hash': '\$2b\$12\$hash_for_jennifer',
        'system_role_id': hrAdminRole.id,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'username': 'priya.sharma',
        'email': 'priya.sharma@company.com',
        'password_hash': '\$2b\$12\$hash_for_priya',
        'system_role_id': employeeRole.id,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final userAccount in userAccounts) {
      await _firestore.collection('user_accounts').add(userAccount);
    }
  }

  // Check if master data already exists
  static Future<bool> isMasterDataExists() async {
    try {
      final deptSnapshot = await _firestore.collection('departments').limit(1).get();
      return deptSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
} 