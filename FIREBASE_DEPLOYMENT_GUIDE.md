# Firebase Deployment Guide - Elevate-360

This guide covers the complete Firebase setup and deployment process for the Elevate-360 Flutter application.

## 🚀 Current Deployment Status

- **Live URL**: https://elevate-360-5f40b.web.app
- **Project ID**: elevate-360-5f40b
- **Firebase Console**: https://console.firebase.google.com/project/elevate-360-5f40b/overview

## 📋 Prerequisites

### Required Tools
- Flutter SDK (>=3.0.0)
- Node.js and npm
- Firebase CLI
- Git (for version control)

### Installation Commands
```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Set PowerShell execution policy (Windows)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🔧 Firebase Configuration Files

### 1. firebase.json
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### 2. .firebaserc
```json
{
  "projects": {
    "default": "elevate-360-5f40b"
  }
}
```

### 3. lib/firebase_options.dart
```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAVK-DtyVxwWL6fB4O8oxaqWmDptLlZ8A0",
    authDomain: "elevate-360-5f40b.firebaseapp.com",
    projectId: "elevate-360-5f40b",
    storageBucket: "elevate-360-5f40b.firebasestorage.app",
    messagingSenderId: "1063730194040",
    appId: "1:1063730194040:web:5bbd4bb0e9d9ac13632f8d",
    measurementId: "G-9DZ61NM6JB",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-api-key-here',
    appId: '1:1063730194040:android:7ed3bf2d007d78dd632f8d',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'elevate-360-app',
    storageBucket: 'elevate-360-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-api-key-here',
    appId: 'your-app-id-here',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'elevate-360-app',
    storageBucket: 'elevate-360-app.appspot.com',
    iosBundleId: 'com.elevate360.elevate360',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-api-key-here',
    appId: 'your-app-id-here',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'elevate-360-app',
    storageBucket: 'elevate-360-app.appspot.com',
    iosBundleId: 'com.elevate360.elevate360',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-api-key-here',
    appId: 'your-app-id-here',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'elevate-360-app',
    storageBucket: 'elevate-360-app.appspot.com',
  );
}
```

## 🚀 Deployment Process

### Initial Setup (One-time)
```bash
# 1. Login to Firebase
firebase login

# 2. Initialize Firebase project (if not already done)
firebase init hosting

# 3. Select your project: elevate-360-5f40b
# 4. Set public directory: build/web
# 5. Configure as single-page app: Yes
# 6. Set up automatic builds: No
```

### Build and Deploy
```bash
# 1. Clean previous builds
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build for web
flutter build web --release

# 4. Deploy to Firebase
firebase deploy --only hosting
```

### Quick Deploy Script
Create a `deploy.bat` (Windows) or `deploy.sh` (Linux/Mac) file:

**Windows (deploy.bat):**
```batch
@echo off
echo Building Flutter app...
flutter clean
flutter pub get
flutter build web --release
echo Deploying to Firebase...
firebase deploy --only hosting
echo Deployment complete!
pause
```

**Linux/Mac (deploy.sh):**
```bash
#!/bin/bash
echo "Building Flutter app..."
flutter clean
flutter pub get
flutter build web --release
echo "Deploying to Firebase..."
firebase deploy --only hosting
echo "Deployment complete!"
```

## 🔄 Future Deployments

### Method 1: Manual Deployment
```bash
# Navigate to project directory
cd elevate-360

# Build and deploy
flutter build web --release
firebase deploy --only hosting
```

### Method 2: Using Deploy Script
```bash
# Windows
./deploy.bat

# Linux/Mac
./deploy.sh
```

### Method 3: CI/CD Pipeline (GitHub Actions)
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Firebase

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Install Firebase CLI
      run: npm install -g firebase-tools
    
    - name: Build Flutter app
      run: |
        flutter clean
        flutter pub get
        flutter build web --release
    
    - name: Deploy to Firebase
      run: firebase deploy --only hosting --token "${{ secrets.FIREBASE_TOKEN }}"
```

## 🔧 Firebase Project Configuration

### Authentication Setup
1. Go to Firebase Console → Authentication
2. Enable Anonymous Authentication
3. Add Google Sign-In provider (for production)
4. Configure authorized domains

### Hosting Configuration
1. Go to Firebase Console → Hosting
2. Verify domain settings
3. Set up custom domain (optional)
4. Configure redirects and rewrites

### Security Rules
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📱 Platform-Specific Configurations

### Android Configuration
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/`
3. Update `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
}
```

### iOS Configuration
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place in `ios/Runner/`
3. Add to Xcode project

### Web Configuration
1. Update `web/index.html` for Firebase SDK
2. Configure Firebase Hosting settings
3. Set up custom domain (optional)

## 🔍 Troubleshooting

### Common Issues

**1. Build Errors**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

**2. Firebase CLI Issues**
```bash
# Reinstall Firebase CLI
npm uninstall -g firebase-tools
npm install -g firebase-tools

# Login again
firebase logout
firebase login
```

**3. Permission Issues (Windows)**
```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**4. Cache Issues**
```bash
# Clear Firebase cache
firebase logout
firebase login
firebase use --clear
firebase use elevate-360-5f40b
```

### Debug Commands
```bash
# Check Firebase project
firebase projects:list

# Check current project
firebase use

# Test hosting locally
firebase serve

# View deployment history
firebase hosting:releases:list
```

## 📊 Monitoring and Analytics

### Firebase Analytics
- View user engagement in Firebase Console
- Track app performance and crashes
- Monitor user behavior and demographics

### Performance Monitoring
- Set up Firebase Performance Monitoring
- Track app load times and user interactions
- Monitor API response times

### Error Reporting
- Configure Firebase Crashlytics
- Set up error alerting
- Monitor app stability

## 🔐 Security Best Practices

### Environment Variables
```bash
# Create .env file for sensitive data
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=elevate-360-5f40b
```

### Security Rules
```javascript
// Example Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /public/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 📈 Scaling Considerations

### Performance Optimization
- Enable Firebase CDN
- Optimize image assets
- Implement lazy loading
- Use Firebase caching strategies

### Cost Management
- Monitor Firebase usage
- Set up billing alerts
- Optimize database queries
- Use Firebase pricing calculator

## 🎯 Next Steps

### Immediate Actions
1. [ ] Test the live application
2. [ ] Set up custom domain
3. [ ] Configure analytics
4. [ ] Set up monitoring alerts

### Future Enhancements
1. [ ] Implement CI/CD pipeline
2. [ ] Add automated testing
3. [ ] Set up staging environment
4. [ ] Configure backup strategies

### Production Checklist
- [ ] Update Firebase configuration with production values
- [ ] Set up proper authentication methods
- [ ] Configure security rules
- [ ] Set up monitoring and alerting
- [ ] Test all features thoroughly
- [ ] Optimize performance
- [ ] Set up backup and recovery procedures

---

**Last Updated**: July 29, 2025  
**Deployment URL**: https://elevate-360-5f40b.web.app  
**Project ID**: elevate-360-5f40b

For support or questions, refer to the main README.md file or contact the development team. 