import HotwireNative
import UIKit

final class ShareComponent: BridgeComponent {
    override static var name: String { "share" }

    private var viewController: UIViewController? {
        delegate?.destination as? UIViewController
    }

    override func onReceive(message: Message) {
        print("ShareComponent received message: \(message.event)")
        guard let event = Event(rawValue: message.event) else {
            print("Unknown event: \(message.event)")
            return
        }

        switch event {
        case .share:
            handleShare(message: message)
        }
    }

    private func handleShare(message: Message) {
        guard let data: MessageData = message.data() else { return }

        var shareItems: [Any] = []

        // Add URL if provided
        if let urlString = data.url, let url = URL(string: urlString) {
            shareItems.append(url)
        }

        // Add title and text if provided
        if let title = data.title {
            shareItems.append(title)
        }

        if let text = data.text {
            shareItems.append(text)
        }

        // If no items to share, return
        guard !shareItems.isEmpty else { return }

        let activityViewController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )

        // For iPad compatibility
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = viewController?.view
            popover.sourceRect = CGRect(x: viewController?.view.bounds.midX ?? 0,
                                        y: viewController?.view.bounds.midY ?? 0,
                                        width: 0,
                                        height: 0)
            popover.permittedArrowDirections = []
        }

        viewController?.present(activityViewController, animated: true) {
            // Reply to web indicating share was presented
            self.reply(to: Event.share.rawValue)
        }
    }
}

// MARK: - Events

private extension ShareComponent {
    enum Event: String {
        case share
    }
}

// MARK: - Message Data

private extension ShareComponent {
    struct MessageData: Decodable {
        let url: String?
        let title: String?
        let text: String?
    }
}
