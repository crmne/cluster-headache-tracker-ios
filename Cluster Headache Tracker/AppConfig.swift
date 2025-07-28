import Foundation

enum AppConfig {
    static let remote = URL(string: "https://clusterheadachetracker.com") ?? URL(fileURLWithPath: "/")
    static let local = URL(string: "http://192.168.8.220:3000") ?? URL(fileURLWithPath: "/")

    /// Update this to choose which environment is used
    static var current: URL {
        #if DEBUG
            local
        #else
            remote
        #endif
    }
}
