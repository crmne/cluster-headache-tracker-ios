import Foundation

/// Persists the latest `WidgetStatus` in the App Group shared with the
/// widget extension.
struct WidgetStatusStore: Sendable {
    static let appGroupIdentifier = "group.me.paolino.Cluster-Headache-Tracker"
    static let shared = WidgetStatusStore(suiteName: appGroupIdentifier)

    private static let key = "widgetStatus"
    private let suiteName: String?

    init(suiteName: String?) {
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    func load() -> WidgetStatus? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(WidgetStatus.self, from: data)
    }

    func save(_ status: WidgetStatus) {
        guard let data = try? JSONEncoder().encode(status) else { return }
        defaults.set(data, forKey: Self.key)
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
    }
}
