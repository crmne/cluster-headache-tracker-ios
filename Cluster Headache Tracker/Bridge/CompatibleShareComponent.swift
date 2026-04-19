import BridgeComponents
import HotwireNative
import UIKit

final class CompatibleShareComponent: BridgeComponent {
    override nonisolated class var name: String { "share" }

    private var viewController: UIViewController? {
        delegate?.destination as? UIViewController
    }

    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else { return }

        switch event {
        case .connect:
            addButton(via: message)
        case .share:
            share(from: message)
        }
    }

    private func addButton(via message: Message) {
        guard let data: MessageData = message.data(), let items = data.activityItems, !items.isEmpty else {
            return
        }

        let action = UIAction { [weak self] _ in
            self?.presentShareSheet(with: items)
        }

        let item = UIBarButtonItem(
            title: "Share",
            image: UIImage(systemName: "square.and.arrow.up"),
            primaryAction: action
        )
        item.tintColor = Bridgework.color("Share", hex: data.colorCode)
        viewController?.navigationItem.rightBarButtonItem = item
    }

    private func share(from message: Message) {
        guard let data: MessageData = message.data(), let items = data.activityItems, !items.isEmpty else {
            return
        }

        presentShareSheet(with: items)
        reply(to: message.event)
    }

    private func presentShareSheet(with items: [Any]) {
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = viewController?.view
            popover.sourceRect = CGRect(
                x: viewController?.view.bounds.midX ?? 0,
                y: viewController?.view.bounds.midY ?? 0,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        viewController?.present(activityViewController, animated: true)
    }
}

private extension CompatibleShareComponent {
    enum Event: String {
        case connect
        case share
    }

    struct MessageData: Decodable {
        let urlString: String?
        let title: String?
        let text: String?
        let colorCode: String?

        var activityItems: [Any]? {
            var items = [Any]()

            if let urlString, let url = URL(string: urlString) {
                items.append(url)
            }

            if let title, !title.isEmpty {
                items.append(title)
            }

            if let text, !text.isEmpty {
                items.append(text)
            }

            return items.isEmpty ? nil : items
        }

        enum CodingKeys: String, CodingKey {
            case urlString = "url"
            case title
            case text
            case colorCode = "color"
        }
    }
}
