import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

void main() async {
  try {
    print('🔍 Testing Firebase connection...');
    print('================================');
    
    // Initialize Firebase
    print('📡 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Firestore connection
    print('📊 Testing Firestore connection...');
    final firestore = FirebaseFirestore.instance;
    
    // Test if we can access Firestore
    print('🔍 Testing Firestore instance...');
    final collectionRef = firestore.collection('test_connection');
    print('✅ Firestore instance accessible');
    
    // Test write operation
    print('📝 Testing write operation...');
    await collectionRef.doc('test').set({
      'timestamp': FieldValue.serverTimestamp(),
      'test': true,
    });
    print('✅ Write operation successful');
    
    // Test read operation
    print('📖 Testing read operation...');
    final doc = await collectionRef.doc('test').get();
    print('✅ Read operation successful');
    
    // Clean up test document
    print('🧹 Cleaning up test document...');
    await collectionRef.doc('test').delete();
    print('✅ Cleanup successful');
    
    // Test Authentication
    print('🔐 Testing Firebase Authentication...');
    final auth = FirebaseAuth.instance;
    
    // Check if user is signed in
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      print('✅ User is signed in: ${currentUser.email}');
    } else {
      print('⚠️ No user signed in - this is normal for setup');
    }
    
    print('\n🎉 All Firebase tests passed!');
    print('Firebase connection is working properly.');
    print('You can now run the Elevate360 setup.');
    
  } catch (e) {
    print('❌ Firebase connection test failed: $e');
    print('\n🔧 Troubleshooting:');
    print('1. Check Firebase project configuration');
    print('2. Verify Firestore is enabled in Firebase Console');
    print('3. Check network connection');
    print('4. Ensure Firebase Authentication is enabled');
    
    if (e.toString().contains('permission-denied')) {
      print('\n🚫 Permission Error:');
      print('• Deploy Firestore rules: firebase deploy --only firestore:rules');
      print('• Check if Firestore is enabled in Firebase Console');
    }
  }
} 