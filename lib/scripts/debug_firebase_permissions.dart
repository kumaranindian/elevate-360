import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('✅ Firebase initialized successfully');
    
    // Test authentication
    final auth = FirebaseAuth.instance;
    print('🔐 Testing authentication...');
    
    // Try to sign in with a test account
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: 'malai@ideas2it.com',
        password: 'Admin@1234',
      );
      
      if (userCredential.user != null) {
        print('✅ Authentication successful');
        print('👤 User ID: ${userCredential.user!.uid}');
        print('📧 Email: ${userCredential.user!.email}');
      } else {
        print('❌ Authentication failed - no user returned');
        return;
      }
    } catch (e) {
      print('❌ Authentication failed: $e');
      return;
    }
    
    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    print('\n📊 Testing Firestore collections...');
    
    // Test reading from different collections
    final collections = [
      'employees',
      'goals', 
      'reviews',
      'goal_categories',
      'departments',
      'teams',
      'user_accounts',
    ];
    
    for (final collection in collections) {
      try {
        print('\n🔍 Testing collection: $collection');
        final snapshot = await firestore.collection(collection).limit(1).get();
        print('✅ Successfully read from $collection (${snapshot.docs.length} documents)');
        
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          print('📄 Sample document ID: ${doc.id}');
          print('📄 Sample document data: ${doc.data()}');
        }
      } catch (e) {
        print('❌ Failed to read from $collection: $e');
      }
    }
    
    // Test specific queries
    print('\n🔍 Testing specific queries...');
    
    try {
      // Test goals query
      final goalsSnapshot = await firestore.collection('goals').get();
      print('✅ Goals query successful: ${goalsSnapshot.docs.length} goals found');
    } catch (e) {
      print('❌ Goals query failed: $e');
    }
    
    try {
      // Test employees query
      final employeesSnapshot = await firestore.collection('employees').get();
      print('✅ Employees query successful: ${employeesSnapshot.docs.length} employees found');
    } catch (e) {
      print('❌ Employees query failed: $e');
    }
    
    try {
      // Test reviews query
      final reviewsSnapshot = await firestore.collection('reviews').get();
      print('✅ Reviews query successful: ${reviewsSnapshot.docs.length} reviews found');
    } catch (e) {
      print('❌ Reviews query failed: $e');
    }
    
    // Test user account lookup
    try {
      final userDoc = await firestore.collection('user_accounts').doc(auth.currentUser!.uid).get();
      if (userDoc.exists) {
        print('✅ User account found');
        print('👤 User role: ${userDoc.data()?['role']}');
      } else {
        print('⚠️ User account not found in user_accounts collection');
      }
    } catch (e) {
      print('❌ User account lookup failed: $e');
    }
    
    print('\n🎉 Firebase permission test completed!');
    
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  exit(0);
} 