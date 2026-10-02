import XCTest

/// Runs against production read-only: it only looks at the native chrome and
/// the public sign-in page, and never signs in or submits anything.
final class AppLaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testShowsNativeTabsAndAsksToSignIn() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 30))
        for title in ["Logs", "Charts", "New", "Account", "Feedback"] {
            XCTAssertTrue(tabBar.buttons[title].exists, "Missing tab \(title)")
        }

        let signIn = app.navigationBars["Sign in to your account"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 30), "Sign-in sheet did not appear")
        XCTAssertTrue(signIn.buttons["close-sheet"].exists, "Sheet has no close button")

        add(screenshot(of: app, named: "Sign in"))
    }

    @MainActor
    func testUsesGermanWhenTheDeviceIsInGerman() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(de)", "-AppleLocale", "de_DE"]
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 30))
        XCTAssertTrue(tabBar.buttons["Diagramme"].exists)
        XCTAssertTrue(tabBar.buttons["Konto"].exists)

        add(screenshot(of: app, named: "Sign in (German)"))
    }

    @MainActor
    private func screenshot(of app: XCUIApplication, named name: String) -> XCTAttachment {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        return attachment
    }
}
