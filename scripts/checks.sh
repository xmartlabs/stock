#!/bin/bash
RED='\033[0;31m'

echo ':: Get dependencies ::'
fvm dart pub get

echo ':: Check code format ::'
fvm dart format --set-exit-if-changed . || { echo -e "${RED}Invalid format" ; exit 1; }

echo ':: Run dart linter ::'
fvm dart analyze --fatal-infos || { echo -e "${RED}Linter error" ; exit 1; }

echo ':: Run flutter linter ::'
fvm flutter analyze --fatal-infos || { echo -e "${RED}Linter error" ; exit 1; }

echo ':: Run tests ::'
fvm dart test || { echo -e "${RED}Test error" ; exit 1; }
