import BridgeComponents
// Hotwire.config is a mutable static from a Swift 5 module; it is only touched on the main thread.
@preconcurrency import HotwireNative
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppAppearance.configure()
        configureHotwire()
        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

private extension AppDelegate {
    private func configureHotwire() {
        Hotwire.loadPathConfiguration(from: [
            .file(AppConfig.bundledPathConfigurationURL),
            .server(AppConfig.remotePathConfigurationURL),
        ])

        Hotwire.config.applicationUserAgentPrefix = AppConfig.applicationUserAgentPrefix
        Hotwire.config.backButtonDisplayMode = .minimal
        Hotwire.config.hideTabBarWhenPushed = true
        Hotwire.config.animateReplaceActions = true
        Hotwire.config.defaultViewController = { url in
            MainActor.assumeIsolated { WebViewController(url: url) }
        }
        Hotwire.config.defaultNavigationController = {
            MainActor.assumeIsolated { NavigationController() }
        }
        Hotwire.config.makeCustomWebView = { configuration in
            MainActor.assumeIsolated { WebViewFactory.makeWebView(configuration: configuration) }
        }
        #if DEBUG
            Hotwire.config.debugLoggingEnabled = true
        #endif

        Hotwire.registerRouteDecisionHandlers([
            DocumentRouteDecisionHandler(),
            AppNavigationRouteDecisionHandler(),
            SafariViewControllerRouteDecisionHandler(),
            SystemNavigationRouteDecisionHandler(),
        ])

        Hotwire.registerBridgeComponents(bridgeComponents)
    }

    private var bridgeComponents: [BridgeComponent.Type] {
        Bridgework.coreComponents.filter { component in
            component != ButtonComponent.self && component != ShareComponent.self
        } + [
            CompatibleButtonComponent.self,
            CompatibleShareComponent.self,
            WidgetStatusComponent.self,
            DownloadComponent.self,
        ]
    }
}
