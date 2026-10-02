import Foundation
import HotwireNative
import UIKit

/// The native tab bar mirrors the signed-in web navigation that the Rails app
/// hides for native shells (`native_app_with_tabs?`).
@MainActor
enum AppTabs {
    static let newTabID = "new"

    static var all: [HotwireTab] {
        [
            HotwireTab(
                id: "logs",
                title: String(localized: "Logs", comment: "Tab title for the list of headache logs"),
                image: UIImage(systemName: "list.bullet.clipboard"),
                url: AppConfig.logsURL
            ),
            HotwireTab(
                id: "charts",
                title: String(localized: "Charts", comment: "Tab title for the charts screen"),
                image: UIImage(systemName: "chart.bar.xaxis"),
                url: AppConfig.chartsURL
            ),
            HotwireTab(
                id: newTabID,
                title: String(localized: "New", comment: "Tab title that opens the new headache log form"),
                image: UIImage(systemName: "plus.circle.fill"),
                url: AppConfig.logsURL
            ),
            HotwireTab(
                id: "account",
                title: String(localized: "Account", comment: "Tab title for account settings"),
                image: UIImage(systemName: "person.crop.circle"),
                url: AppConfig.settingsURL
            ),
            HotwireTab(
                id: "feedback",
                title: String(localized: "Feedback", comment: "Tab title for the feedback screen"),
                image: UIImage(systemName: "bubble.left.and.text.bubble.right"),
                url: AppConfig.feedbackURL
            ),
        ]
    }

    static var newTabIndex: Int {
        all.firstIndex { $0.id == newTabID } ?? 2
    }
}
