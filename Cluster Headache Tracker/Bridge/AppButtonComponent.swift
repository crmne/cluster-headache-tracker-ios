import BridgeComponents
import HotwireNative
import UIKit
import WebKit

extension Notification.Name {
    static let appSignOutRequested = Notification.Name("AppSignOutRequested")
}

final class AppButtonComponent: BridgeComponent {
    override nonisolated class var name: String { "button" }

    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else { return }

        switch event {
        case .left, .right:
            addButton(via: message, side: event)
        case .disconnect:
            removeButton()
        }
    }

    private func addButton(via message: Message, side: Event) {
        guard let data: MessageData = message.data() else { return }

        let action = UIAction { [weak self] _ in
            self?.handleTap(data: data, replyEvent: message.event)
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
        case .right:
            viewController?.navigationItem.rightBarButtonItem = item
        default:
            break
        }
    }

    private func handleTap(data: MessageData, replyEvent: String) {
        reply(to: replyEvent)

        if data.title == "Sign Out" {
            signOut()
        }
    }

    private func signOut() {
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: .distantPast
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                NotificationCenter.default.post(name: .appSignOutRequested, object: nil)
            }
        }
    }

    private func removeButton() {
        viewController?.navigationItem.leftBarButtonItem = nil
        viewController?.navigationItem.rightBarButtonItem = nil
    }
}

private extension AppButtonComponent {
    enum Event: String {
        case left
        case right
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
