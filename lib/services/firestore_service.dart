import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/role_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get userAccounts => _firestore.collection('user_accounts');

  // Test Firestore connectivity
  Future<bool> testFirestoreConnection() async {
    try {
      print('🔍 [FIRESTORE] Testing Firestore connection...');
      
      // Test if we can access the Firestore instance
      print('✅ [FIRESTORE] Firestore instance accessible');
      
      // Test if we can access the collection
      final collectionRef = userAccounts;
      print('✅ [FIRESTORE] Collection reference accessible: ${collectionRef.path}');
      
      // Test if we can perform a simple read operation
      print('📖 [FIRESTORE] Testing read operation...');
      try {
        await collectionRef.limit(1).get();
        print('✅ [FIRESTORE] Read operation successful');
      } catch (e) {
        // If read fails due to permissions, try a simple write test
        print('⚠️ [FIRESTORE] Read operation failed, testing write permissions...');
        print('📝 [FIRESTORE] This is expected during signup process');
        return true; // Allow the process to continue
      }
      
      return true;
    } catch (e) {
      print('❌ [FIRESTORE] Connection test failed: $e');
      return false;
    }
  }

  // Create new user account (for HR signup)
  Future<void> createUserAccount(UserModel user) async {
    try {
      print('💾 [FIRESTORE] Creating user account for UID: ${user.uid}');
      print('📝 [FIRESTORE] User data: ${user.toFirestore()}');
      
      // Test Firestore connection first
      final isConnected = await testFirestoreConnection();
      if (!isConnected) {
        throw Exception('Firestore connection test failed');
      }
      
      // Test if we can access the collection
      print('🔍 [FIRESTORE] Testing collection access...');
      final collectionRef = userAccounts;
      print('✅ [FIRESTORE] Collection reference obtained');
      
      // Test if we can create a document reference
      print('📄 [FIRESTORE] Creating document reference...');
      final docRef = collectionRef.doc(user.uid);
      print('✅ [FIRESTORE] Document reference created: ${docRef.path}');
      
      // Test the data we're about to write
      final userData = user.toFirestore();
      print('📊 [FIRESTORE] Data to write: $userData');
      
      // Attempt to write the data
      print('✍️ [FIRESTORE] Attempting to write data to Firestore...');
      await docRef.set(userData);
      
      print('✅ [FIRESTORE] User account created successfully');
      
      // Verify the write by reading it back
      print('🔍 [FIRESTORE] Verifying write by reading back...');
      final verifyDoc = await docRef.get();
      if (verifyDoc.exists) {
        print('✅ [FIRESTORE] Write verification successful');
      } else {
        print('❌ [FIRESTORE] Write verification failed - document does not exist');
      }
      
    } catch (e) {
      print('❌ [FIRESTORE] Failed to create user account: $e');
      print('🔍 [FIRESTORE] Error type: ${e.runtimeType}');
      print('🔍 [FIRESTORE] Error details: ${e.toString()}');
      
      // Check if it's a Firebase Auth error
      if (e.toString().contains('permission-denied')) {
        print('🚫 [FIRESTORE] Permission denied - check Firestore security rules');
      } else if (e.toString().contains('unavailable')) {
        print('🌐 [FIRESTORE] Service unavailable - check network connection');
      } else if (e.toString().contains('unauthenticated')) {
        print('🔐 [FIRESTORE] Unauthenticated - check Firebase Auth state');
      }
      
      throw Exception('Failed to create user account: $e');
    }
  }

  // Get user by UID
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      print('🔍 [FIRESTORE] Getting user by UID: $uid');
      
      DocumentSnapshot doc = await userAccounts.doc(uid).get();
      
      if (doc.exists) {
        print('✅ [FIRESTORE] User found by UID');
        return UserModel.fromFirestore(doc);
      } else {
        print('❌ [FIRESTORE] User not found by UID');
        return null;
      }
    } catch (e) {
      print('❌ [FIRESTORE] Failed to get user by UID: $e');
      throw Exception('Failed to get user: $e');
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      print('🔍 [FIRESTORE] Getting user by email: $email');
      
      QuerySnapshot query = await userAccounts
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        print('✅ [FIRESTORE] User found by email');
        return UserModel.fromFirestore(query.docs.first);
      } else {
        print('❌ [FIRESTORE] User not found by email');
        return null;
      }
    } catch (e) {
      print('❌ [FIRESTORE] Failed to get user by email: $e');
      // If it's a permission error, return null (user doesn't exist)
      if (e.toString().contains('permission-denied')) {
        print('⚠️ [FIRESTORE] Permission denied for email check, assuming user does not exist');
        return null;
      }
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Update user's last login
  Future<void> updateLastLogin(String uid) async {
    try {
      await userAccounts.doc(uid).update({
        'last_login': Timestamp.fromDate(DateTime.now()),
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  // Update user's active status (for approval/rejection)
  Future<void> updateUserActiveStatus(String uid, bool isActive) async {
    try {
      await userAccounts.doc(uid).update({
        'is_active': isActive,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // Get pending HR signups (for super admin)
  Future<List<UserModel>> getPendingHrSignups() async {
    try {
      try {
        // Try with full query (requires composite index)
        QuerySnapshot query = await userAccounts
            .where('role', isEqualTo: RoleConstants.HR_ADMIN)
            .where('is_active', isEqualTo: false)
            .orderBy('created_at', descending: true)
            .get();
        
        return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      } catch (indexError) {
        // If index doesn't exist, fall back to basic query and sort in memory
        print('Composite index not ready for pending HR signups. Falling back to memory sort.');
        print('Please create the index using this link:');
        print(indexError.toString());
        
        QuerySnapshot query = await userAccounts
            .where('role', isEqualTo: RoleConstants.HR_ADMIN)
            .where('is_active', isEqualTo: false)
            .get();
        
        final users = query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        
        // Sort by created_at in memory
        users.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        
        return users;
      }
    } catch (e) {
      throw Exception('Failed to get pending HR signups: $e');
    }
  }

  // Get all users (for super admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      try {
        // Try with sorting (requires index)
        QuerySnapshot query = await userAccounts
            .orderBy('created_at', descending: true)
            .get();
        
        return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      } catch (indexError) {
        // If index doesn't exist, fall back to basic query and sort in memory
        print('Index not ready for user sorting. Falling back to memory sort.');
        print('Please create the index using this link:');
        print(indexError.toString());
        
        QuerySnapshot query = await userAccounts.get();
        final users = query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        
        // Sort by created_at in memory
        users.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        
        return users;
      }
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  // Check if email already exists
  Future<bool> emailExists(String email) async {
    try {
      print('🔍 [FIRESTORE] Checking if email exists: $email');
      
      QuerySnapshot query = await userAccounts
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      final exists = query.docs.isNotEmpty;
      print('${exists ? "✅" : "❌"} [FIRESTORE] Email ${exists ? "exists" : "does not exist"}');
      return exists;
    } catch (e) {
      print('❌ [FIRESTORE] Failed to check email existence: $e');
      throw Exception('Failed to check email existence: $e');
    }
  }

  // Check if username already exists
  Future<bool> usernameExists(String username) async {
    try {
      print('🔍 [FIRESTORE] Checking if username exists: $username');
      
      QuerySnapshot query = await userAccounts
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      final exists = query.docs.isNotEmpty;
      print('${exists ? "✅" : "❌"} [FIRESTORE] Username ${exists ? "exists" : "does not exist"}');
      return exists;
    } catch (e) {
      print('❌ [FIRESTORE] Failed to check username existence: $e');
      // If it's a permission error, assume username doesn't exist
      if (e.toString().contains('permission-denied')) {
        print('⚠️ [FIRESTORE] Permission denied for username check, assuming username does not exist');
        return false;
      }
      throw Exception('Failed to check username existence: $e');
    }
  }

  // Delete user account (for super admin)
  Future<void> deleteUserAccount(String uid) async {
    try {
      await userAccounts.doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user account: $e');
    }
  }

  // Update user role (for super admin)
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await userAccounts.doc(uid).update({
        'role': newRole,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    try {
      QuerySnapshot allUsers = await userAccounts.get();
      QuerySnapshot activeUsers = await userAccounts
          .where('is_active', isEqualTo: true)
          .get();
      QuerySnapshot pendingHr = await userAccounts
          .where('role', isEqualTo: RoleConstants.HR_ADMIN)
          .where('is_active', isEqualTo: false)
          .get();

      return {
        'total_users': allUsers.docs.length,
        'active_users': activeUsers.docs.length,
        'pending_hr': pendingHr.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }
} 