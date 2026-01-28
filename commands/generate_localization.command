#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "${DIR}"
flutter pub run easy_localization:generate --source-dir ./assets/translations
flutter pub run easy_localization:generate --source-dir ./assets/translations -f keys -o locale_keys.g.dart