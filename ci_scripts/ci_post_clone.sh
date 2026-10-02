#!/bin/bash
set -e

# Pass the Honeybadger API key from the Xcode Cloud secret environment
# variable into the build (see Configuration/App.xcconfig).
if [ -n "${HONEYBADGER_API_KEY:-}" ]; then
  printf 'HONEYBADGER_API_KEY = %s\n' "$HONEYBADGER_API_KEY" \
    > "$CI_PRIMARY_REPOSITORY_PATH/Configuration/Secrets.xcconfig"
  echo "Wrote Configuration/Secrets.xcconfig"
else
  echo "warning: HONEYBADGER_API_KEY is not set; Honeybadger will be disabled in this build"
fi

# Resolve Swift package dependencies after cloning
xcodebuild -resolvePackageDependencies \
  -project "$CI_PRIMARY_REPOSITORY_PATH/Cluster Headache Tracker.xcodeproj" \
  -scheme "Cluster Headache Tracker"
