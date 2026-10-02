import Foundation

/// The destinations widgets, quick actions and App Intents can open. Kept to
/// an allowlist so other apps can't send the app to arbitrary pages.
enum DeepLink: String, CaseIterable, Sendable {
    case quickLog
    case currentAttack

    static let scheme = "clusterheadachetracker"

    /// Path and query on the web app, as agreed with the Rails side.
    var webPath: String {
        switch self {
        case .quickLog: "/headache_logs/new?quick=1"
        case .currentAttack: "/current_attack"
        }
    }

    /// `clusterheadachetracker://headache_logs/new?quick=1`
    var appURL: URL {
        URL(string: "\(Self.scheme):/\(webPath)")!
    }

    func webURL(baseURL: URL) -> URL {
        URL(string: webPath, relativeTo: baseURL)!.absoluteURL
    }

    /// Shortcut item type used for Home Screen quick actions.
    var shortcutType: String {
        "me.paolino.Cluster-Headache-Tracker.\(rawValue)"
    }

    init?(appURL url: URL) {
        guard url.scheme == Self.scheme else { return nil }

        let path = "/" + [url.host(), url.path()]
            .compactMap { $0 }
            .joined()
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        switch path {
        case "/headache_logs/new": self = .quickLog
        case "/current_attack": self = .currentAttack
        default: return nil
        }
    }

    init?(shortcutType: String) {
        guard let link = Self.allCases.first(where: { $0.shortcutType == shortcutType }) else { return nil }
        self = link
    }
}
