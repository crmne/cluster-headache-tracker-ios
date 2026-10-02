import Honeybadger
import HotwireNative
import UIKit

final class SceneController: UIResponder {
    var window: UIWindow?

    private var tabBarController: AppTabBarController?
    private var isAuthenticationRoutePending = false
    private var signOutObserver: NSObjectProtocol?
    private var lastSignOut: ContinuousClock.Instant?
}

extension SceneController: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        installRootController(selectedTabID: nil)

        window.makeKeyAndVisible()

        signOutObserver = NotificationCenter.default.addObserver(
            forName: .signOutRequested,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleSignOut()
            }
        }

        DeepLinkCenter.shared.handler = { [weak self] link in
            self?.open(link)
        }

        if let shortcutItem = connectionOptions.shortcutItem {
            handle(shortcutItem)
        }
        if let url = connectionOptions.urlContexts.first?.url {
            handle(url)
        }
    }

    func scene(_: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
        if let url = contexts.first?.url {
            handle(url)
        }
    }

    func windowScene(
        _: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(handle(shortcutItem))
    }
}

private extension SceneController {
    @discardableResult
    func handle(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let link = DeepLink(shortcutType: shortcutItem.type) else { return false }
        open(link)
        return true
    }

    func handle(_ url: URL) {
        if let link = DeepLink(appURL: url) {
            open(link)
        }
    }

    /// Routes a deep link from the visible tab, closing any sheet first so the
    /// destination always ends up on top.
    func open(_ link: DeepLink) {
        guard let navigator = tabBarController?.activeNavigator else { return }
        let url = link.webURL(baseURL: AppConfig.baseURL)

        if let presented = navigator.rootViewController.presentedViewController {
            presented.dismiss(animated: false) {
                navigator.route(url)
            }
        } else {
            navigator.route(url)
        }
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

    func formSubmissionDidFinish(at url: URL) {
        if AppConfig.isSignOutURL(url) {
            handleSignOut()
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

    func installRootController(selectedTabID: String?) {
        let controller = AppTabBarController(navigatorDelegate: self)
        controller.onCreateRequested = { [weak self] in
            self?.routeToNewHeadacheLog()
        }
        controller.load(AppTabs.all)

        if let selectedTabID {
            controller.selectTab(withID: selectedTabID)
        }

        tabBarController = controller
        window?.rootViewController = controller
    }

    func presentAuthentication(after delay: Duration = .zero) {
        guard let tabBarController else { return }
        guard !isAuthenticationRoutePending, !authenticationIsVisible else { return }

        isAuthenticationRoutePending = true

        Task { @MainActor [weak tabBarController] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            tabBarController?.activeNavigator.route(AppConfig.signInURL)
        }
    }

    func routeToNewHeadacheLog() {
        tabBarController?.activeNavigator.route(AppConfig.newHeadacheLogURL)
    }

    func rebuildAfterAuthentication(using navigator: Navigator) {
        isAuthenticationRoutePending = false
        let selectedTabID = tabBarController?.selectedTab?.identifier

        let rebuild: () -> Void = { [weak self] in
            self?.installRootController(selectedTabID: selectedTabID)
        }

        if navigator.rootViewController.presentedViewController != nil {
            navigator.rootViewController.dismiss(animated: true, completion: rebuild)
        } else {
            rebuild()
        }
    }

    /// Rebuilds every tab after signing out so no signed-in screen stays cached
    /// behind another tab, then asks for credentials again.
    func handleSignOut() {
        // The sign out button and the form submission both report the same sign out.
        let now = ContinuousClock.now
        if let lastSignOut, now - lastSignOut < .seconds(3) {
            return
        }
        lastSignOut = now

        isAuthenticationRoutePending = false
        StatusSync.clear()
        let selectedTabID = tabBarController?.selectedTab?.identifier

        installRootController(selectedTabID: selectedTabID)
        presentAuthentication(after: .milliseconds(350))
    }

    func cleanupUnauthorizedFailure() {
        tabBarController?.activeNavigator.pop(animated: false)
    }

    func errorContext(for visitable: any Visitable, error: HotwireNativeError) -> [String: String] {
        [
            "source": "SceneController",
            "url": visitableURLString(for: visitable),
            "error_type": String(describing: type(of: error)),
            "status_code": error.statusCode.map(String.init) ?? "none",
        ]
    }

    func visitableURLString(for visitable: any Visitable) -> String {
        if let visitableController = visitable as? VisitableViewController {
            return visitableController.currentVisitableURL.absoluteString
        }

        return "unknown"
    }
}
