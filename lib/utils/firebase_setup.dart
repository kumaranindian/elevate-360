import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase collections with sample data
  static Future<void> initializeCollections() async {
    try {
      await _initializeDepartments();
      await _initializeRoles();
      await _initializeTeams();
      await _initializeGoalCategories();
      print('Firebase collections initialized successfully!');
    } catch (e) {
      print('Error initializing Firebase collections: $e');
    }
  }

  static Future<void> _initializeDepartments() async {
    // Check if departments already exist
    final deptSnapshot = await _firestore.collection('departments').limit(1).get();
    if (deptSnapshot.docs.isNotEmpty) {
      print('Departments already exist, skipping initialization');
      return;
    }

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
    ];

    for (final dept in departments) {
      await _firestore.collection('departments').add(dept);
    }
    print('Departments initialized');
  }

  static Future<void> _initializeRoles() async {
    // Check if roles already exist
    final roleSnapshot = await _firestore.collection('roles').limit(1).get();
    if (roleSnapshot.docs.isNotEmpty) {
      print('Roles already exist, skipping initialization');
      return;
    }

    final roles = [
      // Engineering Roles
      {
        'title': 'Software Engineer Intern',
        'department_id': 'ENG',
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
        'department_id': 'ENG',
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
        'department_id': 'ENG',
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
        'department_id': 'ENG',
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
        'title': 'Engineering Manager',
        'department_id': 'ENG',
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
      
      // QA Roles
      {
        'title': 'QA Engineer',
        'department_id': 'QA',
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
        'department_id': 'QA',
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
      
      // DevOps Roles
      {
        'title': 'DevOps Engineer',
        'department_id': 'DEVOPS',
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
        'department_id': 'DEVOPS',
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
      
      // Product Management Roles
      {
        'title': 'Product Manager',
        'department_id': 'PM',
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
        'department_id': 'PM',
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
        'department_id': 'UX',
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
        'department_id': 'UX',
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
        'department_id': 'DATA',
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
        'department_id': 'DATA',
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
        'department_id': 'HR',
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
        'department_id': 'HR',
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
        'title': 'HR Manager',
        'department_id': 'HR',
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
      
      // Sales & Marketing Roles
      {
        'title': 'Sales Executive',
        'department_id': 'SALES',
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 600000,
        'salary_range_max': 1200000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Marketing Manager',
        'department_id': 'SALES',
        'level': 'Manager',
        'grade': 'M1',
        'min_experience': 4,
        'max_experience': 8,
        'salary_range_min': 1200000,
        'salary_range_max': 2000000,
        'is_management_role': true,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      
      // Finance Roles
      {
        'title': 'Financial Analyst',
        'department_id': 'FIN',
        'level': 'Mid-Level',
        'grade': 'L2',
        'min_experience': 2,
        'max_experience': 4,
        'salary_range_min': 600000,
        'salary_range_max': 1000000,
        'is_management_role': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final role in roles) {
      await _firestore.collection('roles').add(role);
    }
    print('Roles initialized');
  }

  static Future<void> _initializeTeams() async {
    // Check if teams already exist
    final teamSnapshot = await _firestore.collection('teams').limit(1).get();
    if (teamSnapshot.docs.isNotEmpty) {
      print('Teams already exist, skipping initialization');
      return;
    }

    final teams = [
      {
        'name': 'Frontend Platform Team',
        'department_id': 'ENG',
        'team_type': 'Development',
        'max_capacity': 8,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Backend Services Team',
        'department_id': 'ENG',
        'team_type': 'Development',
        'max_capacity': 10,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Mobile Development Team',
        'department_id': 'ENG',
        'team_type': 'Development',
        'max_capacity': 6,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'DevOps & Infrastructure',
        'department_id': 'DEVOPS',
        'team_type': 'DevOps',
        'max_capacity': 5,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Quality Engineering',
        'department_id': 'QA',
        'team_type': 'QA',
        'max_capacity': 8,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Data Platform Team',
        'department_id': 'DATA',
        'team_type': 'Development',
        'max_capacity': 6,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Product Strategy',
        'department_id': 'PM',
        'team_type': 'Cross-functional',
        'max_capacity': 4,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Design System Team',
        'department_id': 'UX',
        'team_type': 'Development',
        'max_capacity': 4,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'People Operations',
        'department_id': 'HR',
        'team_type': 'Support',
        'max_capacity': 6,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sales Team',
        'department_id': 'SALES',
        'team_type': 'Sales',
        'max_capacity': 8,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Marketing Team',
        'department_id': 'SALES',
        'team_type': 'Marketing',
        'max_capacity': 6,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Finance Team',
        'department_id': 'FIN',
        'team_type': 'Support',
        'max_capacity': 4,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final team in teams) {
      await _firestore.collection('teams').add(team);
    }
    print('Teams initialized');
  }

  static Future<void> _initializeGoalCategories() async {
    // Check if goal categories already exist
    final categorySnapshot = await _firestore.collection('goal_categories').limit(1).get();
    if (categorySnapshot.docs.isNotEmpty) {
      print('Goal categories already exist, skipping initialization');
      return;
    }

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
    print('Goal categories initialized');
  }
} 