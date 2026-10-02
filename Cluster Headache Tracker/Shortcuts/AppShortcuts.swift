import AppIntents

struct ClusterHeadacheShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogAttackIntent(),
            phrases: [
                "Log an attack in \(.applicationName)",
                "Log a cluster headache in \(.applicationName)",
                "Record an attack with \(.applicationName)",
            ],
            shortTitle: "Log Attack",
            systemImageName: "plus.circle.fill"
        )
        AppShortcut(
            intent: ShowCurrentAttackIntent(),
            phrases: [
                "Show my current attack in \(.applicationName)",
                "End my attack in \(.applicationName)",
            ],
            shortTitle: "Current Attack",
            systemImageName: "timer"
        )
    }

    static let shortcutTileColor: ShortcutTileColor = .purple
}
