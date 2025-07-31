@echo off
echo ========================================
echo Elevate360 Data Setup
echo ========================================
echo.

echo [1/3] Deploying Firestore security rules...
firebase deploy --only firestore:rules
if %errorlevel% neq 0 (
    echo ERROR: Firestore rules deployment failed!
    echo Please check your Firebase configuration.
    pause
    exit /b 1
)

echo.
echo [2/3] Starting Elevate360 data setup...
echo.
echo This will create:
echo • 19 Users with proper hierarchy
echo • Q1 & Q2 2025 performance data
echo • Refined role-based access control
echo • Comprehensive goal and review system
echo.
echo Test Accounts:
echo • malai@ideas2it.com (Manager - Multi-team)
echo • jennifer@ideas2it.com (HR Manager)
echo • sarah@ideas2it.com (HR - Read-only)
echo • All accounts use password: Admin@1234
echo.

flutter run -d chrome --target lib/scripts/elevate360_setup_script.dart

echo.
echo [3/3] Setup completed!
echo.
echo ========================================
echo Elevate360 Setup Complete!
echo ========================================
echo.
echo You can now:
echo 1. Run the main app: flutter run
echo 2. Login with any test account
echo 3. Explore the performance management system
echo.
echo Firebase Console: https://console.firebase.google.com/project/elevate-360-5f40b/firestore
echo.
pause 