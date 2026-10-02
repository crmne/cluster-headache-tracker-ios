import HotwireNative
import UIKit

/// Native side of the `bridge--widget-status` Stimulus controller. On
/// `connect` the web app sends the current attack status, which feeds the
/// widgets, quick actions and Live Activity.
final class WidgetStatusComponent: BridgeComponent {
    override nonisolated class var name: String { "widget-status" }

    override func onReceive(message: Message) {
        guard message.event == "connect",
              let data: MessageData = message.data()
        else {
            return
        }

        StatusSync.apply(data.status(updatedAt: .now))
    }
}

extension WidgetStatusComponent {
    struct MessageData: Decodable {
        let ongoing: Bool
        let startedAt: String?
        let lastAttackAt: String?
        let attackFreeDays: Int
        let attacksToday: Int
        let locale: String

        func status(updatedAt: Date) -> WidgetStatus {
            WidgetStatus(
                ongoing: ongoing,
                startedAt: WidgetStatus.parseDate(startedAt),
                lastAttackAt: WidgetStatus.parseDate(lastAttackAt),
                attackFreeDays: attackFreeDays,
                attacksToday: attacksToday,
                locale: locale,
                updatedAt: updatedAt
            )
        }
    }
}
