import HotwireNative
import UIKit

let rootURL = URL(string: "https://clusterheadachetracker.com")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    let homeURL = URL(string: "\(rootURL.absoluteString)/headache_logs")!

    lazy var localPathConfigURL: URL = {
        Bundle.main.url(forResource: "ios_v1", withExtension: "json")!
    }()

    lazy var remotePathConfigURL: URL = {
        URL(string: "\(rootURL.absoluteString)/configurations/ios_v1.json")!
    }()

    lazy var pathConfiguration: PathConfiguration = {
        PathConfiguration(sources: [
            .file(localPathConfigURL),
            .server(remotePathConfigURL)
        ])
    }()

    lazy var navigator: Navigator = {
        let nav = Navigator(pathConfiguration: pathConfiguration)
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
        
        // Set the window background color to match the nav bar
        window?.backgroundColor = UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 1) // #4f46e5
        
        navigator.route(homeURL)
    }
}

extension SceneDelegate: NavigatorDelegate {
    func navigator(_ navigator: Navigator, didReceiveServerRedirect response: URLResponse) {
        // Handle redirects by routing to the new URL
        if let url = response.url {
            navigator.route(url)
        }
    }
}
