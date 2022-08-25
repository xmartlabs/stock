#!/bin/bash
RED='\033[0;31m'

echo ':: Get dependencies ::'
flutter pub get

echo ':: Check code format ::'
flutter format --set-exit-if-changed . || { echo -e "${RED}Invalid format" ; exit 1; }

echo ':: Run linter ::'
flutter analyze . || { echo -e "${RED}Linter error" ; exit 1; }

result=$(flutter pub run dart_code_metrics:metrics analyze lib  --fatal-style --fatal-performance --fatal-warnings)
echo "$result"
[[ $result == '✔ no issues found!' ]] || { echo -e "${RED}Linter error" ; exit 1; }

flutter pub run dart_code_metrics:metrics check-unused-code lib --fatal-unused || { echo -e "${RED}Linter error" ; exit 1; }

flutter pub run dart_code_metrics:metrics check-unused-files lib  --fatal-unused || { echo -e "${RED}Linter error" ; exit 1; }

echo ':: Run tests ::'
flutter test || { echo -e "${RED}Test error" ; exit 1; }
