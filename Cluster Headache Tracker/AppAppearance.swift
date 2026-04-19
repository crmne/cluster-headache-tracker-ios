import UIKit

enum AppPalette {
    static let primary = UIColor(hex: "#4F46E5")!
    static let secondary = UIColor(hex: "#10B981")!
    static let accent = UIColor(hex: "#F59E0B")!
    static let info = UIColor(hex: "#3B82F6")!
    static let chromeBackground = UIColor.systemBackground
    static let chromeBorder = UIColor.separator
    static let unselectedTab = UIColor.secondaryLabel
}

enum AppAppearance {
    static func configure() {
        configureNavigationBar()
        configureTabBar()
    }

    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppPalette.chromeBackground
        appearance.shadowColor = AppPalette.chromeBorder
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: AppPalette.primary]
        appearance.buttonAppearance = buttonAppearance
        appearance.doneButtonAppearance = buttonAppearance

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = AppPalette.primary
    }

    private static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppPalette.chromeBackground
        appearance.shadowColor = AppPalette.chromeBorder

        let stacked = appearance.stackedLayoutAppearance
        stacked.normal.iconColor = AppPalette.unselectedTab
        stacked.normal.titleTextAttributes = [.foregroundColor: AppPalette.unselectedTab]
        stacked.selected.iconColor = AppPalette.primary
        stacked.selected.titleTextAttributes = [.foregroundColor: UIColor.label]

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = AppPalette.primary
        tabBar.unselectedItemTintColor = AppPalette.unselectedTab
    }
}

private extension UIColor {
    convenience init?(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard sanitized.count == 6,
              let value = Int(sanitized, radix: 16)
        else {
            return nil
        }

        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
