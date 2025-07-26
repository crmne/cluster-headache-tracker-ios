import HotwireNative
import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppearance()
        configureHotwire()
        return true
    }
    
    // Make navigation and tab bars opaque.
    private func configureAppearance() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        // Primary color from Rails app (#4f46e5)
        navBarAppearance.backgroundColor = UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 1.0)
        
        // White title text
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        // Configure button appearance
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.buttonAppearance = buttonAppearance
        
        // Apply to all navigation bars
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = .white
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set tab bar colors to match Rails app
        UITabBar.appearance().tintColor = UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 1.0) // Primary color
    }
    
    private func configureHotwire() {
        // Load the path configuration
        Hotwire.loadPathConfiguration(from: [
            .file(Bundle.main.url(forResource: "ios_v1", withExtension: "json")!)
        ])
        
        // Set custom user agent to include Turbo Native and version for detection
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        Hotwire.config.applicationUserAgentPrefix = "Turbo Native; ClusterHeadacheTracker/\(appVersion).\(buildNumber);"
        
        // Register bridge components
        Hotwire.registerBridgeComponents([
            ShareComponent.self,
            ButtonComponent.self
        ])
        
        // Set configuration options
        Hotwire.config.backButtonDisplayMode = .minimal
        Hotwire.config.showDoneButtonOnModals = true
        Hotwire.config.defaultViewController = { url in
            SafeAreaWebViewController(url: url)
        }
#if DEBUG
        Hotwire.config.debugLoggingEnabled = true
#endif
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
