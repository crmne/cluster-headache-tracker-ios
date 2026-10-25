import HotwireNative
import ObjectiveC
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
        // No white band when a page bounces past its edges in dark mode.
        webView.underPageBackgroundColor = .systemBackground
        // A long press on a link shouldn't open a browser preview of an app page.
        webView.allowsLinkPreview = false
        // Swiping down a page lowers the keyboard, as in Messages.
        webView.scrollView.keyboardDismissMode = .interactive
        webView.pageZoom = pageZoom(for: UIApplication.shared.preferredContentSizeCategory)
        PageTitle.follow(webView)
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

/// A screen's title is its page's `<title>`, kept in step as it changes.
/// Hotwire Native reads the title once, when Turbo says a visit rendered, and
/// WebKit can still report the previous page's title then: a sheet that
/// reused its web view showed the last sheet's title. The screen holding the
/// web view follows the title instead, including a page that retitles itself.
@MainActor
enum PageTitle {
    private nonisolated(unsafe) static var key: UInt8 = 0

    static func follow(_ webView: WKWebView) {
        let observation = webView.observe(\.title, options: [.new]) { webView, _ in
            MainActor.assumeIsolated {
                // Turbo swaps <title> elements while it renders, which passes
                // through an empty title.
                guard let title = webView.title, !title.isEmpty, let screen = screen(holding: webView) else { return }
                screen.navigationItem.title = title
            }
        }
        objc_setAssociatedObject(webView, &key, observation, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// The web screen whose view holds `view`, if it's on one.
    static func screen(holding view: UIView) -> UIViewController? {
        sequence(first: view as UIResponder, next: \.next).lazy.compactMap { $0 as? VisitableViewController }.first
    }
}
