import UIKit
import WebKit

/// Builds the web views Hotwire uses and keeps their zoom in step with the
/// system text size, so Dynamic Type applies to web content as well.
@MainActor
enum WebViewFactory {
    private static let webViews = NSHashTable<WKWebView>.weakObjects()
    private static var contentSizeObserver: NSObjectProtocol?

    static func makeWebView(configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground
        webView.pageZoom = pageZoom(for: UIApplication.shared.preferredContentSizeCategory)
        #if DEBUG
            webView.isInspectable = true
        #endif

        webViews.add(webView)
        observeContentSizeChanges()

        return webView
    }

    /// Text size steps roughly follow the body text style scale, capped so that
    /// layouts built for phones remain usable at accessibility sizes.
    static func pageZoom(for category: UIContentSizeCategory) -> CGFloat {
        switch category {
        case .extraSmall: 0.85
        case .small: 0.9
        case .medium: 0.95
        case .large: 1
        case .extraLarge: 1.1
        case .extraExtraLarge: 1.2
        case .extraExtraExtraLarge: 1.3
        case .accessibilityMedium: 1.4
        case .accessibilityLarge, .accessibilityExtraLarge,
             .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge: 1.5
        default: 1
        }
    }

    private static func observeContentSizeChanges() {
        guard contentSizeObserver == nil else { return }

        contentSizeObserver = NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                let zoom = pageZoom(for: UIApplication.shared.preferredContentSizeCategory)
                webViews.allObjects.forEach { $0.pageZoom = zoom }
            }
        }
    }
}
