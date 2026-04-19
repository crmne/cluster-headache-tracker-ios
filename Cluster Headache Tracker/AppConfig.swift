import Foundation

enum AppConfig {
    static let productionBaseURL = URL(string: "https://clusterheadachetracker.com")!
    static let localBaseURL = URL(string: "http://192.168.8.220:3000")!

    private static let baseURLOverrideEnvironmentKey = "CLUSTER_HEADACHE_TRACKER_BASE_URL"

    static var baseURL: URL {
        if let override = ProcessInfo.processInfo.environment[baseURLOverrideEnvironmentKey],
           let url = URL(string: override)
        {
            return url
        }

        #if DEBUG
            return productionBaseURL
        #else
            return productionBaseURL
        #endif
    }

    static var bundledPathConfigurationURL: URL {
        Bundle.main.url(forResource: "path-configuration", withExtension: "json")!
    }

    static var remotePathConfigurationURL: URL {
        baseURL.appendingPathComponent("configurations/ios_v2.json")
    }

    static var logsURL: URL {
        baseURL.appendingPathComponent("headache_logs")
    }

    static var chartsURL: URL {
        baseURL.appendingPathComponent("charts")
    }

    static var newHeadacheLogURL: URL {
        baseURL.appendingPathComponent("headache_logs/new")
    }

    static var settingsURL: URL {
        baseURL.appendingPathComponent("settings")
    }

    static var feedbackURL: URL {
        baseURL.appendingPathComponent("feedback")
    }

    static var signInURL: URL {
        baseURL.appendingPathComponent("users/sign_in")
    }

    static let compatibilityAuthenticationRefreshPath = "/recede_historical_location"

    static let authenticationPaths: Set<String> = [
        "/users/sign_in",
        "/users/sign_up",
        "/users/password/new",
        "/users/password/edit",
        "/users/password",
        "/login",
        "/signup",
        "/register",
    ]

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    }

    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    static var appVersionIdentifier: String {
        "\(appVersion).\(buildNumber)"
    }

    static var applicationUserAgentPrefix: String {
        "ClusterHeadacheTracker/\(appVersionIdentifier);"
    }

    static func isAuthenticationURL(_ url: URL) -> Bool {
        authenticationPaths.contains(url.path)
    }

    static func isCompatibilityAuthenticationRefreshURL(_ url: URL) -> Bool {
        url.path == compatibilityAuthenticationRefreshPath
    }

    static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}
