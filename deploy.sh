#!/bin/bash

echo "========================================"
echo "   Elevate-360 Firebase Deployment"
echo "========================================"
echo

echo "[1/4] Cleaning previous builds..."
flutter clean
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter clean failed!"
    exit 1
fi

echo "[2/4] Getting dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter pub get failed!"
    exit 1
fi

echo "[3/4] Building for web..."
flutter build web --release
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter build failed!"
    exit 1
fi

echo "[4/4] Deploying to Firebase..."
firebase deploy --only hosting
if [ $? -ne 0 ]; then
    echo "ERROR: Firebase deployment failed!"
    exit 1
fi

echo
echo "========================================"
echo "   Deployment Complete!"
echo "========================================"
echo
echo "Live URL: https://elevate-360-5f40b.web.app"
echo "Firebase Console: https://console.firebase.google.com/project/elevate-360-5f40b/overview"
echo 