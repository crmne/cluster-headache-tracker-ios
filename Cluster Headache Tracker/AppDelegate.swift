import BridgeComponents
import Honeybadger
import HotwireNative
import UIKit

enum EnvironmentConfig {
    static let honeybadgerAPIKey: String? = Bundle.main.object(forInfoDictionaryKey: "HONEYBADGER_API_KEY") as? String
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureHoneybadger()
        AppAppearance.configure()
        configureHotwire()
        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

private extension AppDelegate {
    private func configureHoneybadger() {
        guard let apiKey = EnvironmentConfig.honeybadgerAPIKey,
              !apiKey.isEmpty
        else {
            return
        }

        Honeybadger.configure(
            apiKey: apiKey,
            environment: AppConfig.isDebug ? "development" : "production"
        )

        Honeybadger.setContext(context: [
            "app_version": AppConfig.appVersion,
            "build_number": AppConfig.buildNumber,
            "ios_version": UIDevice.current.systemVersion,
            "device_model": UIDevice.current.model,
        ])
    }

    private func configureHotwire() {
        Hotwire.loadPathConfiguration(from: [
            .file(AppConfig.bundledPathConfigurationURL),
            .server(AppConfig.remotePathConfigurationURL),
        ])

        Hotwire.config.applicationUserAgentPrefix = AppConfig.applicationUserAgentPrefix
        Hotwire.config.backButtonDisplayMode = .minimal
        Hotwire.config.showDoneButtonOnModals = true
        Hotwire.config.hideTabBarWhenPushed = true
        #if DEBUG
            Hotwire.config.debugLoggingEnabled = true
        #endif

        Hotwire.registerBridgeComponents(bridgeComponents)
    }

    private var bridgeComponents: [BridgeComponent.Type] {
        Bridgework.coreComponents.filter { component in
            component != ButtonComponent.self && component != ShareComponent.self
        } + [
            CompatibleButtonComponent.self,
            CompatibleShareComponent.self,
        ]
    }
}
