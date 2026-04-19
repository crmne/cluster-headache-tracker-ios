# Clean-Room iOS Architecture

## Goal

Rebuild the Cluster Headache Tracker iOS shell as a clean Hotwire Native application that:

- uses the current Hotwire Native configuration model
- uses Joe Masilotti's Bridge Components and Bridge Components PRO packages
- preserves the product behavior already expressed by the Rails app and Android app
- removes the existing ad-hoc auth refresh and bridge registration code paths

This document is the implementation contract for the rewrite.

## Inputs

- Web app routes and mobile layout live in `../cluster-headache-tracker`
- Android app behavior lives in `../cluster-headache-tracker-android`
- Local dependency checkouts:
  - `../hotwire-native-ios`
  - `../bridge-components`
  - `../bridge-components-pro`

## Verified Dependency State

- Hotwire Native iOS official docs currently list `1.2.2` as the current iOS release.
- The local `../hotwire-native-ios` checkout is at `1.3.0-beta-19`.
- Local `../bridge-components` is `v0.13.2`.
- Local `../bridge-components-pro` is `v0.13.0`.

Because the user explicitly asked to use the parent-folder checkouts, the project should be wired to the local packages instead of the previously pinned remote package references.

## Product Model

The native shell should reflect the existing signed-in product structure:

1. Logs
2. Charts
3. New
4. Account
5. Feedback

The tab bar is native. Each tab owns its own Hotwire `Navigator`.

The `"New"` tab is not a real destination. Selecting it should route to `/headache_logs/new` as a modal from the active tab and keep the previously selected tab active.

## Clean-Room Architecture

### AppDelegate responsibilities

- configure Honeybadger if an API key is available
- configure global UIKit appearance
- configure Hotwire before any navigator is created
- load bundled and remote path configuration
- register bridge components
- post the push notification token into `Bridgework` when APNs registration succeeds

### SceneController responsibilities

- create the window and root tab bar controller
- rebuild the root controller after authentication changes
- handle 401 responses by presenting the sign-in flow as a modal
- preserve the selected tab across auth refreshes when possible
- report non-auth visit failures to Honeybadger and present retry UI

### Tab controller responsibilities

- keep Hotwire's own tab startup behavior intact
- intercept the `"New"` tab before selection
- route create flow modally via the active navigator

## Hotwire Configuration

The rewrite should use the modern Hotwire configuration surface:

- `Hotwire.loadPathConfiguration(...)`
- `Hotwire.config.applicationUserAgentPrefix`
- `Hotwire.config.showDoneButtonOnModals = true`
- `Hotwire.config.backButtonDisplayMode = .minimal`
- `Hotwire.config.hideTabBarWhenPushed = true`

No custom web view controller is needed unless a concrete rendering problem remains after the rewrite.

## Authentication Model

### Preferred model

Hotwire Native 1.2+ already supports the built-in historical-location URLs:

- `recede_or_redirect_to`
- `refresh_or_redirect_to`
- `resume_or_redirect_to`

That is the preferred server-side model because it avoids native-specific notification plumbing.

### Compatibility model for the current Rails app

The current Rails app still redirects successful native auth flows to `/recede_historical_location`.

The new iOS shell should support that existing endpoint by treating it as an auth-success compatibility signal:

1. intercept the proposal
2. dismiss the auth modal if present
3. rebuild the tab bar controller
4. restore the previously selected tab index when possible

This keeps the current server behavior working while the app is being modernized.

### Sign out behavior

The native shell should rebuild all tabs after sign out, not just the visible navigator. That prevents stale signed-in screens from remaining cached behind other tabs.

## Bridge Components Strategy

### Primary strategy

Register Joe Masilotti's bridge packages through `Bridgework`, using the PRO aggregate so the app is ready for both free and pro components.

### Required compatibility seam

The Rails app currently ships custom `"button"` and `"share"` Stimulus bridge controllers under the same component names used by Joe's library, but with older payload/event semantics.

Because the component names collide, the iOS app cannot register Joe's stock `ButtonComponent` and `ShareComponent` unchanged today.

The clean-room solution is:

1. register all Joe components except the conflicting stock `button` and `share` implementations
2. replace those two names with compatibility components that:
   - accept Joe's current event contract
   - also accept the legacy app-specific event contract already deployed by the Rails app

This gives the app a clean migration path:

- iOS shell is modernized now
- Rails bridge controllers can migrate later
- future server cleanup can delete the compatibility components without another architectural rewrite

## Visual Direction

Use the existing product palette from the Rails app:

- Primary: `#4f46e5`
- Secondary: `#10b981`
- Accent: `#f59e0b`
- Info: `#3b82f6`

Apply those colors to the tab selection assets and native chrome so the shell feels native while still matching the web product.

## Path Configuration Rules

The bundled path configuration should:

- default to normal in-tab navigation with pull-to-refresh enabled
- present auth URLs modally with pull-to-refresh disabled
- present create/edit form URLs modally with pull-to-refresh disabled
- keep signed-in root pages in normal tab contexts

The config should use current property names such as `page_sheet`, not older camelCase spellings.

## Non-Goals

- no new fully native screens
- no redesign of the Rails app itself
- no forced migration of the Rails bridge Stimulus controllers in the same change

## Verification Plan

1. Validate local package wiring to the parent-folder dependencies.
2. Verify the project file remains coherent.
3. Run Swift-level checks available on Linux.
4. Run a real Xcode build once macOS/Xcode is available.

Linux can validate Swift source and package assumptions, but a real iOS build still requires Xcode on macOS.
