import UIKit
import HotwireNative

/// Custom web view controller that respects safe area boundaries
class SafeAreaWebViewController: HotwireWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove the existing constraints
        view.constraints.forEach { constraint in
            if constraint.firstItem === visitableView || constraint.secondItem === visitableView {
                constraint.isActive = false
            }
        }
        
        // Add new constraints that respect the safe area
        NSLayoutConstraint.activate([
            visitableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visitableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visitableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            visitableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}