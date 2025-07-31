# Elevate-360 - Employee Performance Monitoring System

A modern Flutter application for monitoring and managing employee performance with a clean, professional interface.

## Features

- **Modern UI/UX**: Clean, responsive design with smooth animations
- **Firebase Integration**: Authentication and real-time data management
- **Cross-Platform**: Works on Web, Android, iOS, and Desktop
- **State Management**: Riverpod for efficient state management
- **Professional Theme**: Custom Material Design theme with consistent branding

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd elevate-360
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   **For Web:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add a web app to your project
   - Copy the Firebase config to `lib/firebase_options.dart`
   - Replace the placeholder values with your actual Firebase configuration

   **For Android:**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`
   - Update the Firebase config in `lib/firebase_options.dart`

   **For iOS:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/`
   - Update the Firebase config in `lib/firebase_options.dart`

4. **Run the application**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

## Project Structure

```
lib/
├── app/
│   └── app.dart                 # Main app configuration
├── core/
│   ├── models/                  # Data models
│   ├── providers/               # Riverpod providers
│   ├── routes/                  # App routing
│   ├── services/                # Business logic services
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Reusable widgets
├── features/
│   ├── auth/                    # Authentication feature
│   ├── dashboard/               # Dashboard feature
│   └── onboarding/              # Onboarding feature
├── firebase_options.dart        # Firebase configuration
└── main.dart                    # App entry point
```

## Firebase Configuration

Update the Firebase configuration in `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-api-key-here',
  appId: 'your-app-id-here',
  messagingSenderId: 'your-sender-id-here',
  projectId: 'elevate-360-app',
  authDomain: 'elevate-360-app.firebaseapp.com',
  storageBucket: 'elevate-360-app.appspot.com',
  measurementId: 'your-measurement-id-here',
);
```

## Features Overview

### Authentication
- Google Sign-In integration
- Anonymous authentication for demo
- User profile management
- Secure logout functionality

### UI Components
- Responsive design for all screen sizes
- Smooth animations and transitions
- Professional color scheme
- Material Design 3 components

### State Management
- Riverpod for reactive state management
- Provider pattern for dependency injection
- Stream-based authentication state

## Development

### Adding New Features

1. Create feature directory in `lib/features/`
2. Follow the feature structure:
   ```
   feature_name/
   ├── data/
   ├── domain/
   └── presentation/
   ```

### Code Style

- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

## Dependencies

### Core Dependencies
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `flutter_riverpod`: State management
- `go_router`: Navigation
- `flutter_animate`: Animations

### UI Dependencies
- `flutter_svg`: SVG support
- `cached_network_image`: Image caching
- `shimmer`: Loading effects
- `lottie`: Animation support

## Deployment

### Web Deployment
```bash
flutter build web
# Deploy the build/web directory to your hosting service
```

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## Roadmap

- [ ] Dashboard implementation
- [ ] Employee management features
- [ ] Performance tracking
- [ ] Reporting and analytics
- [ ] Mobile app store deployment
- [ ] Advanced authentication methods
- [ ] Real-time notifications
- [ ] Data export functionality

---

**Elevate-360** - Empowering organizations to monitor and improve employee performance through modern technology.
