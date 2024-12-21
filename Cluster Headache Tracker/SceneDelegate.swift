import HotwireNative
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    let rootURL = URL(string: "https://clusterheadachetracker.com")!
    let homeURL = URL(string: "https://clusterheadachetracker.com/headache_logs")!

    lazy var navigator: Navigator = {
        let nav = Navigator()
        nav.delegate = self
        return nav
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()
        navigator.rootViewController.setNavigationBarHidden(true, animated: true)
        navigator.modalRootViewController.setNavigationBarHidden(true, animated: true)
        
        navigator.route(homeURL)
    }
}

extension SceneDelegate: NavigatorDelegate {
    func navigator(_ navigator: Navigator, didReceiveServerRedirect response: URLResponse) {
        if let url = response.url {
            navigator.route(url)
        }
    }
}
