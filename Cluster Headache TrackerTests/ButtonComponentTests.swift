@testable import Cluster_Headache_Tracker
import Foundation
import Testing

@MainActor
struct ButtonComponentTests {
    func action(_ json: String) throws -> CompatibleButtonComponent.NativeAction? {
        try JSONDecoder().decode(CompatibleButtonComponent.MessageData.self, from: Data(json.utf8)).resolvedNativeAction
    }

    @Test func nativeActionWinsOverTranslatedTitles() throws {
        #expect(try action(#"{"title":"Abmelden","nativeAction":"sign-out","metadata":{"url":"/settings"}}"#) == .signOut)
        #expect(try action(#"{"title":"Drucken","iosImage":"printer","nativeAction":"print"}"#) == .print)
        #expect(try action(#"{"title":"Unterstützen","nativeAction":"sponsor"}"#) == .sponsor)
    }

    @Test func olderServersFallBackToEnglishTitlesAndThePrinterSymbol() throws {
        #expect(try action(#"{"title":"Sign Out"}"#) == .signOut)
        #expect(try action(#"{"title":"Print"}"#) == .print)
        #expect(try action(#"{"title":"Sponsor"}"#) == .sponsor)
        #expect(try action(#"{"title":"Drucken","iosImage":"printer"}"#) == .print)
    }

    @Test func ordinaryButtonsHaveNoNativeAction() throws {
        #expect(try action(#"{"title":"Neu","iosImage":"plus"}"#) == nil)
        #expect(try action(#"{"title":"Abmelden"}"#) == nil)
        #expect(try action(#"{"title":"Neu","nativeAction":"unknown"}"#) == nil)
    }
}
