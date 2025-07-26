import HotwireNative
import SafariServices
import UIKit
import WebKit

final class SceneController: UIResponder {
    var window: UIWindow?
    
    private let rootURL = AppConfig.current
    private lazy var tabBarController = HotwireTabBarController(navigatorDelegate: self)
    
    // MARK: - Authentication
    
    private func promptForAuthentication() {
        let authURL = rootURL.appendingPathComponent("/users/sign_in")
        
        // Use the active navigator's modal presentation instead
        // This will respect the path configuration for modal context
        tabBarController.activeNavigator.route(authURL, options: VisitOptions(action: .advance))
    }
}

extension SceneController: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        tabBarController.delegate = self
        tabBarController.load(HotwireTab.all)
    }
}


extension SceneController: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        // Check for recede_historical_location and handle modal dismissal
        if proposal.url.path == "/recede_historical_location" {
            DispatchQueue.main.async {
                if let presented = navigator.rootViewController.presentedViewController {
                    presented.dismiss(animated: true)
                }
            }
            return .reject
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

