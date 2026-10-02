import ActivityKit
import SwiftUI
import WidgetKit

struct AttackLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AttackActivityAttributes.self) { context in
            LockScreenAttackView(startedAt: context.state.startedAt)
                .environment(\.locale, Locale(identifier: context.attributes.localeIdentifier))
                .activityBackgroundTint(nil)
                .widgetURL(DeepLink.currentAttack.appURL)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Attack", systemImage: "waveform.path.ecg")
                        .font(.headline)
                        .foregroundStyle(.red)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.startedAt, style: .timer)
                        .font(.title2.monospacedDigit().weight(.semibold))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 110)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Link(destination: DeepLink.currentAttack.appURL) {
                        Label("End attack", systemImage: "stop.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(.red.opacity(0.25), in: .capsule)
                    }
                }
            } compactLeading: {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(.red)
            } compactTrailing: {
                Text(context.state.startedAt, style: .timer)
                    .monospacedDigit()
                    .frame(maxWidth: 52)
            } minimal: {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(.red)
            }
            .widgetURL(DeepLink.currentAttack.appURL)
            .keylineTint(.red)
        }
    }
}

private struct LockScreenAttackView: View {
    let startedAt: Date

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Label("Attack ongoing", systemImage: "waveform.path.ecg")
                    .font(.headline)
                    .foregroundStyle(.red)
                Text(startedAt, style: .timer)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .monospacedDigit()
            }
            Spacer()
            Link(destination: DeepLink.currentAttack.appURL) {
                Label("End attack", systemImage: "stop.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.red.opacity(0.2), in: .capsule)
            }
        }
        .padding()
    }
}
