import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all goals from Firebase
  static Future<List<GoalModel>> getAllGoals() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('goals').get();
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return GoalModel.fromJson({...data, 'id': doc.id});
        } catch (parseError) {
          print('Error parsing goal document ${doc.id}: $parseError');
          print('Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to load goals: $e');
    }
  }

  // Get goals by employee ID
  static Future<List<GoalModel>> getGoalsByEmployeeId(String employeeId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('goals')
          .where('employee_id', isEqualTo: employeeId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GoalModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load employee goals: $e');
    }
  }

  // Get goals by status
  static Future<List<GoalModel>> getGoalsByStatus(String status) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('goals')
          .where('status', isEqualTo: status)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GoalModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load goals by status: $e');
    }
  }

  // Create new goal
  static Future<bool> createGoal(GoalModel goal) async {
    try {
      final goalData = goal.toJson();
      goalData['created_at'] = FieldValue.serverTimestamp();
      goalData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('goals').add(goalData);
      return true;
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  // Update goal
  static Future<bool> updateGoal(GoalModel goal) async {
    try {
      final goalData = goal.toJson();
      goalData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('goals')
          .doc(goal.id)
          .update(goalData);

      return true;
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  // Update goal progress
  static Future<bool> updateGoalProgress(String goalId, double progress, double currentValue) async {
    try {
      await _firestore
          .collection('goals')
          .doc(goalId)
          .update({
            'progress_percentage': progress,
            'current_value': currentValue,
            'updated_at': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      throw Exception('Failed to update goal progress: $e');
    }
  }

  // Get goal categories
  static Future<List<GoalCategoryModel>> getGoalCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('goal_categories').get();
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return GoalCategoryModel.fromJson({...data, 'id': doc.id});
        } catch (parseError) {
          print('Error parsing goal category document ${doc.id}: $parseError');
          print('Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to load goal categories: $e');
    }
  }

  // Delete goal
  static Future<bool> deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  // Get goals by category
  static Future<List<GoalModel>> getGoalsByCategory(String categoryId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('goals')
          .where('category_id', isEqualTo: categoryId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GoalModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load goals by category: $e');
    }
  }

  // Get overdue goals
  static Future<List<GoalModel>> getOverdueGoals() async {
    try {
      final now = DateTime.now();
      try {
        // Try with full query (requires composite index)
        final QuerySnapshot snapshot = await _firestore
            .collection('goals')
            .where('due_date', isLessThan: now)
            .where('status', whereNotIn: ['Completed', 'Cancelled'])
            .get();
        
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return GoalModel.fromJson({...data, 'id': doc.id});
        }).toList();
      } catch (indexError) {
        // If index doesn't exist, fall back to basic query and filter in memory
        print('Composite index not ready for overdue goals. Falling back to memory filter.');
        print('Please create the index using this link:');
        print(indexError.toString());
        
        // Get all goals and filter in memory
        final QuerySnapshot snapshot = await _firestore
            .collection('goals')
            .where('due_date', isLessThan: now)
            .get();
        
        return snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return GoalModel.fromJson({...data, 'id': doc.id});
            })
            .where((goal) => !['Completed', 'Cancelled'].contains(goal.status))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load overdue goals: $e');
    }
  }

  // Get goals by manager ID
  static Future<List<GoalModel>> getGoalsByManagerId(String managerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('goals')
          .where('manager_id', isEqualTo: managerId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GoalModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load manager goals: $e');
    }
  }

  // Get all goals grouped by manager
  static Future<Map<String, List<GoalModel>>> getAllGoalsGroupedByManager() async {
    try {
      final goals = await getAllGoals();
      final Map<String, List<GoalModel>> groupedGoals = {};
      
      for (var goal in goals) {
        if (!groupedGoals.containsKey(goal.managerId)) {
          groupedGoals[goal.managerId] = [];
        }
        groupedGoals[goal.managerId]!.add(goal);
      }
      
      return groupedGoals;
    } catch (e) {
      throw Exception('Failed to load grouped goals: $e');
    }
  }

  // Assign goal to multiple employees
  static Future<bool> assignGoalToEmployees(GoalModel goalTemplate, List<String> employeeIds) async {
    try {
      final batch = _firestore.batch();
      
      for (var employeeId in employeeIds) {
        final goalData = {
          ...goalTemplate.toJson(),
          'employee_id': employeeId,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };
        
        final docRef = _firestore.collection('goals').doc();
        batch.set(docRef, goalData);
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      throw Exception('Failed to assign goals: $e');
    }
  }
} 