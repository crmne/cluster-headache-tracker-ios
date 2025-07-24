# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Hotwire Native iOS wrapper application for the Cluster Headache Tracker web application (https://clusterheadachetracker.com). The app provides a native iOS experience while serving web content through Hotwire Native framework.

## Build Commands

```bash
# Open project in Xcode
open "Cluster Headache Tracker.xcodeproj"

# Build from command line
xcodebuild -project "Cluster Headache Tracker.xcodeproj" -scheme "Cluster Headache Tracker" -configuration Debug build

# Run tests
xcodebuild test -project "Cluster Headache Tracker.xcodeproj" -scheme "Cluster Headache Tracker" -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build
xcodebuild -project "Cluster Headache Tracker.xcodeproj" -scheme "Cluster Headache Tracker" clean

# Resolve SPM dependencies
xcodebuild -resolvePackageDependencies -project "Cluster Headache Tracker.xcodeproj"

# Archive for distribution
xcodebuild -project "Cluster Headache Tracker.xcodeproj" -scheme "Cluster Headache Tracker" -configuration Release archive -archivePath build/ClusterHeadacheTracker.xcarchive
```

## Architecture

This is a **Hotwire Native wrapper app** with minimal native code:

### Core Components
- **AppDelegate.swift**: Configures Hotwire Native with path configurations loaded from `configurations/ios_v1.json` and remote server
- **SceneDelegate.swift**: Entry point that creates a Navigator routing to `/headache_logs` on the web app
- **configurations/ios_v1.json**: Defines routing rules for different URLs (modal vs replace presentation)

### Key Characteristics
- The app wraps the web application at `https://clusterheadachetracker.com`
- Uses Hotwire Native v1.2.0 as the only dependency (via Swift Package Manager)
- Navigation bars are hidden for both root and modal presentations
- Form pages (`/headache_logs/new`, edit pages) open as modals without pull-to-refresh
- Main pages (`/headache_logs`, `/charts`, `/settings`, `/feedback`) use replace presentation

### Requirements
- iOS 15.6+ deployment target
- Xcode 15.0+
- Swift 5.0+

When modifying this app, remember that most functionality lives in the web application. Native iOS changes should focus on navigation, presentation, and Hotwire Native configuration rather than implementing features directly in Swift.