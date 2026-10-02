@testable import Cluster_Headache_Tracker
import Foundation
import Testing
import UIKit

@MainActor
struct NativeShellTests {
    func status(ongoing: Bool, locale: String = "en") -> WidgetStatus {
        WidgetStatus(ongoing: ongoing, startedAt: ongoing ? .now : nil, lastAttackAt: nil,
                     attackFreeDays: 0, attacksToday: 0, locale: locale, updatedAt: .now)
    }

    @Test func quickActionsOfferStartingOrEndingAnAttack() {
        #expect(QuickActions.items(for: nil).map(\.localizedTitle) == ["Log attack", "Current attack"])
        #expect(QuickActions.items(for: status(ongoing: false)).map(\.localizedTitle) == ["Log attack", "Start attack now"])
        #expect(QuickActions.items(for: status(ongoing: true)).map(\.localizedTitle) == ["Log attack", "End attack"])
        #expect(QuickActions.items(for: nil).map(\.type) == DeepLink.allCases.map(\.shortcutType))
    }

    @Test func quickActionsFollowTheWebAppLanguage() {
        #expect(QuickActions.items(for: status(ongoing: true, locale: "de")).map(\.localizedTitle) == ["Attacke erfassen", "Attacke beenden"])
        #expect(QuickActions.items(for: status(ongoing: false, locale: "it")).first?.localizedTitle == "Registra attacco")
        #expect(QuickActions.items(for: status(ongoing: false, locale: "es")).first?.localizedTitle == "Registrar crisis")
    }

    @Test func pageZoomGrowsWithTheTextSize() {
        #expect(WebViewFactory.pageZoom(for: .large) == 1)
        #expect(WebViewFactory.pageZoom(for: .extraSmall) < 1)
        #expect(WebViewFactory.pageZoom(for: .extraExtraExtraLarge) > WebViewFactory.pageZoom(for: .extraLarge))
        #expect(WebViewFactory.pageZoom(for: .accessibilityExtraExtraExtraLarge) == 1.5)
    }

    @Test func tabsCoverTheSignedInWebNavigation() {
        #expect(AppTabs.all.map(\.id) == ["logs", "charts", "new", "account", "feedback"])
        #expect(AppTabs.newTabIndex == 2)
    }

    @Test func pendingDeepLinksAreDeliveredOnceAHandlerIsInstalled() {
        let center = DeepLinkCenter.shared
        let previous = center.handler
        defer { center.handler = previous }

        center.handler = nil
        center.open(.currentAttack)

        var received = [DeepLink]()
        center.handler = { received.append($0) }
        center.open(.quickLog)

        #expect(received == [.currentAttack, .quickLog])
    }

    @Test func bridgeComponentNamesMatchTheWebControllers() {
        #expect(WidgetStatusComponent.name == "widget-status")
        #expect(CompatibleButtonComponent.name == "button")
        #expect(CompatibleShareComponent.name == "share")
    }
}
