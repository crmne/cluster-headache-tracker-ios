import HotwireNative
import UIKit

let baseURL = URL(string: "http://192.168.8.231:3000")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var tabBarController = HotwireTabBarController(navigatorDelegate: self)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // Configure tab bar appearance
        configureTabBarAppearance()
        
        tabBarController.load(HotwireTab.all)
        
        // Hide navigation bars for all tabs
        hideNavigationBars()
        
        // Setup modal navigation bars
        setupModalNavigationBars()
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.isTranslucent = false
    }
    
    private func hideNavigationBars() {
        // Hide navigation bars for all tab view controllers
        tabBarController.viewControllers?.forEach { viewController in
            if let navController = viewController as? UINavigationController {
                navController.setNavigationBarHidden(true, animated: false)
            }
        }
    }
    
    private func setupModalNavigationBars() {
        // Get all tabs and hide navigation bars for their modal navigators
        // For each tab's navigator, hide the modal navigation bar
        for i in 0..<HotwireTab.all.count {
            tabBarController.selectedIndex = i
            let navigator = tabBarController.activeNavigator
            navigator.modalRootViewController.setNavigationBarHidden(true, animated: false)
        }
        // Reset to first tab
        tabBarController.selectedIndex = 0
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
        return .accept
    }
}

extension HotwireTab {
    static let all: [HotwireTab] = [
        HotwireTab(
            title: "Logs",
            image: UIImage(systemName: "calendar")!,
            url: baseURL.appendingPathComponent("headache_logs")
        ),
        HotwireTab(
            title: "Charts", 
            image: UIImage(systemName: "chart.bar")!,
            url: baseURL.appendingPathComponent("charts")
        ),
        HotwireTab(
            title: "New",
            image: UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!,
            url: baseURL.appendingPathComponent("headache_logs/new")
        ),
        HotwireTab(
            title: "Account",
            image: UIImage(systemName: "person")!,
            url: baseURL.appendingPathComponent("settings")
        ),
        HotwireTab(
            title: "Feedback",
            image: UIImage(systemName: "bubble.left")!,
            url: baseURL.appendingPathComponent("feedback")
        )
    ]
}
