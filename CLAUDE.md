# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hotwire Native iOS wrapper for the Cluster Headache Tracker web application. It provides a native iOS shell around the web app, enabling App Store distribution and native iOS features like sharing and custom navigation buttons.

## Key Architecture

The app follows Hotwire Native architecture:
- **Web Content**: The main functionality lives in the Rails web app at https://clusterheadachetracker.com
- **Native Shell**: Thin iOS wrapper that enhances the web experience with native features
- **Bridge Components**: Enable JavaScript-to-native communication for features like sharing and navigation buttons

Core navigation flow:
1. `SceneController` manages the app lifecycle and navigation
2. `SafeAreaWebViewController` displays web content respecting safe areas
3. Bridge components (`ButtonComponent`, `ShareComponent`) handle native feature requests from web
4. Authentication errors (401) trigger modal sign-in flow

## Common Development Commands

### Building and Running
```bash
# Open project in Xcode
open "Cluster Headache Tracker.xcodeproj"

# Build from command line
xcodebuild -scheme "Cluster Headache Tracker" -configuration Debug -sdk iphonesimulator

# Run tests
xcodebuild test -scheme "Cluster Headache Tracker" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Local Development Setup
1. Update `AppConfig.swift` with your local Rails server IP:
   ```swift
   static var local: URL {
       URL(string: "http://YOUR_IP:3000")!
   }
   ```
2. Ensure your local Rails server is accessible from the iOS simulator/device

## Important Files and Their Roles

- **`SceneController.swift`**: Main navigation controller, handles authentication flow and tab bar interactions
- **`AppConfig.swift`**: Environment configuration (local vs production URLs)
- **`path-configuration.json`**: Hotwire navigation rules (which URLs open as modals, enable pull-to-refresh, etc.)
- **Bridge Components** in `Bridge/`: Enable native iOS features from JavaScript

## Testing Against Local Server

The app is configured to allow insecure HTTP connections to local development servers. In debug builds, it automatically uses the local URL defined in `AppConfig.swift`.

## Adding New Native Features

To add new native features accessible from the web app:
1. Create a new bridge component in `Bridge/` directory extending `BridgeComponent`
2. Register it in `AppDelegate.swift`:
   ```swift
   Hotwire.registerBridgeComponents([
       // existing components...
       YourNewComponent.self
   ])
   ```
3. Implement the JavaScript counterpart in the web app

## Deployment Notes

- Bundle ID: `me.paolino.Cluster-Headache-Tracker`
- Minimum iOS: 15.6
- The app uses Swift Package Manager for dependencies (no CocoaPods/Carthage)
- Production URL is hardcoded in `AppConfig.swift` for release builds

## Principles

- Don't overcomplicate things.
- Search for the right solution first. Can be from the hotwire-native-ios code (in ~/Code/External/hotwire-native-ios/) and their demos, or online.

