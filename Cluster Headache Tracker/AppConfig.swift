import Foundation

struct AppConfig {
    static let remote = URL(string: "https://clusterheadachetracker.com")!
    static let local = URL(string: "http://192.168.8.220:3000")!
    
    /// Update this to choose which environment is used
    static var current: URL {
        #if DEBUG
        local
        #else
        remote
        #endif
    }
}