import HotwireNative
import SafariServices
import UIKit
import WebKit

extension Notification.Name {
    static let authenticationStateChanged = Notification.Name("authenticationStateChanged")
    static let signOutRequested = Notification.Name("signOutRequested")
}

final class SceneController: UIResponder {
    var window: UIWindow?

    private let rootURL = AppConfig.current
    private var tabBarController: HotwireTabBarController!

    // MARK: - Authentication

    private func promptForAuthentication() {
        let authURL = rootURL.appendingPathComponent("/users/sign_in")

        // Use the active navigator's modal presentation instead
        // This will respect the path configuration for modal context
        tabBarController.activeNavigator.route(authURL, options: VisitOptions(action: .advance))
    }

    private func setupAuthenticationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAuthenticationStateChanged),
            name: .authenticationStateChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSignOutRequested),
            name: .signOutRequested,
            object: nil
        )
    }

    @objc private func handleAuthenticationStateChanged() {
        print("[Auth] Authentication state changed notification received")

        DispatchQueue.main.async { [weak self] in
            print("[Auth] Starting tab refresh after sign-in")
            self?.tabBarController.refreshAllTabs()
        }
    }

    @objc private func handleSignOutRequested() {
        print("[Auth] Sign out requested, clearing all navigators")

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            // Clear all navigators and refresh tabs
            if let viewControllers = tabBarController.viewControllers {
                for (index, _) in viewControllers.enumerated() {
                    if index < HotwireTab.all.count {
                        // Select each tab to access its navigator
                        tabBarController.selectedIndex = index
                        // Clear the navigator
                        tabBarController.activeNavigator.clearAll()
                        // Route to the tab's URL to refresh it
                        let tab = HotwireTab.all[index]
                        tabBarController.activeNavigator.route(tab.url, options: VisitOptions(action: .replace))
                    }
                }
            }

            // Reset to first tab
            tabBarController.selectedIndex = 0

            // Navigate to sign in
            promptForAuthentication()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SceneController: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)

        // Create tab bar controller
        tabBarController = HotwireTabBarController(navigatorDelegate: self)
        tabBarController.delegate = self
        tabBarController.load(HotwireTab.all)

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        setupAuthenticationObserver()
    }
}

extension SceneController: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        print("[Auth] NavigatorDelegate handling proposal to: \(proposal.url.path)")

        // Check for recede_historical_location and handle modal dismissal
        if proposal.url.path == "/recede_historical_location" {
            print("[Auth] Received recede_historical_location")
            DispatchQueue.main.async {
                if let presented = navigator.rootViewController.presentedViewController {
                    print("[Auth] Found presented view controller, dismissing...")
                    presented.dismiss(animated: true) {
                        print("[Auth] Modal dismissed, posting notification")
                        // Post notification after successful authentication
                        NotificationCenter.default.post(name: .authenticationStateChanged, object: nil)
                    }
                } else {
                    print("[Auth] No presented view controller found, posting notification anyway")
                    // Post notification even if no modal to dismiss
                    NotificationCenter.default.post(name: .authenticationStateChanged, object: nil)
                }
            }
            return .reject
        }

        // Alternative: Check if we're going to headache_logs from a modal (likely after login)
        if proposal.url.path == "/headache_logs", navigator.rootViewController.presentedViewController != nil {
            print("[Auth] Detected navigation to /headache_logs with modal present - likely successful login")
            DispatchQueue.main.async {
                if let presented = navigator.rootViewController.presentedViewController {
                    presented.dismiss(animated: true) {
                        print("[Auth] Modal dismissed after login, posting notification")
                        NotificationCenter.default.post(name: .authenticationStateChanged, object: nil)
                    }
                }
            }
        }

        switch proposal.viewController {
        default:
            return .accept
        }
    }

    func visitableDidFailRequest(_ visitable: any Visitable, error: any Error, retryHandler: RetryBlock?) {
        if let turboError = error as? TurboError, case let .http(statusCode) = turboError, statusCode == 401 {
            promptForAuthentication()
        } else if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error) {
                retryHandler?()
            }
        } else {
            let alert = UIAlertController(title: "Visit failed!", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            tabBarController.activeNavigator.present(alert, animated: true)
        }
    }
}

extension SceneController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Check if the "New" tab is being selected (index 2)
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 2 {
            // Navigate to the new headache page
            let newHeadacheURL = rootURL.appendingPathComponent("headache_logs/new")
            self.tabBarController.activeNavigator.route(newHeadacheURL)

            return false // Don't actually select the "New" tab
        }

        return true
    }
}
