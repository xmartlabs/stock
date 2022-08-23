#!/bin/bash
RED='\033[0;31m'

echo ':: Get dependencies ::'
flutter pub get

echo ':: Check code format ::'
flutter format --set-exit-if-changed . || { echo -e "${RED}Invalid format" ; exit 1; }

echo ':: Run linter ::'
flutter analyze . || { echo -e "${RED}Linter error" ; exit 1; }

echo ':: Run tests ::'
flutter test || { echo -e "${RED}Test error" ; exit 1; }
