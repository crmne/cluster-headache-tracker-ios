import Honeybadger
import HotwireNative
import UIKit

final class SceneController: UIResponder {
    var window: UIWindow?

    private var tabBarController: AppTabBarController?
    private var notificationObservers = [NSObjectProtocol]()
    private var isAuthenticationRoutePending = false
}

extension SceneController: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        installRootController(selectedIndex: nil)
        observeNotifications()

        window.makeKeyAndVisible()
    }
}

extension SceneController: @preconcurrency NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        if AppConfig.isCompatibilityAuthenticationRefreshURL(proposal.url) {
            rebuildAfterAuthentication(using: navigator)
            return .reject
        }

        return .accept
    }

    func requestDidFinish(at url: URL) {
        if AppConfig.isAuthenticationURL(url) || !authenticationIsVisible {
            isAuthenticationRoutePending = false
        }
    }

    func visitableDidFailRequest(_ visitable: any Visitable, error: HotwireNativeError, retryHandler: RetryBlock?) {
        if error.statusCode == 401 {
            guard !authenticationIsVisible else {
                return
            }

            cleanupUnauthorizedFailure()
            presentAuthentication()
            return
        }

        let context = errorContext(for: visitable, error: error)
        Honeybadger.notify(error: error, context: context)

        if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error, retryHandler: retryHandler)
        }
    }
}

private extension SceneController {
    var authenticationIsVisible: Bool {
        guard let navigator = tabBarController?.activeNavigator else { return false }

        return navigator.modalRootViewController.viewControllers.contains { viewController in
            guard let visitable = viewController as? VisitableViewController else {
                return false
            }

            return AppConfig.isAuthenticationURL(visitable.initialVisitableURL)
        }
    }

    func installRootController(selectedIndex: Int?) {
        let controller = AppTabBarController(navigatorDelegate: self)
        controller.onCreateRequested = { [weak self] in
            self?.routeToNewHeadacheLog()
        }
        controller.load(AppTabs.all)

        if let selectedIndex,
           AppTabs.all.indices.contains(selectedIndex),
           selectedIndex != controller.selectedIndex
        {
            controller.selectedIndex = selectedIndex
        }

        tabBarController = controller
        window?.rootViewController = controller
    }

    func observeNotifications() {
        guard notificationObservers.isEmpty else { return }

        let signOutObserver = NotificationCenter.default.addObserver(
            forName: .clusterHeadacheTrackerSignOutRequested,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleSignOutRequested()
            }
        }

        notificationObservers.append(signOutObserver)
    }

    func presentAuthentication(after delay: TimeInterval = 0) {
        guard let tabBarController else { return }
        guard !isAuthenticationRoutePending, !authenticationIsVisible else { return }

        isAuthenticationRoutePending = true

        Task { @MainActor [weak tabBarController] in
            if delay > 0 {
                try? await Task.sleep(for: .seconds(delay))
            }
            tabBarController?.activeNavigator.route(AppConfig.signInURL)
        }
    }

    func routeToNewHeadacheLog() {
        tabBarController?.activeNavigator.route(AppConfig.newHeadacheLogURL)
    }

    func rebuildAfterAuthentication(using navigator: Navigator) {
        isAuthenticationRoutePending = false
        let selectedIndex = tabBarController?.selectedIndex

        let rebuild: () -> Void = { [weak self] in
            self?.installRootController(selectedIndex: selectedIndex)
        }

        if navigator.rootViewController.presentedViewController != nil {
            navigator.rootViewController.dismiss(animated: true, completion: rebuild)
        } else {
            rebuild()
        }
    }

    func handleSignOutRequested() {
        isAuthenticationRoutePending = false
        let selectedIndex = tabBarController?.selectedIndex

        installRootController(selectedIndex: selectedIndex)
        presentAuthentication(after: 0.35)
    }

    func cleanupUnauthorizedFailure() {
        tabBarController?.activeNavigator.pop(animated: false)
    }

    func errorContext(for visitable: any Visitable, error: HotwireNativeError) -> [String: String] {
        [
            "source": "SceneController",
            "url": visitableURLString(for: visitable),
            "error_type": String(describing: type(of: error)),
        ]
    }

    func visitableURLString(for visitable: any Visitable) -> String {
        if let webViewController = visitable as? HotwireWebViewController {
            return webViewController.currentVisitableURL.absoluteString
        }

        if let visitableController = visitable as? VisitableViewController {
            return visitableController.currentVisitableURL.absoluteString
        }

        return "unknown"
    }
}
