#!/bin/bash
flutter clean &&
flutter pub get &&
flutter build ios --release --no-codesign &&
cd ./ios &&
fastlane beta