import HotwireNative
import UIKit

extension HotwireTabBarController {
    /// Refreshes all tabs to ensure they have the latest authentication state
    func refreshAllTabs() {
        print("[Auth] refreshAllTabs called")
        
        // Get the currently selected index to restore it later
        let currentIndex = selectedIndex
        
        // Force visit each tab by temporarily selecting it
        for index in 0..<(viewControllers?.count ?? 0) {
            print("[Auth] Refreshing tab at index \(index)")
            selectedIndex = index
            
            // Get the tab URL and force a reload
            if index < HotwireTab.all.count {
                let tab = HotwireTab.all[index]
                print("[Auth] Routing to \(tab.url) with replace action")
                activeNavigator.route(tab.url, options: VisitOptions(action: .replace))
            }
        }
        
        // Restore the originally selected tab
        selectedIndex = currentIndex
        print("[Auth] Tab refresh complete, restored tab index: \(currentIndex)")
    }
}