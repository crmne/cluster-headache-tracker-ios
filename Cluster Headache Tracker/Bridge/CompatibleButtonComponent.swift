import BridgeComponents
import HotwireNative
import UIKit
import WebKit

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
        case .left, .right:
            addButton(via: message, side: event)
        case .connect:
            addButton(via: message, side: .right)
        case .disconnect:
            removeButtons()
        }
    }

    private func addButton(via message: Message, side: Event) {
        guard let data: MessageData = message.data() else { return }

        let action = UIAction { [weak self] _ in
            self?.handleTap(for: data, replyEvent: message.event)
        }

        let item = UIBarButtonItem(
            title: data.title,
            image: data.image.flatMap(UIImage.init(systemName:)),
            primaryAction: action
        )
        item.tintColor = Bridgework.color("Button", hex: data.colorCode)

        switch side {
        case .left:
            viewController?.navigationItem.leftItemsSupplementBackButton = true
            viewController?.navigationItem.leftBarButtonItem = item
        case .right, .connect:
            viewController?.navigationItem.rightBarButtonItem = item
        case .disconnect:
            break
        }
    }

    private func handleTap(for data: MessageData, replyEvent: String) {
        reply(to: replyEvent)

        switch data.title {
        case "Print":
            printCurrentPage()
        case "Sign Out":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                NotificationCenter.default.post(name: .clusterHeadacheTrackerSignOutRequested, object: nil)
            }
        default:
            break
        }
    }

    private func removeButtons() {
        viewController?.navigationItem.leftBarButtonItem = nil
        viewController?.navigationItem.rightBarButtonItem = nil
    }

    private func printCurrentPage() {
        guard let webView else { return }

        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Headache Report"

        printController.printInfo = printInfo
        printController.printFormatter = webView.viewPrintFormatter()
        printController.present(animated: true) { _, _, _ in }
    }
}

private extension CompatibleButtonComponent {
    enum Event: String {
        case left
        case right
        case connect
        case disconnect
    }

    struct MessageData: Decodable {
        let title: String
        let image: String?
        let colorCode: String?

        enum CodingKeys: String, CodingKey {
            case title
            case image = "iosImage"
            case colorCode = "color"
        }
    }
}
