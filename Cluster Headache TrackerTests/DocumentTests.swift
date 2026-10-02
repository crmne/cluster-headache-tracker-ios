@testable import Cluster_Headache_Tracker
import Foundation
import HotwireNative
import Testing

@MainActor
struct DocumentTests {
    let configuration = Navigator.Configuration(name: "logs", startLocation: URL(string: "https://clusterheadachetracker.com/headache_logs")!)

    func proposal(_ string: String) -> VisitProposal {
        VisitProposal(url: URL(string: string)!, options: VisitOptions(action: .advance), properties: [:])
    }

    @Test func routesOwnPDFAndCSVLinksToQuickLook() {
        let handler = DocumentRouteDecisionHandler()

        #expect(handler.matches(proposal: proposal("https://clusterheadachetracker.com/headache_log_print.pdf?from=2026-01-01"), configuration: configuration))
        #expect(handler.matches(proposal: proposal("https://clusterheadachetracker.com/headache_log_exports.csv"), configuration: configuration))
        #expect(!handler.matches(proposal: proposal("https://clusterheadachetracker.com/headache_logs"), configuration: configuration))
        #expect(!handler.matches(proposal: proposal("https://example.com/report.pdf"), configuration: configuration))
    }

    @Test func namesDownloadsAfterTheTitle() {
        let url = URL(string: "https://clusterheadachetracker.com/headache_log_print.pdf")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: [
            "Content-Disposition": "attachment; filename=\"report.pdf\"",
            "Content-Type": "application/pdf",
        ])!

        #expect(DocumentPreviewer.fileName(title: "Headache report 1/2", response: response, url: url) == "Headache report 1-2.pdf")
        #expect(DocumentPreviewer.fileName(title: nil, response: response, url: url) == "report.pdf")
    }

    @Test func downloadComponentIsRegisteredUnderTheWebName() {
        #expect(DownloadComponent.name == "download")
    }
}
