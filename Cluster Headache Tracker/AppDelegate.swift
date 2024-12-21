import HotwireNative
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Load the path configuration
        let baseURL = URL(string: "https://clusterheadachetracker.com")!
        Hotwire.loadPathConfiguration(from: [
            .file(Bundle.main.url(forResource: "ios_v1", withExtension: "json")!),
            .server(baseURL.appendingPathComponent("configurations/ios_v1.json"))
        ])
        
        // Set custom user agent if needed
        Hotwire.config.applicationUserAgentPrefix = "ClusterHeadacheTracker;"
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
