@echo off
echo ========================================
echo    Deploying Firestore Rules
echo ========================================
echo.

echo [1/2] Deploying Firestore security rules...
firebase deploy --only firestore:rules
if %errorlevel% neq 0 (
    echo ERROR: Firestore rules deployment failed!
    pause
    exit /b 1
)

echo [2/2] Deploying Firestore indexes...
firebase deploy --only firestore:indexes
if %errorlevel% neq 0 (
    echo ERROR: Firestore indexes deployment failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo    Firestore Rules Deployed!
echo ========================================
echo.
echo Firestore Console: https://console.firebase.google.com/project/elevate-360-5f40b/firestore
echo.
pause 