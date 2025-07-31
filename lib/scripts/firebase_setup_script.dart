import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../services/firebase_data_setup.dart';

void main() async {
  try {
    print('🚀 Starting Firebase setup script...');
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('✅ Firebase initialized');
    
    // Run the setup
    final setup = FirebaseDataSetup();
    await setup.setupCompleteData();
    
    print('✅ Firebase data setup completed successfully!');
    print('\n📋 Test Accounts Created:');
    print('• mukilan@ideas2it.com (Admin@1234) - Backend Senior Developer');
    print('• karthi@ideas2it.com (Admin@1234) - Backend Senior Developer');
    print('• gautam@ideas2it.com (Admin@1234) - Frontend Senior Developer');
    print('• niranjan@ideas2it.com (Admin@1234) - DevOps Engineer');
    print('• ramiz@ideas2it.com (Admin@1234) - Senior QA Engineer');
    print('• lingesh@ideas2it.com (Admin@1234) - QA Engineer');
    print('• gomathi@ideas2it.com (Admin@1234) - QA Engineer');
    print('• malai@ideas2it.com (Admin@1234) - Engineering Manager (Multi-team)');
    print('• jennifer@ideas2it.com (Admin@1234) - HR Manager');
    print('• priya@ideas2it.com (Admin@1234) - Software Engineer');
    print('• alex@ideas2it.com (Admin@1234) - Software Engineer');
    print('• raj@ideas2it.com (Admin@1234) - Junior Software Engineer');
    print('• emily@ideas2it.com (Admin@1234) - Junior Software Engineer');
    
    print('\n🎯 Collections Created:');
    print('• system_roles');
    print('• departments');
    print('• roles');
    print('• teams');
    print('• employees');
    print('• user_accounts');
    print('• goals');
    print('• goal_categories');
    print('• projects');
    
    print('\n📊 Data Summary:');
    print('• 11 Departments');
    print('• 25+ Roles');
    print('• 6 Teams');
    print('• 14 Users/Employees');
    print('• 6 Goal Categories');
    print('• 3 Projects');
    print('• 30+ Goals');
    
    print('\n✅ Setup completed! You can now run the Flutter app and test with any of the accounts above.');
    
  } catch (e) {
    print('❌ Error during setup: $e');
    print('\n🔧 Troubleshooting:');
    print('1. Check Firebase project configuration');
    print('2. Verify Firestore security rules');
    print('3. Ensure Firebase Authentication is enabled');
    print('4. Check network connectivity');
  }
} 