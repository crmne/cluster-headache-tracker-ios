import HotwireNative
import UIKit
import WebKit

final class ButtonComponent: BridgeComponent {
    override static var name: String { "button" }

    private var viewController: UIViewController? {
        delegate?.destination as? UIViewController
    }

    private var webView: WKWebView? {
        (delegate?.destination as? VisitableViewController)?.visitableView.webView
    }

    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else { return }

        switch event {
        case .connect:
            addButton(via: message)
        }
    }

    private func addButton(via message: Message) {
        guard let data: MessageData = message.data() else { return }

        let image = UIImage(systemName: data.image ?? "")
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            // Check if this is the Sign Out button
            if data.title == "Sign Out" {
                // First reply to the web to trigger sign out
                reply(to: message.event)

                // Then immediately trigger the authentication flow
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .signOutRequested, object: nil)
                }
            } else if data.title == "Print" {
                // Handle print button
                reply(to: message.event)
                printCurrentPage()
            } else {
                reply(to: message.event)
            }
        }
        let item = UIBarButtonItem(title: data.title, image: image, primaryAction: action)
        viewController?.navigationItem.rightBarButtonItem = item
    }

    private func printCurrentPage() {
        guard let webView else { return }

        let printController = UIPrintInteractionController.shared

        // Configure print info
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Headache Log"
        printController.printInfo = printInfo

        // Set the print formatter
        printController.printFormatter = webView.viewPrintFormatter()

        // Present the print controller
        printController.present(animated: true) { _, completed, error in
            if completed {
                print("Print completed successfully")
            } else if let error {
                print("Print failed with error: \(error.localizedDescription)")
            } else {
                print("Print cancelled")
            }
        }
    }
}

private extension ButtonComponent {
    enum Event: String {
        case connect
    }
}

private extension ButtonComponent {
    struct MessageData: Decodable {
        let title: String
        let image: String?

        enum CodingKeys: String, CodingKey {
            case title
            case image = "iosImage"
        }
    }
}
