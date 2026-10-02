import SwiftUI
import WidgetKit

@main
struct ClusterHeadacheWidgets: WidgetBundle {
    var body: some Widget {
        AttackStatusWidget()
        AttackLiveActivityWidget()
        LogAttackControl()
    }
}
