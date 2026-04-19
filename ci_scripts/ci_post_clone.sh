#!/bin/bash
set -e

# Resolve Swift package dependencies after cloning
xcodebuild -resolvePackageDependencies \
  -project "$CI_PRIMARY_REPOSITORY_PATH/Cluster Headache Tracker.xcodeproj" \
  -scheme "Cluster Headache Tracker"
