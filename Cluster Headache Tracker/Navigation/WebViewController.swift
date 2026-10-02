import HotwireNative
import UIKit

final class WebViewController: HotwireWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if isRootOfModal {
            addCloseButton()
        }
    }

    /// Modal sheets get a system close button on the leading side so the trailing
    /// side stays free for the form's primary action (bridge `button` component).
    private func addCloseButton() {
        let action = UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: action)
    }

    private var isRootOfModal: Bool {
        presentingViewController != nil && navigationController?.viewControllers.first == self
    }
}
