import HotwireNative
import UIKit

/// Large titles on the root screen of each tab, inline titles everywhere else
/// (pushed screens and modal sheets).
final class NavigationController: HotwireNavigationController {
    override func viewWillAppear(_ animated: Bool) {
        navigationBar.prefersLargeTitles = presentingViewController == nil
        super.viewWillAppear(animated)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.largeTitleDisplayMode = viewControllers.isEmpty ? .always : .never
        super.pushViewController(viewController, animated: animated)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        for (index, viewController) in viewControllers.enumerated() {
            viewController.navigationItem.largeTitleDisplayMode = index == 0 ? .always : .never
        }
        super.setViewControllers(viewControllers, animated: animated)
    }
}
