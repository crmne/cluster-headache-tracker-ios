import SwiftUI
import WidgetKit

struct AttackStatusEntry: TimelineEntry {
    let date: Date
    let status: WidgetStatus?
}

struct AttackStatusProvider: TimelineProvider {
    var store = WidgetStatusStore.shared

    func placeholder(in _: Context) -> AttackStatusEntry {
        AttackStatusEntry(date: .now, status: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (AttackStatusEntry) -> Void) {
        let status = context.isPreview ? (store.load() ?? .preview) : store.load()
        completion(AttackStatusEntry(date: .now, status: status))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<AttackStatusEntry>) -> Void) {
        let now = Date.now
        let entry = AttackStatusEntry(date: now, status: store.load())
        // The elapsed timer updates itself; refresh at midnight so the
        // attack-free day count and today's count roll over.
        let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

struct AttackStatusWidget: Widget {
    let kind = "AttackStatus"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AttackStatusProvider()) { entry in
            AttackStatusView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Attack Status")
        .description("Shows how long the current attack has lasted, or how many days you have been attack-free.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct AttackStatusView: View {
    @Environment(\.widgetFamily) private var family
    let entry: AttackStatusEntry

    var body: some View {
        content
            .environment(\.locale, entry.status?.resolvedLocale ?? .current)
    }

    @ViewBuilder
    private var content: some View {
        if let status = entry.status {
            switch family {
            case .accessoryCircular: CircularStatusView(status: status, date: entry.date)
            case .accessoryRectangular: RectangularStatusView(status: status, date: entry.date)
            case .accessoryInline: InlineStatusView(status: status, date: entry.date)
            case .systemMedium: MediumStatusView(status: status, date: entry.date)
            default: SmallStatusView(status: status, date: entry.date)
            }
        } else {
            SignedOutView()
        }
    }
}

// MARK: - Home Screen

private struct SmallStatusView: View {
    let status: WidgetStatus
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            StatusHeadline(status: status, date: date)
            Spacer(minLength: 0)
            if status.ongoing {
                ActionLabel(title: "End attack", systemImage: "stop.circle.fill")
            } else {
                ActionLabel(title: "Log attack", systemImage: "plus.circle.fill")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(status.ongoing ? DeepLink.currentAttack.appURL : DeepLink.quickLog.appURL)
    }
}

private struct MediumStatusView: View {
    let status: WidgetStatus
    let date: Date

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                StatusHeadline(status: status, date: date)
                Spacer(minLength: 0)
                Text("Today: \(status.attacksToday(at: date)) attacks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                Link(destination: DeepLink.quickLog.appURL) {
                    ActionLabel(title: "Log attack", systemImage: "plus.circle.fill")
                }
                Link(destination: DeepLink.currentAttack.appURL) {
                    if status.ongoing {
                        ActionLabel(title: "End attack", systemImage: "stop.circle.fill")
                    } else {
                        ActionLabel(title: "Start now", systemImage: "timer")
                    }
                }
            }
        }
    }
}

private struct StatusHeadline: View {
    let status: WidgetStatus
    let date: Date

    var body: some View {
        if status.ongoing, let startedAt = status.startedAt {
            Label("Attack ongoing", systemImage: "waveform.path.ecg")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.red)
            Text(startedAt, style: .timer)
                .font(.system(.title, design: .rounded, weight: .bold))
                .monospacedDigit()
                .minimumScaleFactor(0.6)
        } else {
            let days = status.attackFreeDays(at: date)
            Label("Attack-free", systemImage: "leaf.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.green)
            Text(days, format: .number)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
            Text("\(days) days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ActionLabel: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.tint.opacity(0.18), in: .capsule)
            .foregroundStyle(.tint)
    }
}

private struct SignedOutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundStyle(.tint)
            Text("Open the app to sign in")
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - Lock Screen

private struct CircularStatusView: View {
    let status: WidgetStatus
    let date: Date

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if status.ongoing, let startedAt = status.startedAt {
                VStack(spacing: 0) {
                    Image(systemName: "waveform.path.ecg")
                    Text(startedAt, style: .timer)
                        .font(.caption2.monospacedDigit())
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                }
                .padding(4)
            } else {
                VStack(spacing: 0) {
                    Text(status.attackFreeDays(at: date), format: .number)
                        .font(.title3.weight(.bold))
                    Image(systemName: "leaf.fill")
                        .font(.caption2)
                }
            }
        }
        .widgetURL(status.ongoing ? DeepLink.currentAttack.appURL : DeepLink.quickLog.appURL)
    }
}

private struct RectangularStatusView: View {
    let status: WidgetStatus
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if status.ongoing, let startedAt = status.startedAt {
                Label("Attack ongoing", systemImage: "waveform.path.ecg")
                    .font(.headline)
                Text(startedAt, style: .timer)
                    .font(.title3.monospacedDigit())
            } else {
                Label("Attack-free", systemImage: "leaf.fill")
                    .font(.headline)
                Text("\(status.attackFreeDays(at: date)) days")
                    .font(.title3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(status.ongoing ? DeepLink.currentAttack.appURL : DeepLink.quickLog.appURL)
    }
}

private struct InlineStatusView: View {
    let status: WidgetStatus
    let date: Date

    var body: some View {
        if status.ongoing, let startedAt = status.startedAt {
            Label {
                Text(startedAt, style: .timer)
            } icon: {
                Image(systemName: "waveform.path.ecg")
            }
        } else {
            Label("\(status.attackFreeDays(at: date)) days attack-free", systemImage: "leaf.fill")
        }
    }
}

extension WidgetStatus {
    static let preview = WidgetStatus(
        ongoing: false,
        startedAt: nil,
        lastAttackAt: Calendar.current.date(byAdding: .day, value: -12, to: .now),
        attackFreeDays: 12,
        attacksToday: 0,
        locale: "en",
        updatedAt: .now
    )
}
