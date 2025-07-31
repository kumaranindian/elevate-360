import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../services/elevate360_data_setup.dart';

void main() async {
  try {
    print('🚀 Starting Elevate360 setup script...');
    print('=====================================');
    
    // Initialize Firebase
    print('📡 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Run the Elevate360 data setup
    print('📋 Starting Elevate360 data setup...');
    final setup = Elevate360DataSetup();
    await setup.setupElevate360Data();
    
    print('✅ Elevate360 data setup completed successfully!');
    print('\n📊 Data Summary:');
    print('• 19 Users created with proper hierarchy');
    print('• 6 Departments (Engineering, QA, DevOps, PM, HR, Sales)');
    print('• 6 Teams with realistic structure');
    print('• 5 Goal categories (Productivity, Skill Development, Team Collaboration, Quality, Customer Satisfaction)');
    print('• Q1 & Q2 2025 performance data');
    print('• Comprehensive review system');
    
    print('\n👤 Test Accounts Created:');
    print('• malai@ideas2it.com (Admin@1234) - Engineering Manager (Multi-team)');
    print('• jennifer@ideas2it.com (Admin@1234) - HR Manager (Full access)');
    print('• sarah@ideas2it.com (Admin@1234) - HR Executive (Read-only)');
    print('• james@ideas2it.com (Admin@1234) - QA Manager');
    print('• maria@ideas2it.com (Admin@1234) - DevOps Manager');
    print('• david@ideas2it.com (Admin@1234) - Sales Manager');
    print('• gautam@ideas2it.com (Admin@1234) - Senior Software Engineer');
    print('• mukilan@ideas2it.com (Admin@1234) - Senior Software Engineer');
    print('• karthi@ideas2it.com (Admin@1234) - Senior Software Engineer');
    print('• ramiz@ideas2it.com (Admin@1234) - Senior QA Engineer');
    print('• niranjan@ideas2it.com (Admin@1234) - Senior DevOps Engineer');
    print('• And 8 more employees...');
    
    print('\n🎯 Collections Created:');
    print('• system_roles - Role-based access control');
    print('• departments - Company departments');
    print('• roles - Job positions and levels');
    print('• teams - Team structures');
    print('• employees - Employee records');
    print('• user_accounts - Authentication data');
    print('• goals - Employee objectives');
    print('• goal_categories - Goal classification');
    print('• reviews - Performance reviews');
    print('• projects - Project information');
    
    print('\n🔐 Role-Based Access Control:');
    print('• Employee - Own data only');
    print('• Manager - Self + Direct reportees');
    print('• HR Manager - All teams + Self');
    print('• HR (Non-Manager) - Cross-team (read-only) + Self');
    
    print('\n📅 Performance Data Periods:');
    print('• Q1 2025 (Jan 1, 2025 – Mar 31, 2025)');
    print('• Q2 2025 (Apr 1, 2025 – Jun 30, 2025)');
    print('• 3-4 goals per user per quarter');
    print('• Self, Manager, and HR reviews');
    
    print('\n🎉 Setup completed successfully!');
    print('You can now run the Flutter app and test with any of the accounts above.');
    print('\nFirebase Console: https://console.firebase.google.com/project/elevate-360-5f40b/firestore');
    
  } catch (e) {
    print('❌ Error during Elevate360 setup: $e');
    print('\n🔧 Troubleshooting Tips:');
    print('1. Check Firebase configuration in firebase_options.dart');
    print('2. Verify Firestore security rules are deployed');
    print('3. Ensure Firebase project is properly set up');
    print('4. Check network connection');
    print('5. Verify Firebase Authentication is enabled');
    
    if (e.toString().contains('permission-denied')) {
      print('\n🚫 Permission Denied Error:');
      print('• Deploy Firestore security rules: firebase deploy --only firestore:rules');
      print('• Check if Firebase project is correctly configured');
      print('• Verify authentication is enabled in Firebase Console');
    } else if (e.toString().contains('unavailable')) {
      print('\n🌐 Service Unavailable Error:');
      print('• Check network connection');
      print('• Verify Firebase project is active');
      print('• Try again in a few minutes');
    }
    
    print('\nFor more help, check the ELEVATE360_IMPLEMENTATION_GUIDE.md file.');
  }
} 