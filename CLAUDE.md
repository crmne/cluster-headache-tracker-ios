# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hotwire Native iOS shell for the Cluster Headache Tracker Rails app (https://clusterheadachetracker.com). The web app does the work; the shell adds native navigation, bridge components, widgets, a Live Activity, App Intents and Home Screen quick actions.

## Key Architecture

- **`AppDelegate`**: configures Honeybadger, UIKit appearance and Hotwire (path configuration, custom view/navigation controllers, web view factory, route decision handlers, bridge components).
- **`SceneController`**: owns the window and the `AppTabBarController`, presents sign-in on 401, rebuilds all tabs after sign-in (`/recede_historical_location`) and sign-out, and handles deep links (`clusterheadachetracker://`), quick actions and App Intents via `DeepLinkCenter`.
- **`AppTabBarController` / `Tabs.swift`**: native tabs (Logs, Charts, New, Account, Feedback), one Hotwire `Navigator` each. "New" is not a destination: it opens `/headache_logs/new` as a sheet. The Rails app hides its own navigation for native shells (`native_app_with_tabs?`).
- **`Navigation/`**: `WebViewController` (subclass of `HotwireWebViewController` that only adds a close button to sheets; never recreate its `BridgeDelegate`), `NavigationController` (large titles on tab roots), `WebViewFactory` (Dynamic Type via page zoom).
- **`Bridge/`**: `CompatibleButtonComponent` (library `button` contract plus legacy `connect`; Print, Sign Out and Sponsor come from the web's `nativeAction`, falling back to English titles for older servers), `CompatibleShareComponent`, `WidgetStatusComponent` (custom `widget-status`), `DownloadComponent` (`download`). Every other component (form, menu, alert, toast, haptic, review-prompt, theme, search) comes from Joe Masilotti's `BridgeComponents` package (`Bridgework.coreComponents`).
- **`Documents/`**: downloads PDF/CSV documents with the web view's cookies and shows them in Quick Look.
- **`Status/StatusSync`**: fans `widget-status` out to the App Group store, widgets, quick actions and the Live Activity; cleared on sign out.
- **`Shared/`**: compiled into the app and the widget extension (status model and store, deep links, App Intents, Live Activity attributes, `Localizable.xcstrings`).
- **`Widgets/`**: WidgetKit extension with the attack status widget (Home and Lock Screen), the Live Activity and the Log Attack control.
- **`path-configuration.json`**: bundled rules; the server copy at `/configurations/ios_v2.json` is loaded afterwards and should stay identical.

## Common Development Commands

```bash
open "Cluster Headache Tracker.xcodeproj"

xcodebuild -scheme "Cluster Headache Tracker" -configuration Debug -destination 'generic/platform=iOS Simulator' build

xcodebuild test -scheme "Cluster Headache Tracker" -destination 'platform=iOS Simulator,name=iPhone 17'
```

UI tests run against production read-only (native chrome and the public sign-in page only).

### Local Development

Set `CLUSTER_HEADACHE_TRACKER_BASE_URL` (e.g. `http://192.168.1.10:3000`) in the scheme's environment variables. Plain HTTP to local network addresses is allowed through `NSAllowsLocalNetworking`.

### Honeybadger

`HONEYBADGER_API_KEY` comes from `Configuration/App.xcconfig`, which includes the git-ignored `Configuration/Secrets.xcconfig` (see `Secrets.xcconfig.example`). Xcode Cloud writes that file in `ci_scripts/ci_post_clone.sh` from the `HONEYBADGER_API_KEY` secret environment variable. Without it, Honeybadger is disabled.

## Adding New Native Features

1. Create a bridge component in `Bridge/` extending `BridgeComponent` (prefer the library's component when one exists).
2. Register it in `AppDelegate.bridgeComponents`.
3. Implement the Stimulus counterpart in the web app (`app/javascript/controllers/bridge`).

User-facing strings go through `String(localized:)` / SwiftUI literals and need en/de/it/es translations in the String Catalogs (`Shared/Localizable.xcstrings`, `InfoPlist.xcstrings`, `AppShortcuts.xcstrings`).

## Deployment Notes

- Bundle IDs: `me.paolino.Cluster-Headache-Tracker`, widget extension `me.paolino.Cluster-Headache-Tracker.Widgets`
- App Group: `group.me.paolino.Cluster-Headache-Tracker` (app and widget extension)
- Minimum iOS: 18.0, Swift 6 language mode
- Swift Package Manager only (Hotwire Native, Bridge Components, Honeybadger)
- Release versions come from tags: `Scripts/archive-release.sh vX.Y.Z`

## Principles

- Don't overcomplicate things.
- Search for the right solution first. Can be from the hotwire-native-ios code (in ~/Code/External/hotwire-native-ios/) and their demos, or online.
