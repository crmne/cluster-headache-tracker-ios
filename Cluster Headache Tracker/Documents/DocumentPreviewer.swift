@preconcurrency import HotwireNative
import QuickLook
import UIKit
import WebKit

/// Downloads a signed-in document (PDF report, CSV export) with the web view's
/// session cookies and shows it in Quick Look, which offers the share sheet,
/// Save to Files and printing.
@MainActor
final class DocumentPreviewer: NSObject {
    static let shared = DocumentPreviewer()

    private var previewURL: URL?
    private var task: Task<Void, Never>?

    func preview(_ url: URL, title: String?, from presenter: UIViewController) {
        task?.cancel()

        let restoreItem = showActivity(on: presenter)
        task = Task {
            defer { restoreItem() }
            do {
                let fileURL = try await download(url, title: title)
                try Task.checkCancellation()
                present(fileURL, from: presenter)
            } catch is CancellationError {
                return
            } catch {
                showError(error, from: presenter)
            }
        }
    }

    func download(_ url: URL, title: String?) async throws -> URL {
        var request = URLRequest(url: url)
        request.setValue(Hotwire.config.userAgent, forHTTPHeaderField: "User-Agent")
        let cookies = await WKWebsiteDataStore.default().httpCookieStore.allCookies()
        let headers = HTTPCookie.requestHeaderFields(with: cookies.filter { cookie in
            url.host().map { host in host == cookie.domain || host.hasSuffix(cookie.domain) } ?? false
        })
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let directory = FileManager.default.temporaryDirectory.appending(path: "Documents", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let fileURL = directory.appending(path: Self.fileName(title: title, response: httpResponse, url: url))
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    /// `title.pdf` when the web app names the document, otherwise the server's
    /// suggested file name.
    static func fileName(title: String?, response: URLResponse, url: URL) -> String {
        let fileExtension = url.pathExtension.isEmpty ? (response.suggestedFilename.map { URL(filePath: $0).pathExtension } ?? "pdf") : url.pathExtension
        if let title, !title.trimmingCharacters(in: .whitespaces).isEmpty {
            let safe = title.components(separatedBy: CharacterSet(charactersIn: "/\\:?%*|\"<>")).joined(separator: "-")
            return "\(safe).\(fileExtension)"
        }
        return response.suggestedFilename ?? "Document.\(fileExtension)"
    }

    private func present(_ fileURL: URL, from presenter: UIViewController) {
        previewURL = fileURL
        let controller = QLPreviewController()
        controller.dataSource = self
        presenter.present(controller, animated: true)
    }

    private func showActivity(on presenter: UIViewController) -> () -> Void {
        let navigationItem = (presenter as? UINavigationController)?.topViewController?.navigationItem ?? presenter.navigationItem
        let previous = navigationItem.rightBarButtonItem
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        return { navigationItem.rightBarButtonItem = previous }
    }

    private func showError(_ error: any Error, from presenter: UIViewController) {
        let alert = UIAlertController(
            title: String(localized: "Couldn't open the document", comment: "Alert title when a PDF or CSV download fails"),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "Dismiss an alert"), style: .default))
        presenter.present(alert, animated: true)
    }
}

extension DocumentPreviewer: @preconcurrency QLPreviewControllerDataSource {
    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        previewURL == nil ? 0 : 1
    }

    func previewController(_: QLPreviewController, previewItemAt _: Int) -> any QLPreviewItem {
        (previewURL ?? URL(filePath: "/")) as NSURL
    }
}

/// Opens links to PDF and CSV documents on our own domain in Quick Look
/// instead of trying a Turbo visit.
struct DocumentRouteDecisionHandler: RouteDecisionHandler {
    static let documentExtensions: Set<String> = ["pdf", "csv"]

    let name = "document"

    func matches(proposal: VisitProposal, configuration: Navigator.Configuration) -> Bool {
        proposal.url.host() == configuration.startLocation.host() &&
            Self.documentExtensions.contains(proposal.url.pathExtension.lowercased())
    }

    func handle(proposal: VisitProposal, configuration _: Navigator.Configuration, navigator: Navigating) -> Router.Decision {
        let url = proposal.url
        MainActor.assumeIsolated {
            DocumentPreviewer.shared.preview(url, title: nil, from: navigator.activeNavigationController)
        }
        return .cancel
    }
}
