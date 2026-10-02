import ActivityKit
import Foundation

/// Live Activity for an ongoing attack: a running timer on the Lock Screen and
/// in the Dynamic Island.
struct AttackActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable, Sendable {
        var startedAt: Date
    }

    var localeIdentifier: String
}
