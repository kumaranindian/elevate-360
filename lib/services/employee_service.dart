import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/employee_model.dart';

class EmployeeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get all employees from Firebase
  static Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('employees').get();
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return EmployeeModel.fromJson({...data, 'id': doc.id});
        } catch (parseError) {
          print('Error parsing employee document ${doc.id}: $parseError');
          print('Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  // Get employee by ID
  static Future<EmployeeModel?> getEmployeeById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('employees').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return EmployeeModel.fromJson({...data, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load employee: $e');
    }
  }

  // Search employees
  static Future<List<EmployeeModel>> searchEmployees(String query) async {
    try {
      try {
        // Try with full query (requires composite indexes)
        final QuerySnapshot snapshot = await _firestore
            .collection('employees')
            .where('first_name', isGreaterThanOrEqualTo: query)
            .where('first_name', isLessThan: query + '\uf8ff')
            .get();
        
        final QuerySnapshot snapshot2 = await _firestore
            .collection('employees')
            .where('last_name', isGreaterThanOrEqualTo: query)
            .where('last_name', isLessThan: query + '\uf8ff')
            .get();
        
        final QuerySnapshot snapshot3 = await _firestore
            .collection('employees')
            .where('email', isGreaterThanOrEqualTo: query)
            .where('email', isLessThan: query + '\uf8ff')
            .get();
        
        final QuerySnapshot snapshot4 = await _firestore
            .collection('employees')
            .where('employee_id', isGreaterThanOrEqualTo: query)
            .where('employee_id', isLessThan: query + '\uf8ff')
            .get();

        final Set<String> uniqueIds = <String>{};
        final List<EmployeeModel> results = <EmployeeModel>[];

        for (final doc in [...snapshot.docs, ...snapshot2.docs, ...snapshot3.docs, ...snapshot4.docs]) {
          if (uniqueIds.add(doc.id)) {
            final data = doc.data() as Map<String, dynamic>;
            results.add(EmployeeModel.fromJson({...data, 'id': doc.id}));
          }
        }

        return results;
      } catch (indexError) {
        // If indexes don't exist, fall back to basic query and filter in memory
        print('Composite indexes not ready for employee search. Falling back to memory filter.');
        print('Please create the indexes using these links:');
        print(indexError.toString());
        
        // Get all employees and filter in memory
        final QuerySnapshot snapshot = await _firestore
            .collection('employees')
            .get();
        
        final searchTerm = query.toLowerCase();
        final Set<String> uniqueIds = <String>{};
        final List<EmployeeModel> results = <EmployeeModel>[];
        
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final firstName = (data['first_name'] as String).toLowerCase();
          final lastName = (data['last_name'] as String).toLowerCase();
          final email = (data['email'] as String).toLowerCase();
          final employeeId = (data['employee_id'] as String).toLowerCase();
          
          if ((firstName.contains(searchTerm) ||
               lastName.contains(searchTerm) ||
               email.contains(searchTerm) ||
               employeeId.contains(searchTerm)) &&
              uniqueIds.add(doc.id)) {
            results.add(EmployeeModel.fromJson({...data, 'id': doc.id}));
          }
        }
        
        return results;
      }
    } catch (e) {
      throw Exception('Failed to search employees: $e');
    }
  }

  // Filter employees by status
  static Future<List<EmployeeModel>> filterEmployeesByStatus(String status) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('employees')
          .where('employment_status', isEqualTo: status)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EmployeeModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter employees: $e');
    }
  }

  // Create new employee
  static Future<bool> createEmployee(EmployeeModel employee) async {
    try {
      // Generate default password: last4digit + birthYear
      String defaultPassword = '';
      if (employee.dateOfBirth != null && employee.phone != null && employee.phone!.length >= 4) {
        final birthYear = employee.dateOfBirth!.year.toString();
        final last4Digits = employee.phone!.substring(employee.phone!.length - 4);
        defaultPassword = last4Digits + birthYear;
      } else {
        // Fallback: use last 4 digits of phone or '0000' + current year
        final last4Digits = employee.phone != null && employee.phone!.length >= 4 
            ? employee.phone!.substring(employee.phone!.length - 4)
            : '0000';
        final year = employee.dateOfBirth?.year ?? DateTime.now().year;
        defaultPassword = last4Digits + year.toString();
      }

      // Get job role details to determine system role
      final jobRole = await _getJobRoleDetails(employee.roleId);
      final department = await _getDepartmentDetails(employee.departmentId);
      
      // Determine system role based on job role and department
      final systemRole = _determineSystemRole(jobRole, department);

      // Create user account in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: employee.email,
        password: defaultPassword,
      );

      // Create user account document in user_accounts collection
      final username = employee.email.split('@')[0]; // Use email prefix as username
      final userAccountData = {
        'username': username,
        'email': employee.email,
        'role': systemRole, // Use determined system role
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('user_accounts').doc(userCredential.user!.uid).set(userAccountData);

      // Create employee document in Firestore
      final employeeData = employee.toJson();
      employeeData['user_account_id'] = userCredential.user!.uid;
      employeeData['created_at'] = FieldValue.serverTimestamp();
      employeeData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('employees').add(employeeData);

      return true;
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  // Update employee
  static Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      final employeeData = employee.toJson();
      employeeData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('employees')
          .doc(employee.id)
          .update(employeeData);

      return true;
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  // Delete employee
  static Future<bool> deleteEmployee(String employeeId) async {
    try {
      await _firestore.collection('employees').doc(employeeId).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  // Get departments
  static Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('departments').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  // Get roles
  static Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('roles').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();
    } catch (e) {
      throw Exception('Failed to load roles: $e');
    }
  }

  // Get teams
  static Future<List<Map<String, dynamic>>> getTeams() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('teams').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();
    } catch (e) {
      throw Exception('Failed to load teams: $e');
    }
  }

  // Generate unique employee ID
  static Future<String> generateEmployeeId() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('employees')
          .orderBy('employee_id', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 'EMP001';
      }

      final lastEmployeeId = snapshot.docs.first.data() as Map<String, dynamic>;
      final lastId = lastEmployeeId['employee_id'] as String;
      final number = int.parse(lastId.substring(3)) + 1;
      return 'EMP${number.toString().padLeft(3, '0')}';
    } catch (e) {
      throw Exception('Failed to generate employee ID: $e');
    }
  }

  // Get employee by user account ID
  static Future<EmployeeModel> getEmployeeByUserAccountId(String userAccountId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('employees')
          .where('user_account_id', isEqualTo: userAccountId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        throw Exception('Employee not found for user account ID: $userAccountId');
      }

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return EmployeeModel.fromJson({...data, 'id': snapshot.docs.first.id});
    } catch (e) {
      throw Exception('Failed to load employee by user account ID: $e');
    }
  }

  // Get employee by email
  static Future<EmployeeModel?> getEmployeeByEmail(String email) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('employees')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return EmployeeModel.fromJson({...data, 'id': snapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load employee by email: $e');
    }
  }

  // Helper method to get job role details
  static Future<Map<String, dynamic>> _getJobRoleDetails(String roleId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('roles').doc(roleId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }
      return {};
    } catch (e) {
      print('Error getting job role details: $e');
      return {};
    }
  }

  // Helper method to get department details
  static Future<Map<String, dynamic>> _getDepartmentDetails(String departmentId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('departments').doc(departmentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }
      return {};
    } catch (e) {
      print('Error getting department details: $e');
      return {};
    }
  }

  // Helper method to determine system role based on job role and department
  static String _determineSystemRole(Map<String, dynamic> jobRole, Map<String, dynamic> department) {
    final jobTitle = (jobRole['title'] ?? '').toString().toLowerCase();
    final departmentName = (department['name'] ?? '').toString().toLowerCase();
    final departmentCode = (department['code'] ?? '').toString().toLowerCase();

    // Check for HR roles
    if (departmentName.contains('hr') || 
        departmentCode == 'hr' || 
        jobTitle.contains('hr') ||
        jobTitle.contains('human resource')) {
      return 'hr_admin';
    }

    // Check for manager roles
    if (jobTitle.contains('manager') ||
        jobTitle.contains('director') ||
        jobTitle.contains('lead') ||
        jobTitle.contains('head')) {
      return 'manager';
    }

    // Check for project manager roles
    if (jobTitle.contains('project manager') ||
        jobTitle.contains('program manager')) {
      return 'project_manager';
    }

    // Default to employee
    return 'employee';
  }

  // Update employee system role based on job role
  static Future<bool> updateEmployeeSystemRole(String employeeId) async {
    try {
      // Get employee details
      final employee = await getEmployeeById(employeeId);
      if (employee == null) {
        throw Exception('Employee not found');
      }

      // Get job role and department details
      final jobRole = await _getJobRoleDetails(employee.roleId);
      final department = await _getDepartmentDetails(employee.departmentId);
      
      // Determine correct system role
      final correctSystemRole = _determineSystemRole(jobRole, department);

      // Update user account with correct system role
      if (employee.userAccountId != null) {
        await _firestore.collection('user_accounts').doc(employee.userAccountId).update({
          'role': correctSystemRole,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      throw Exception('Failed to update employee system role: $e');
    }
  }

  // Bulk update all employees' system roles
  static Future<bool> updateAllEmployeeSystemRoles() async {
    try {
      final employees = await getAllEmployees();
      int updatedCount = 0;

      for (final employee in employees) {
        try {
          await updateEmployeeSystemRole(employee.id);
          updatedCount++;
        } catch (e) {
          print('Error updating employee ${employee.id}: $e');
        }
      }

      print('Updated system roles for $updatedCount employees');
      return true;
    } catch (e) {
      throw Exception('Failed to update employee system roles: $e');
    }
  }

  // Get reportees for a manager
  static Future<List<EmployeeModel>> getReporteesByManagerId(String managerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('employees')
          .where('manager_id', isEqualTo: managerId)
          .get();

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return EmployeeModel.fromJson({...data, 'id': doc.id});
        } catch (parseError) {
          print('Error parsing reportee document ${doc.id}: $parseError');
          print('Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching reportees for manager $managerId: $e');
      return [];
    }
  }

  // Get manager's team performance summary
  static Future<Map<String, dynamic>> getManagerTeamSummary(String managerId) async {
    try {
      final reportees = await getReporteesByManagerId(managerId);
      
      if (reportees.isEmpty) {
        return {
          'totalReportees': 0,
          'activeReportees': 0,
          'averageRating': 0.0,
          'teamPerformance': 0.0,
        };
      }

      final activeReportees = reportees.where((r) => r.employmentStatus == 'Active').length;
      
      // Calculate average salary (for demo purposes)
      final totalSalary = reportees.fold<double>(0.0, (sum, r) => sum + (r.currentSalary ?? 0.0));
      final averageSalary = totalSalary / reportees.length;

      return {
        'totalReportees': reportees.length,
        'activeReportees': activeReportees,
        'averageRating': 4.2, // This would come from performance reviews
        'teamPerformance': 4.0, // This would be calculated from team metrics
        'averageSalary': averageSalary,
      };
    } catch (e) {
      print('Error getting manager team summary: $e');
      return {
        'totalReportees': 0,
        'activeReportees': 0,
        'averageRating': 0.0,
        'teamPerformance': 0.0,
      };
    }
  }

  // Get department details by ID
  static Future<Map<String, dynamic>> getDepartmentById(String departmentId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('departments').doc(departmentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }
      return {};
    } catch (e) {
      print('Error getting department details: $e');
      return {};
    }
  }

  // Get job role details by ID
  static Future<Map<String, dynamic>> getJobRoleById(String roleId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('job_roles').doc(roleId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }
      return {};
    } catch (e) {
      print('Error getting job role details: $e');
      return {};
    }
  }

} 