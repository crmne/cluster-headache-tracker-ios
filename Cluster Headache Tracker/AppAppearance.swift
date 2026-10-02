import UIKit

enum AppPalette {
    static let primary = UIColor(light: "#4F46E5", dark: "#818CF8")
    static let secondary = UIColor(light: "#10B981", dark: "#34D399")
    static let accent = UIColor(light: "#F59E0B", dark: "#FBBF24")
    static let info = UIColor(light: "#3B82F6", dark: "#60A5FA")
}

/// Keeps UIKit chrome as close to the system look as possible: on iOS 26+ the
/// bars use Liquid Glass untouched, earlier versions get the default translucent
/// material. Only the tint carries the product colour.
@MainActor
enum AppAppearance {
    static func configure() {
        UINavigationBar.appearance().tintColor = AppPalette.primary
        UITabBar.appearance().tintColor = AppPalette.primary
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = AppPalette.primary

        if #unavailable(iOS 26.0) {
            configureLegacyBars()
        }
    }

    private static func configureLegacyBars() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.compactAppearance = navigationBarAppearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
    }
}

private extension UIColor {
    convenience init(light: String, dark: String) {
        let lightColor = UIColor(hex: light)
        let darkColor = UIColor(hex: dark)

        self.init { traits in
            traits.userInterfaceStyle == .dark ? darkColor : lightColor
        }
    }

    convenience init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let value = Int(sanitized, radix: 16) ?? 0

        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
