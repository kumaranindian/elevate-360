@echo off
echo ========================================
echo    Elevate-360 Firebase Deployment
echo ========================================
echo.

echo [1/4] Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)

echo [2/4] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

echo [3/4] Building for web...
flutter build web --release
if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)

echo [4/4] Deploying to Firebase...
firebase deploy --only hosting
if %errorlevel% neq 0 (
    echo ERROR: Firebase deployment failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo    Deployment Complete!
echo ========================================
echo.
echo Live URL: https://elevate-360-5f40b.web.app
echo Firebase Console: https://console.firebase.google.com/project/elevate-360-5f40b/overview
echo.
pause 