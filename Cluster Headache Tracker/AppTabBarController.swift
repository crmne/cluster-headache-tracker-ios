import HotwireNative
import UIKit

final class AppTabBarController: HotwireTabBarController {
    var onCreateRequested: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 18.0, *) {
            mode = .tabBar
        }
    }
}

extension AppTabBarController {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let viewControllers = tabBarController.viewControllers,
              let index = viewControllers.firstIndex(of: viewController)
        else {
            return true
        }

        return handleSelection(forIndex: index)
    }

    @available(iOS 18.0, *)
    func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
        guard let index = AppTabs.all.firstIndex(where: { $0.id == tab.identifier }) else {
            return true
        }

        return handleSelection(forIndex: index)
    }

    private func handleSelection(forIndex index: Int) -> Bool {
        guard index == AppTabs.newTabIndex else {
            return true
        }

        onCreateRequested?()
        return false
    }
}
