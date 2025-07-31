import 'package:cloud_firestore/cloud_firestore.dart';
import 'performance_review_service.dart';

class IndexInitializationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize all required indexes for the app
  static Future<void> initializeAllIndexes() async {
    print('🚀 Initializing Firestore indexes...');
    
    try {
      // Initialize performance review indexes
      await PerformanceReviewService.createRequiredIndexes();
      
      // Initialize other collection indexes
      await _initializeEmployeeIndexes();
      await _initializeGoalIndexes();
      await _initializeAssessmentIndexes();
      await _initializeSkillIndexes();
      await _initializeReviewIndexes();
      
      print('✅ All index initialization completed!');
    } catch (e) {
      print('❌ Error during index initialization: $e');
    }
  }

  // Employee collection indexes
  static Future<void> _initializeEmployeeIndexes() async {
    print('👥 Initializing employee indexes...');
    
    final indexes = [
      {
        'name': 'employees_by_manager',
        'fields': ['manager_id'],
        'description': 'For querying employees by manager'
      },
      {
        'name': 'employees_by_department',
        'fields': ['department'],
        'description': 'For querying employees by department'
      },
      {
        'name': 'employees_by_status',
        'fields': ['employment_status'],
        'description': 'For querying employees by status'
      }
    ];

    for (final index in indexes) {
      final link = getIndexCreationLink('employees', index['fields'] as List<String>);
      print('📋 ${index['name']}: ${index['description']}');
      print('🔗 Create: $link');
    }
  }

  // Goal collection indexes
  static Future<void> _initializeGoalIndexes() async {
    print('🎯 Initializing goal indexes...');
    
    final indexes = [
      {
        'name': 'goals_by_employee',
        'fields': ['employee_id'],
        'description': 'For querying goals by employee'
      },
      {
        'name': 'goals_by_status',
        'fields': ['status'],
        'description': 'For querying goals by status'
      },
      {
        'name': 'goals_by_employee_status',
        'fields': ['employee_id', 'status'],
        'description': 'For querying goals by employee and status'
      },
      {
        'name': 'goals_with_ordering',
        'fields': ['employee_id', 'created_at'],
        'description': 'For querying goals with ordering'
      }
    ];

    for (final index in indexes) {
      final link = getIndexCreationLink('goals', index['fields'] as List<String>);
      print('📋 ${index['name']}: ${index['description']}');
      print('🔗 Create: $link');
    }
  }

  // Assessment collection indexes
  static Future<void> _initializeAssessmentIndexes() async {
    print('📊 Initializing assessment indexes...');
    
    final indexes = [
      {
        'name': 'assessments_by_employee',
        'fields': ['employee_id'],
        'description': 'For querying assessments by employee'
      },
      {
        'name': 'assessments_by_quarter',
        'fields': ['quarter', 'year'],
        'description': 'For querying assessments by quarter'
      },
      {
        'name': 'assessments_by_employee_quarter',
        'fields': ['employee_id', 'quarter', 'year'],
        'description': 'For querying assessments by employee and quarter'
      },
      {
        'name': 'assessments_with_ordering',
        'fields': ['employee_id', 'year', 'quarter'],
        'description': 'For querying assessments with ordering'
      }
    ];

    for (final index in indexes) {
      final link = getIndexCreationLink('self_assessments', index['fields'] as List<String>);
      print('📋 ${index['name']}: ${index['description']}');
      print('🔗 Create: $link');
    }
  }

  // Skill collection indexes
  static Future<void> _initializeSkillIndexes() async {
    print('💡 Initializing skill indexes...');
    
    final indexes = [
      {
        'name': 'skills_by_employee',
        'fields': ['employee_id'],
        'description': 'For querying skills by employee'
      },
      {
        'name': 'skills_by_name',
        'fields': ['skill_name'],
        'description': 'For querying skills by name'
      },
      {
        'name': 'skills_by_employee_name',
        'fields': ['employee_id', 'skill_name'],
        'description': 'For querying skills by employee and name'
      }
    ];

    for (final index in indexes) {
      final link = getIndexCreationLink('skills', index['fields'] as List<String>);
      print('📋 ${index['name']}: ${index['description']}');
      print('🔗 Create: $link');
    }
  }

  // Review collection indexes
  static Future<void> _initializeReviewIndexes() async {
    print('📝 Initializing review indexes...');
    
    final indexes = [
      {
        'name': 'reviews_by_employee',
        'fields': ['employee_id'],
        'description': 'For querying reviews by employee'
      },
      {
        'name': 'reviews_by_reviewer',
        'fields': ['reviewer_id'],
        'description': 'For querying reviews by reviewer'
      },
      {
        'name': 'reviews_by_quarter',
        'fields': ['quarter', 'year'],
        'description': 'For querying reviews by quarter'
      },
      {
        'name': 'reviews_by_employee_quarter',
        'fields': ['employee_id', 'quarter', 'year'],
        'description': 'For querying reviews by employee and quarter'
      },
      {
        'name': 'reviews_with_ordering',
        'fields': ['employee_id', 'year', 'quarter'],
        'description': 'For querying reviews with ordering'
      }
    ];

    for (final index in indexes) {
      final link = getIndexCreationLink('reviews', index['fields'] as List<String>);
      print('📋 ${index['name']}: ${index['description']}');
      print('🔗 Create: $link');
    }
  }

  // Helper method to create index creation links
  static String getIndexCreationLink(String collection, List<String> fields) {
    final projectId = _firestore.app.options.projectId;
    final fieldsParam = fields.join(',');
    return 'https://console.firebase.google.com/project/$projectId/firestore/indexes?create_composite=ClJwcm9qZWN0cy8k{$projectId}/databases/(default)/collections/$collection&query_id=index_query&field_path=$fieldsParam';
  }

  // Method to check if indexes exist and provide creation links
  static Future<void> checkAndCreateIndexes() async {
    print('🔍 Checking for required indexes...');
    
    // This method can be called on app startup to ensure all indexes are available
    await initializeAllIndexes();
    
    print('📋 Index creation links have been printed to the console.');
    print('🔗 Please create the required indexes in Firebase Console using the provided links.');
    print('⏳ The app will work with fallback queries until indexes are created.');
  }

  // Method to test index availability
  static Future<bool> testIndexAvailability(String collection, List<String> fields) async {
    try {
      // Try a simple query that requires the index
      final query = _firestore.collection(collection);
      
      // Build query based on fields
      Query testQuery = query;
      for (int i = 0; i < fields.length; i++) {
        if (i == 0) {
          testQuery = testQuery.where(fields[i], isEqualTo: 'test');
        } else {
          testQuery = testQuery.orderBy(fields[i]);
        }
      }
      
      await testQuery.limit(1).get();
      return true;
    } catch (e) {
      if (e.toString().contains('index') || e.toString().contains('Index')) {
        return false;
      }
      return true; // Other errors don't indicate missing index
    }
  }
} 