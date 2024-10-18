import HotwireNative
import UIKit

let rootURL = URL(string: "https://clusterheadachetracker.com")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    lazy var localPathConfigURL: URL = {
        Bundle.main.url(forResource: "ios_v1", withExtension: "json")!
    }()

    lazy var remotePathConfigURL: URL = {
        URL(string: "\(rootURL)/configurations/ios_v1.json")!
    }()

    lazy var pathConfiguration: PathConfiguration = {
        PathConfiguration(sources: [
            .file(localPathConfigURL),
            .server(remotePathConfigURL)
        ])
    }()

    lazy var navigator: Navigator = {
        Navigator(pathConfiguration: pathConfiguration)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()
        navigator.route(rootURL)
    }
}
