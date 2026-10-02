@testable import Cluster_Headache_Tracker
import Foundation
import Testing

struct DeepLinkTests {
    let baseURL = URL(string: "https://clusterheadachetracker.com")!

    @Test func quickLogMapsToTheQuickLogForm() {
        #expect(DeepLink.quickLog.webURL(baseURL: baseURL).absoluteString == "https://clusterheadachetracker.com/headache_logs/new?quick=1")
    }

    @Test func currentAttackMapsToTheCurrentAttackPage() {
        #expect(DeepLink.currentAttack.webURL(baseURL: baseURL).absoluteString == "https://clusterheadachetracker.com/current_attack")
    }

    @Test(arguments: DeepLink.allCases)
    func appURLRoundTrips(link: DeepLink) {
        #expect(link.appURL.scheme == "clusterheadachetracker")
        #expect(DeepLink(appURL: link.appURL) == link)
    }

    @Test func unknownAppURLsAreRejected() {
        #expect(DeepLink(appURL: URL(string: "clusterheadachetracker://users/sign_out")!) == nil)
        #expect(DeepLink(appURL: URL(string: "https://clusterheadachetracker.com/current_attack")!) == nil)
    }

    @Test(arguments: DeepLink.allCases)
    func shortcutTypesRoundTrip(link: DeepLink) {
        #expect(DeepLink(shortcutType: link.shortcutType) == link)
    }

    @Test func infoPlistShortcutTypesAreKnown() throws {
        let items = try #require(Bundle.main.object(forInfoDictionaryKey: "UIApplicationShortcutItems") as? [[String: Any]])
        let types = items.compactMap { $0["UIApplicationShortcutItemType"] as? String }
        #expect(types.compactMap(DeepLink.init(shortcutType:)) == [.quickLog, .currentAttack])
    }

    @Test func signOutURLIsDetected() {
        #expect(AppConfig.isSignOutURL(baseURL.appending(path: "users/sign_out")))
        #expect(!AppConfig.isSignOutURL(baseURL.appending(path: "users/sign_in")))
    }
}
