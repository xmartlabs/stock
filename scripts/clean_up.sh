#!/bin/bash
echo ':: flutter clean ::'
flutter clean

echo ':: flutter pub get ::'
flutter pub get

echo ':: flutter pub run build_runner build --delete-conflicting-outputs ::'
flutter pub run build_runner build --delete-conflicting-outputs
