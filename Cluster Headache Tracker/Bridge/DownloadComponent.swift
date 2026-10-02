import HotwireNative
import UIKit

/// Native side of the `bridge--download` Stimulus controller: the web app sends
/// `{ url, title }` for a sign-in protected PDF, which is downloaded with the
/// session cookies and shown in Quick Look.
final class DownloadComponent: BridgeComponent {
    override nonisolated class var name: String { "download" }

    private var viewController: UIViewController? {
        delegate?.destination as? UIViewController
    }

    override func onReceive(message: Message) {
        guard ["download", "connect"].contains(message.event),
              let data: MessageData = message.data(),
              let url = URL(string: data.url, relativeTo: AppConfig.baseURL)?.absoluteURL,
              url.scheme == AppConfig.baseURL.scheme,
              url.host() == AppConfig.baseURL.host(),
              let viewController
        else {
            return
        }

        DocumentPreviewer.shared.preview(url, title: data.title, from: viewController.navigationController ?? viewController)
        reply(to: message.event)
    }
}

extension DownloadComponent {
    struct MessageData: Decodable {
        let url: String
        let title: String?
    }
}
