import XCTest

/// Signs in to a local preview server and screenshots the main screens.
/// Skipped unless the test runner gets the server and a demo account through
/// the environment of `xcodebuild`:
///
///     TEST_RUNNER_CHT_PREVIEW_URL=http://localhost:3000 \
///     TEST_RUNNER_CHT_DEMO_USERNAME=demo TEST_RUNNER_CHT_DEMO_PASSWORD=... \
///       xcodebuild test -only-testing:"Cluster Headache TrackerUITests/SignedInTourUITests" ...
///
/// Never point it at production: it signs in and opens forms.
final class SignedInTourUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    func testSignedInTour() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let baseURL = environment["CHT_PREVIEW_URL"],
              let username = environment["CHT_DEMO_USERNAME"],
              let password = environment["CHT_DEMO_PASSWORD"]
        else {
            throw XCTSkip("Set CHT_PREVIEW_URL, CHT_DEMO_USERNAME and CHT_DEMO_PASSWORD to run the signed-in tour")
        }
        XCTAssertFalse(baseURL.contains("clusterheadachetracker.com"), "The tour must not run against production")

        app = XCUIApplication()
        app.launchEnvironment["CLUSTER_HEADACHE_TRACKER_BASE_URL"] = baseURL
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        signIn(username: username, password: password)

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 30))
        sleep(4)
        capture("01-dashboard")

        openLogDetail()

        app.tabBars.buttons["Charts"].tap()
        sleep(10)
        capture("05-charts")

        app.tabBars.buttons["New"].tap()
        sleep(5)
        capture("06-new-log-sheet")
        closeSheet()

        app.open(URL(string: "clusterheadachetracker://headache_logs/new?quick=1")!)
        sleep(5)
        capture("07-quick-log")
        closeSheet()

        app.open(URL(string: "clusterheadachetracker://current_attack")!)
        sleep(5)
        capture("08-current-attack")
        closeSheet()

        app.tabBars.buttons["Logs"].tap()
        sleep(3)
        XCUIDevice.shared.press(.home)
        sleep(3)
        capture("09-dynamic-island", screen: true)
    }

    @MainActor
    private func signIn(username: String, password: String) {
        let usernameField = app.webViews.textFields.firstMatch
        guard usernameField.waitForExistence(timeout: 20) else {
            // Still signed in from an earlier run.
            return
        }
        capture("00-sign-in")
        usernameField.tap()
        usernameField.typeText(username)

        let passwordField = app.webViews.secureTextFields.firstMatch
        passwordField.tap()
        passwordField.typeText(password)

        app.webViews.buttons["Sign in"].firstMatch.tap()
    }

    @MainActor
    private func openLogDetail() {
        let detailLink = app.webViews.links.matching(NSPredicate(format: "label CONTAINS %@", "·")).firstMatch
        guard detailLink.waitForExistence(timeout: 10) else {
            print("TOUR: no log link found\n\(app.webViews.firstMatch.debugDescription)")
            return
        }
        detailLink.tap()
        sleep(4)
        capture("02-log-detail")

        let menuButton = app.navigationBars.buttons.allElementsBoundByIndex.last
        if let menuButton, menuButton.exists {
            menuButton.tap()
            sleep(2)
            capture("03-log-detail-menu")
            app.tap()
            sleep(1)
        }
        app.navigationBars.buttons.firstMatch.tap()
        sleep(2)
    }

    @MainActor
    private func closeSheet() {
        let close = app.navigationBars.buttons["close-sheet"]
        if close.waitForExistence(timeout: 5) {
            close.tap()
            sleep(2)
        }
    }

    @MainActor
    private func capture(_ name: String, screen: Bool = false) {
        let screenshot = screen ? XCUIScreen.main.screenshot() : app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
