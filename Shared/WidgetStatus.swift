import Foundation

/// Attack status the web app reports through the `widget-status` bridge
/// component. Widgets, quick actions and the Live Activity render from this
/// snapshot only; they never talk to the server.
struct WidgetStatus: Codable, Equatable, Sendable {
    var ongoing: Bool
    var startedAt: Date?
    var lastAttackAt: Date?
    var attackFreeDays: Int
    var attacksToday: Int
    var locale: String
    var updatedAt: Date

    /// Days without an attack as of `date`. Counts calendar days from the last
    /// attack when known, otherwise advances the server's count by the days
    /// passed since the snapshot was taken.
    func attackFreeDays(at date: Date, calendar: Calendar = .current) -> Int {
        guard !ongoing else { return 0 }

        let reference = lastAttackAt ?? updatedAt
        let elapsed = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: reference),
            to: calendar.startOfDay(for: date)
        ).day ?? 0

        if lastAttackAt != nil {
            return max(elapsed, 0)
        }
        return attackFreeDays + max(elapsed, 0)
    }

    /// Attacks logged today, reset once the day of the snapshot has passed.
    func attacksToday(at date: Date, calendar: Calendar = .current) -> Int {
        calendar.isDate(updatedAt, inSameDayAs: date) ? attacksToday : 0
    }
}

extension WidgetStatus {
    static let supportedLocales: Set<String> = ["en", "de", "it", "es"]

    /// Locale for widget text: the language chosen in the web app.
    var resolvedLocale: Locale {
        Locale(identifier: Self.supportedLocales.contains(locale) ? locale : "en")
    }

    /// Parses the ISO 8601 timestamps the web app sends, with or without
    /// fractional seconds.
    static func parseDate(_ string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }

        if let date = try? Date(string, strategy: .iso8601) {
            return date
        }
        return try? Date(string, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
    }
}
