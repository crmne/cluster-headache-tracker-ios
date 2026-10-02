import AppIntents
import Foundation

/// Opens the quick-log form. Available from Siri, Shortcuts, Spotlight, the
/// Action button and the Control Center control.
struct LogAttackIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Attack"
    static let description = IntentDescription("Opens the quick log so you can record a cluster headache attack in a few taps.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        DeepLinkCenter.shared.open(.quickLog)
        return .result()
    }
}

/// Opens the ongoing attack, or lets you start one now.
struct ShowCurrentAttackIntent: AppIntent {
    static let title: LocalizedStringResource = "Current Attack"
    static let description = IntentDescription("Shows the ongoing attack so you can end it, or starts a new one.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        DeepLinkCenter.shared.open(.currentAttack)
        return .result()
    }
}
