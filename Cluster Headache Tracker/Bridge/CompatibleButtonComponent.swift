import BridgeComponents
import HotwireNative
import UIKit
import WebKit

/// Joe Masilotti's `button` contract (`left`, `right`, `disconnect`) plus the
/// legacy `connect` event the Rails app still sends, and native printing for
/// the print report page.
final class CompatibleButtonComponent: BridgeComponent {
    override nonisolated class var name: String { "button" }

    private var viewController: UIViewController? {
        delegate?.destination as? UIViewController
    }

    private var webView: WKWebView? {
        (delegate?.destination as? VisitableViewController)?.visitableView.webView
    }

    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else { return }

        switch event {
        case .left:
            addButton(via: message, side: .left)
        case .right, .connect:
            addButton(via: message, side: .right)
        case .disconnect:
            removeButtons()
        }
    }

    private func addButton(via message: Message, side: Side) {
        guard let data: MessageData = message.data() else { return }

        let action = UIAction { [weak self] _ in
            self?.handleTap(for: data, replyEvent: message.event)
        }

        let item = UIBarButtonItem(
            title: data.title,
            image: data.image.flatMap { UIImage(systemName: $0) },
            primaryAction: action
        )
        item.tintColor = Bridgework.color("Button", hex: data.colorCode)

        switch side {
        case .left:
            viewController?.navigationItem.leftItemsSupplementBackButton = true
            viewController?.navigationItem.leftBarButtonItem = item
        case .right:
            if isPresentedModally {
                item.style = Self.primaryActionStyle
            }
            viewController?.navigationItem.rightBarButtonItem = item
        }
    }

    private func handleTap(for data: MessageData, replyEvent: String) {
        reply(to: replyEvent)

        if data.isPrint {
            printCurrentPage()
        }
    }

    private func removeButtons() {
        viewController?.navigationItem.leftBarButtonItem = nil
        viewController?.navigationItem.rightBarButtonItem = nil
    }

    private var isPresentedModally: Bool {
        viewController?.presentingViewController != nil
    }

    private static var primaryActionStyle: UIBarButtonItem.Style {
        if #available(iOS 26.0, *) {
            .prominent
        } else {
            .done
        }
    }

    private func printCurrentPage() {
        guard let webView else { return }

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = webView.title ?? String(localized: "Headache Report", comment: "Default print job name")

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printFormatter = webView.viewPrintFormatter()
        printController.present(animated: true)
    }
}

private extension CompatibleButtonComponent {
    enum Event: String {
        case left
        case right
        case connect
        case disconnect
    }

    enum Side {
        case left
        case right
    }

    struct MessageData: Decodable {
        let title: String
        let image: String?
        let colorCode: String?

        /// The print page's button is identified by its SF Symbol, falling back
        /// to the English title older server builds send.
        var isPrint: Bool {
            image == "printer" || title == "Print"
        }

        enum CodingKeys: String, CodingKey {
            case title
            case image = "iosImage"
            case colorCode = "color"
        }
    }
}
