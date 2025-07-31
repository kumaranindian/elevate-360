@echo off
echo ========================================
echo Firebase Data Setup for Grow360
echo ========================================
echo.

echo Starting Firebase data setup...
echo.

cd /d "%~dp0"

echo Running Flutter Firebase setup...
flutter run -d chrome --target lib/scripts/firebase_setup_script.dart

echo.
echo ========================================
echo Setup completed!
echo ========================================
echo.
echo Test Accounts:
echo • mukilan@ideas2it.com (Admin@1234)
echo • karthi@ideas2it.com (Admin@1234)
echo • gautam@ideas2it.com (Admin@1234)
echo • niranjan@ideas2it.com (Admin@1234)
echo • ramiz@ideas2it.com (Admin@1234)
echo • malai@ideas2it.com (Admin@1234)
echo • jennifer@ideas2it.com (Admin@1234)
echo.
echo You can now run the main app with: flutter run
echo.
pause 