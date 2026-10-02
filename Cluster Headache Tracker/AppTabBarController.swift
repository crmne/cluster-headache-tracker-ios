import HotwireNative
import UIKit

final class AppTabBarController: HotwireTabBarController {
    var onCreateRequested: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Keep a bottom tab bar on iPad too instead of the floating sidebar.
        mode = .tabBar

        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .onScrollDown
        }
    }

    func selectTab(withID identifier: String) {
        guard let tab = tabs.first(where: { $0.identifier == identifier }) else { return }
        selectedTab = tab
    }
}

extension AppTabBarController {
    func tabBarController(_: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
        guard tab.identifier == AppTabs.newTabID else {
            return true
        }

        onCreateRequested?()
        return false
    }
}
