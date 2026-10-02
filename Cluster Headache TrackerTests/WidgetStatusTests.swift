@testable import Cluster_Headache_Tracker
import Foundation
import Testing

struct WidgetStatusTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
        return calendar
    }

    func date(_ string: String) -> Date {
        WidgetStatus.parseDate(string)!
    }

    func status(ongoing: Bool = false, lastAttackAt: Date? = nil, attackFreeDays: Int = 0, updatedAt: Date) -> WidgetStatus {
        WidgetStatus(
            ongoing: ongoing,
            startedAt: nil,
            lastAttackAt: lastAttackAt,
            attackFreeDays: attackFreeDays,
            attacksToday: 2,
            locale: "it",
            updatedAt: updatedAt
        )
    }

    @Test func parsesRailsAndJavaScriptTimestamps() {
        #expect(WidgetStatus.parseDate("2026-10-02T14:30:00+02:00") == WidgetStatus.parseDate("2026-10-02T12:30:00Z"))
        #expect(WidgetStatus.parseDate("2026-10-02T12:30:00.123Z") != nil)
        #expect(WidgetStatus.parseDate(nil) == nil)
        #expect(WidgetStatus.parseDate("") == nil)
    }

    @Test @MainActor func decodesTheBridgePayload() throws {
        let json = """
        {"ongoing":true,"startedAt":"2026-10-02T12:30:00.000Z","lastAttackAt":null,
         "attackFreeDays":0,"attacksToday":3,"locale":"de"}
        """
        let data = try JSONDecoder().decode(WidgetStatusComponent.MessageData.self, from: Data(json.utf8))
        let now = Date.now
        let status = data.status(updatedAt: now)

        #expect(status.ongoing)
        #expect(status.startedAt == date("2026-10-02T12:30:00Z"))
        #expect(status.lastAttackAt == nil)
        #expect(status.attacksToday == 3)
        #expect(status.resolvedLocale.identifier == "de")
        #expect(status.updatedAt == now)
    }

    @Test func parsesThePatientsUTCOffset() {
        let startedAt = WidgetStatus.parseDate("2026-10-02T11:44:00+02:00")
        #expect(startedAt == WidgetStatus.parseDate("2026-10-02T09:44:00Z"))

        var berlin = Calendar(identifier: .gregorian)
        berlin.timeZone = TimeZone(identifier: "Europe/Berlin")!
        #expect(berlin.component(.hour, from: startedAt!) == 11)
    }

    @Test func flagsStartTimesInTheFuture() {
        let now = date("2026-10-02T13:42:00Z")
        var snapshot = status(updatedAt: now)
        snapshot.ongoing = true

        snapshot.startedAt = date("2026-10-02T14:40:00+02:00")
        #expect(!snapshot.hasFutureTimestamps(relativeTo: now))

        // Wall-clock time labelled as UTC lands two hours in the future.
        snapshot.startedAt = date("2026-10-02T14:40:00Z")
        #expect(snapshot.hasFutureTimestamps(relativeTo: now))
    }

    @Test func countsAttackFreeDaysFromTheLastAttack() {
        let snapshot = status(lastAttackAt: date("2026-09-28T23:00:00Z"), attackFreeDays: 3, updatedAt: date("2026-10-02T08:00:00Z"))

        #expect(snapshot.attackFreeDays(at: date("2026-10-02T08:00:00Z"), calendar: calendar) == 3)
        #expect(snapshot.attackFreeDays(at: date("2026-10-05T08:00:00Z"), calendar: calendar) == 6)
    }

    @Test func advancesTheServerCountWithoutALastAttack() {
        let snapshot = status(attackFreeDays: 10, updatedAt: date("2026-10-02T08:00:00Z"))

        #expect(snapshot.attackFreeDays(at: date("2026-10-02T20:00:00Z"), calendar: calendar) == 10)
        #expect(snapshot.attackFreeDays(at: date("2026-10-04T08:00:00Z"), calendar: calendar) == 12)
    }

    @Test func ongoingAttackMeansNoAttackFreeDays() {
        let snapshot = status(ongoing: true, attackFreeDays: 5, updatedAt: .now)
        #expect(snapshot.attackFreeDays(at: .now, calendar: calendar) == 0)
    }

    @Test func attacksTodayResetsAfterMidnight() {
        let snapshot = status(updatedAt: date("2026-10-02T08:00:00Z"))

        #expect(snapshot.attacksToday(at: date("2026-10-02T21:00:00Z"), calendar: calendar) == 2)
        #expect(snapshot.attacksToday(at: date("2026-10-02T22:30:00Z"), calendar: calendar) == 0)
    }

    @Test func unsupportedLocalesFallBackToEnglish() {
        var snapshot = status(updatedAt: .now)
        snapshot.locale = "fr"
        #expect(snapshot.resolvedLocale.identifier == "en")
    }

    @Test func storeRoundTripsAndClears() {
        let store = WidgetStatusStore(suiteName: "WidgetStatusTests-\(UUID().uuidString)")
        let snapshot = status(lastAttackAt: date("2026-09-28T23:00:00Z"), updatedAt: date("2026-10-02T08:00:00Z"))

        #expect(store.load() == nil)
        store.save(snapshot)
        #expect(store.load() == snapshot)
        store.clear()
        #expect(store.load() == nil)
    }
}
