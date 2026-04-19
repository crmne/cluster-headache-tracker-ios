import Foundation
import HotwireNative
import UIKit

enum AppTabs {
    static let newTabIndex = 2

    static let all: [HotwireTab] = [
        logs,
        charts,
        new,
        account,
        feedback,
    ]

    static let logs = HotwireTab(
        id: "logs",
        title: "Logs",
        image: tabImage(named: "calendar"),
        selectedImage: selectedTabImage(named: "calendar", color: AppPalette.primary),
        url: AppConfig.logsURL
    )

    static let charts = HotwireTab(
        id: "charts",
        title: "Charts",
        image: tabImage(named: "chart.bar"),
        selectedImage: selectedTabImage(named: "chart.bar", color: AppPalette.secondary),
        url: AppConfig.chartsURL
    )

    static let new = HotwireTab(
        id: "new",
        title: "New",
        image: tabImage(
            named: "plus.circle.fill",
            pointSize: 24,
            weight: .semibold,
            color: AppPalette.unselectedTab
        ),
        selectedImage: selectedTabImage(
            named: "plus.circle.fill",
            color: AppPalette.primary,
            pointSize: 24,
            weight: .semibold
        ),
        url: AppConfig.logsURL
    )

    static let account = HotwireTab(
        id: "account",
        title: "Account",
        image: tabImage(named: "person"),
        selectedImage: selectedTabImage(named: "person", color: AppPalette.accent),
        url: AppConfig.settingsURL
    )

    static let feedback = HotwireTab(
        id: "feedback",
        title: "Feedback",
        image: tabImage(named: "bubble.left"),
        selectedImage: selectedTabImage(named: "bubble.left", color: AppPalette.info),
        url: AppConfig.feedbackURL
    )
}

private extension AppTabs {
    static func tabImage(
        named systemName: String,
        pointSize: CGFloat = 18,
        weight: UIImage.SymbolWeight = .medium,
        color: UIColor? = nil
    ) -> UIImage {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        let image = UIImage(systemName: systemName, withConfiguration: configuration)!

        guard let color else {
            return image
        }

        return image.withTintColor(color, renderingMode: .alwaysOriginal)
    }

    static func selectedTabImage(
        named systemName: String,
        color: UIColor,
        pointSize: CGFloat = 18,
        weight: UIImage.SymbolWeight = .medium
    ) -> UIImage {
        tabImage(named: systemName, pointSize: pointSize, weight: weight, color: color)
            .withRenderingMode(.alwaysOriginal)
    }
}
