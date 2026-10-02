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

    /// Text size steps follow the body text style scale, capped at 1.2 so the
    /// page still gets a viewport of at least ~320 CSS pixels on small phones;
    /// beyond that the web layouts start to clip.
    static func pageZoom(for category: UIContentSizeCategory) -> CGFloat {
        switch category {
        case .extraSmall: 0.88
        case .small: 0.92
        case .medium: 0.96
        case .large: 1
        case .extraLarge: 1.06
        case .extraExtraLarge: 1.12
        case .extraExtraExtraLarge: 1.16
        case .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge,
             .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge: 1.2
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
