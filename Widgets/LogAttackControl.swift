import AppIntents
import SwiftUI
import WidgetKit

/// Control Center, Lock Screen and Action button control that opens the
/// quick log.
struct LogAttackControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "me.paolino.Cluster-Headache-Tracker.LogAttack") {
            ControlWidgetButton(action: LogAttackIntent()) {
                Label("Log attack", systemImage: "plus.circle.fill")
            }
        }
        .displayName("Log Attack")
        .description("Opens the quick log.")
    }
}
