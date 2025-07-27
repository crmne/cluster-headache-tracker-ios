import UIKit
import HotwireNative
import WebKit

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
    
    override func visitableDidRender() {
        super.visitableDidRender()
        
        // For the feedback page, ensure iframe content loads properly
        // by injecting JavaScript to wait for iframe load
        if currentVisitableURL.path == "/feedback" {
            let script = """
            (function() {
                const iframe = document.querySelector('iframe');
                if (iframe && !iframe.src) {
                    // Force iframe to reload if src is empty
                    const src = iframe.getAttribute('data-src') || iframe.src;
                    if (src) iframe.src = src;
                }
            })();
            """
            visitableView.webView?.evaluateJavaScript(script)
        }
    }
}