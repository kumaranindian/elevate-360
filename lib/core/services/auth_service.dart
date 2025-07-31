import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/role_constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Role-based getters
  bool get isSuperAdmin => _userModel?.isSuperAdmin ?? false;
  bool get isHrAdmin => _userModel?.isHrAdmin ?? false;
  bool get isManager => _userModel?.isManager ?? false;
  bool get isEmployee => _userModel?.isEmployee ?? false;

  // Permission getters
  bool get canApproveHrSignups => isSuperAdmin;
  bool get canSignUp => isHrAdmin; // Only HR can sign up other HRs

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Helper method to add timeout to async operations
  Future<T> _withTimeout<T>(Future<T> future, Duration timeout, String operation) async {
    try {
      return await future.timeout(timeout, onTimeout: () {
        print('⏰ [TIMEOUT] $operation timed out after ${timeout.inSeconds} seconds');
        throw TimeoutException('$operation timed out after ${timeout.inSeconds} seconds');
      });
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw e;
    }
  }

  // Test Firestore connectivity
  Future<bool> testFirestoreConnection() async {
    try {
      print('🔍 [AUTH] Testing Firestore connection...');
      final isConnected = await _firestoreService.testFirestoreConnection();
      print('${isConnected ? "✅" : "❌"} [AUTH] Firestore connection test: ${isConnected ? "PASSED" : "FAILED"}');
      return isConnected;
    } catch (e) {
      print('❌ [AUTH] Firestore connection test failed: $e');
      return false;
    }
  }

  // Sign up HR Administrator
  Future<Map<String, dynamic>> signUpHrAdmin({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 [SIGNUP] Starting HR signup process...');
      print('📝 [SIGNUP] Data received - Name: $fullName, Username: $username, Email: $email');
      
      _isLoading = true;
      notifyListeners();
      print('⏳ [SIGNUP] Loading state set to true');

      // Skip Firestore connection test during signup since user isn't authenticated yet
      print('⏭️ [SIGNUP] Skipping initial Firestore connection test (user not authenticated yet)');

      // Check if email already exists with timeout
      print('🔍 [SIGNUP] Checking if email already exists: $email');
      final existingUser = await _withTimeout(
        _firestoreService.getUserByEmail(email),
        const Duration(seconds: 10),
        'Email existence check'
      );
      
      if (existingUser != null) {
        print('❌ [SIGNUP] Email already exists: $email');
        return {
          'success': false,
          'message': 'Email already registered. Please use a different email.',
        };
      }
      print('✅ [SIGNUP] Email is unique');

      // Check if username already exists with timeout
      print('🔍 [SIGNUP] Checking if username already exists: $username');
      final existingUsername = await _withTimeout(
        _firestoreService.usernameExists(username),
        const Duration(seconds: 10),
        'Username existence check'
      );
      
      if (existingUsername) {
        print('❌ [SIGNUP] Username already exists: $username');
        return {
          'success': false,
          'message': 'Username already taken. Please choose a different username.',
        };
      }
      print('✅ [SIGNUP] Username is unique');

      // Create Firebase Auth user with timeout
      print('🔥 [SIGNUP] Creating Firebase Auth user...');
      final UserCredential userCredential = await _withTimeout(
        _auth.createUserWithEmailAndPassword(email: email, password: password),
        const Duration(seconds: 15),
        'Firebase Auth user creation'
      );
      print('✅ [SIGNUP] Firebase Auth user created successfully');

      final User firebaseUser = userCredential.user!;
      print('🆔 [SIGNUP] Firebase user UID: ${firebaseUser.uid}');

      // Create UserModel for Firestore
      print('📋 [SIGNUP] Creating UserModel for Firestore...');
      final UserModel userModel = UserModel(
        uid: firebaseUser.uid,
        username: username,
        email: email,
        role: RoleConstants.HR_ADMIN,
        isActive: false, // HR accounts start as inactive
        createdAt: DateTime.now(),
      );
      print('✅ [SIGNUP] UserModel created');

      // Store user data in Firestore with timeout
      print('💾 [SIGNUP] Storing user data in Firestore...');
      await _withTimeout(
        _firestoreService.createUserAccount(userModel),
        const Duration(seconds: 15),
        'Firestore user creation'
      );
      print('✅ [SIGNUP] User data stored in Firestore successfully');

      // Sign out the user (they need to be approved first)
      print('🚪 [SIGNUP] Signing out user (pending approval)...');
      await _auth.signOut();
      print('✅ [SIGNUP] User signed out successfully');

      print('🎉 [SIGNUP] HR signup process completed successfully!');
      return {
        'success': true,
        'message': 'HR account created successfully. Please wait for Super Admin approval.',
      };
    } on TimeoutException catch (e) {
      print('⏰ [SIGNUP] Timeout error: ${e.message}');
      return {
        'success': false,
        'message': 'Operation timed out. Please check your internet connection and try again.',
      };
    } catch (e) {
      print('💥 [SIGNUP] Error occurred during signup: $e');
      String errorMessage = 'Failed to create HR account.';
      
      if (e is FirebaseAuthException) {
        print('🔥 [SIGNUP] Firebase Auth Exception - Code: ${e.code}, Message: ${e.message}');
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email already registered. Please use a different email.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak. Please choose a stronger password.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address. Please enter a valid email.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection.';
            break;
          default:
            errorMessage = 'Authentication error: ${e.message}';
        }
      } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      }
      
      print('❌ [SIGNUP] Returning error: $errorMessage');
      return {
        'success': false,
        'message': errorMessage,
      };
    } finally {
      print('🏁 [SIGNUP] Setting loading to false');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign in with Firebase Auth
      final UserCredential userCredential = await _withTimeout(
        _auth.signInWithEmailAndPassword(email: email, password: password),
        const Duration(seconds: 15),
        'Firebase Auth sign in'
      );

      final User firebaseUser = userCredential.user!;

      // Get user data from Firestore
      final UserModel? userModel = await _withTimeout(
        _firestoreService.getUserByUid(firebaseUser.uid),
        const Duration(seconds: 10),
        'Get user from Firestore'
      );
      
      if (userModel == null) {
        // User exists in Auth but not in Firestore - sign out and show error
        await _auth.signOut();
        return {
          'success': false,
          'message': 'User account not found. Please contact administrator.',
        };
      }

      // Check if account is active
      if (!userModel.isActive) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Account pending approval. Please wait for administrator approval.',
        };
      }

      // Update last login
      await _withTimeout(
        _firestoreService.updateLastLogin(firebaseUser.uid),
        const Duration(seconds: 5),
        'Update last login'
      );

      // Set current user model
      _userModel = userModel;

      return {
        'success': true,
        'message': 'Login successful.',
        'userModel': userModel,
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Login timed out. Please check your internet connection and try again.',
      };
    } catch (e) {
      String errorMessage = 'Login failed.';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email address.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            break;
          case 'user-disabled':
            errorMessage = 'Account has been disabled. Please contact administrator.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection.';
            break;
          default:
            errorMessage = 'Authentication error: ${e.message}';
        }
      } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // For web, we'll use a simple email/password for demo
      // In a real app, you'd implement Google Sign-In
      if (kIsWeb) {
        // Demo sign-in for web
        return await _auth.signInAnonymously();
      } else {
        // For mobile, implement Google Sign-In
        // This is a placeholder - you'll need to add google_sign_in package
        throw UnsupportedError('Google Sign-In not implemented yet');
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signOut();
      _userModel = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Get user display name
  String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  // Get user email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get user photo URL
  String? getUserPhotoURL() {
    return _auth.currentUser?.photoURL;
  }
} 