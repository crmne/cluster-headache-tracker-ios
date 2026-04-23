#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: Scripts/archive-release.sh [VERSION_TAG] [BUILD_NUMBER] [ARCHIVE_PATH]

Examples:
  Scripts/archive-release.sh v2.1.1
  Scripts/archive-release.sh v2.1.1 20101
  Scripts/archive-release.sh v2.1.1 20101 build/ClusterHeadacheTracker.xcarchive

If VERSION_TAG is omitted, the script requires the current commit to be checked out at
an exact vX.Y.Z tag.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

tag="${1:-}"

if [[ -z "$tag" ]]; then
  tag="$(git describe --tags --exact-match 2>/dev/null || true)"
fi

if [[ -z "$tag" ]]; then
  echo "No release tag provided and HEAD is not at an exact vX.Y.Z tag."
  exit 1
fi

version="${tag#v}"

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Release tags must use stable semver, for example v2.1.1."
  exit 1
fi

IFS='.' read -r major minor patch <<< "$version"
default_build_number=$((major * 10000 + minor * 100 + patch))

build_number="${2:-$default_build_number}"
archive_path="${3:-build/ClusterHeadacheTracker.xcarchive}"

xcodebuild archive \
  -project "Cluster Headache Tracker.xcodeproj" \
  -scheme "Cluster Headache Tracker" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$archive_path" \
  APP_VERSION="$version" \
  APP_BUILD_NUMBER="$build_number"
