import Foundation

/// Hands deep links from App Intents to the scene. Links requested before the
/// scene is ready are kept until a handler is installed.
@MainActor
final class DeepLinkCenter {
    static let shared = DeepLinkCenter()

    private var pending: DeepLink?

    var handler: ((DeepLink) -> Void)? {
        didSet {
            if let pending, let handler {
                self.pending = nil
                handler(pending)
            }
        }
    }

    func open(_ link: DeepLink) {
        if let handler {
            handler(link)
        } else {
            pending = link
        }
    }
}
