import ActivityKit
import UIKit
import WidgetKit

/// Fans the web app's attack status out to everything outside the web view:
/// the App Group store (widgets), Home Screen quick actions and the Live
/// Activity.
@MainActor
enum StatusSync {
    static func apply(_ status: WidgetStatus, store: WidgetStatusStore = .shared) {
        let previous = store.load()
        store.save(status)

        if previous != status {
            WidgetCenter.shared.reloadAllTimelines()
        }

        QuickActions.update(for: status)
        AttackLiveActivity.sync(with: status)
    }

    /// Removes every trace of the signed-in user outside the web view.
    static func clear(store: WidgetStatusStore = .shared) {
        store.clear()
        WidgetCenter.shared.reloadAllTimelines()
        QuickActions.update(for: nil)
        AttackLiveActivity.endAll()
    }
}

@MainActor
enum QuickActions {
    /// Static items in Info.plist cover a fresh install; once the status is
    /// known the second item says whether it starts or ends an attack.
    static func update(for status: WidgetStatus?) {
        UIApplication.shared.shortcutItems = items(for: status)
    }

    static func items(for status: WidgetStatus?) -> [UIApplicationShortcutItem] {
        let bundle = Localization.bundle(for: status?.locale)

        let logAttack = UIApplicationShortcutItem(
            type: DeepLink.quickLog.shortcutType,
            localizedTitle: String(localized: "Log attack", bundle: bundle, comment: "Home Screen quick action"),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill")
        )

        let currentAttackTitle: String
        let currentAttackIcon: String
        switch status?.ongoing {
        case true?:
            currentAttackTitle = String(localized: "End attack", bundle: bundle, comment: "Home Screen quick action while an attack is ongoing")
            currentAttackIcon = "stop.circle.fill"
        case false?:
            currentAttackTitle = String(localized: "Start attack now", bundle: bundle, comment: "Home Screen quick action when no attack is ongoing")
            currentAttackIcon = "timer"
        case nil:
            currentAttackTitle = String(localized: "Current attack", bundle: bundle, comment: "Home Screen quick action")
            currentAttackIcon = "timer"
        }

        let currentAttack = UIApplicationShortcutItem(
            type: DeepLink.currentAttack.shortcutType,
            localizedTitle: currentAttackTitle,
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: currentAttackIcon)
        )

        return [logAttack, currentAttack]
    }
}

@MainActor
enum AttackLiveActivity {
    static func sync(with status: WidgetStatus) {
        guard status.ongoing, let startedAt = status.startedAt else {
            endAll()
            return
        }

        let state = AttackActivityAttributes.ContentState(startedAt: startedAt)
        let content = ActivityContent(state: state, staleDate: nil)

        if Activity<AttackActivityAttributes>.activities.isEmpty {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            _ = try? Activity.request(
                attributes: AttackActivityAttributes(localeIdentifier: status.resolvedLocale.identifier),
                content: content
            )
        } else {
            Task {
                for activity in Activity<AttackActivityAttributes>.activities
                    where activity.content.state != state {
                    await activity.update(content)
                }
            }
        }
    }

    static func endAll() {
        Task {
            for activity in Activity<AttackActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
