import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:ui';
import 'firebase_options.dart';
import 'app/app.dart';
import 'services/index_initialization_service.dart';

// Global error handler for debugging
void _handleError(FlutterErrorDetails details) {
  debugPrint('=== FLUTTER ERROR ===');
  debugPrint('Error: ${details.exception}');
  debugPrint('Stack trace: ${details.stack}');
  debugPrint('Library: ${details.library}');
  debugPrint('Context: ${details.context}');
  debugPrint('===================');
}

void main() async {
  try {
    // Enhanced error handling for real devices
    FlutterError.onError = _handleError;
    
    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('=== PLATFORM ERROR ===');
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stack');
      debugPrint('====================');
      return true;
    };

    debugPrint('=== APP STARTUP ===');
    debugPrint('Initializing Flutter binding...');
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint('Setting preferred orientations...');
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    // Initialize Firestore indexes
    debugPrint('Initializing Firestore indexes...');
    try {
      await IndexInitializationService.checkAndCreateIndexes();
      debugPrint('Index initialization completed');
    } catch (e) {
      debugPrint('Warning: Index initialization failed: $e');
      debugPrint('App will continue with fallback queries');
    }

    debugPrint('Starting app...');
    runApp(
      const ProviderScope(
        child: Elevate360App(),
      ),
    );
    debugPrint('App started successfully');

  } catch (e, stackTrace) {
    debugPrint('=== STARTUP ERROR ===');
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    debugPrint('====================');
    
    // Try to show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'App failed to start',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    SystemNavigator.pop();
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
