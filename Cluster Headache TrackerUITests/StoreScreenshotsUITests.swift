import XCTest

/// Takes the App Store screenshots from a local server holding the synthetic
/// `screenshots` account (never real data), as attachments of the result
/// bundle. `Scripts/store-screenshots.sh` runs it on each required device and
/// copies the images into `fastlane/screenshots/en-US`. Skipped unless the
/// runner gets a server and the account:
///
///     TEST_RUNNER_CHT_PREVIEW_URL=http://localhost:3078 \
///     TEST_RUNNER_CHT_DEMO_USERNAME=screenshots TEST_RUNNER_CHT_DEMO_PASSWORD=... \
///       xcodebuild test -only-testing:"Cluster Headache TrackerUITests/StoreScreenshotsUITests" ...
final class StoreScreenshotsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Light mode: an attack in progress, the logs, charts, treatment
    /// effectiveness, a new log and the timeline.
    @MainActor
    func testStoreScreenshots() throws {
        try launchSignedIn()

        app.open(URL(string: "clusterheadachetracker://current_attack")!)
        XCTAssertTrue(app.webViews.staticTexts["Attack in progress"].waitForExistence(timeout: 30))
        sleep(2)
        capture("1_current_attack")
        closeSheet()

        tab("Logs")
        sleep(3)
        scroll(2)
        capture("2_logs")

        tab("Charts")
        XCTAssertTrue(app.navigationBars["Charts"].waitForExistence(timeout: 30))
        sleep(8)
        scroll(4)
        capture("3_charts")
        scroll(3)
        capture("4_treatment")

        tab("New")
        XCTAssertTrue(app.webViews.staticTexts["Pain Intensity"].waitForExistence(timeout: 30))
        sleep(2)
        capture("5_new_log")
        closeSheet()

        tab("Logs")
        sleep(2)
        let timeline = app.webViews.links.matching(NSPredicate(format: "label CONTAINS %@", "Timeline")).firstMatch
        XCTAssertTrue(timeline.waitForExistence(timeout: 10), "No Timeline link")
        for _ in 0 ..< 6 where !timeline.isHittable {
            app.webViews.firstMatch.swipeDown()
            sleep(1)
        }
        timeline.tap()
        XCTAssertTrue(app.navigationBars["Timeline"].waitForExistence(timeout: 30))
        sleep(4)
        capture("6_timeline")
    }

    /// Run with the simulator in dark mode (`xcrun simctl ui <udid> appearance dark`).
    @MainActor
    func testDarkModeScreenshot() throws {
        try launchSignedIn()

        tab("Logs")
        sleep(4)
        capture("7_logs_dark")
    }

    @MainActor
    private func launchSignedIn() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let baseURL = environment["CHT_PREVIEW_URL"],
              let username = environment["CHT_DEMO_USERNAME"],
              let password = environment["CHT_DEMO_PASSWORD"]
        else {
            throw XCTSkip("Set CHT_PREVIEW_URL, CHT_DEMO_USERNAME and CHT_DEMO_PASSWORD to take store screenshots")
        }
        guard let host = URL(string: baseURL)?.host()?.lowercased(),
              host != "clusterheadachetracker.com", !host.hasSuffix(".clusterheadachetracker.com")
        else {
            throw XCTSkip("Store screenshots are taken from a local server with synthetic data, never production")
        }

        app = XCUIApplication()
        app.launchEnvironment["CLUSTER_HEADACHE_TRACKER_BASE_URL"] = baseURL
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        // A fresh install asks to sign in in a sheet once the first page
        // answers 401 (the logs' navigation bar is already there behind it);
        // a remembered session never shows the sheet.
        let signInSheet = app.navigationBars["Sign in to your account"]
        let signedIn = app.navigationBars["Headache Logs"]
        if signInSheet.waitForExistence(timeout: 45) {
            let usernameField = app.webViews.textFields.firstMatch
            XCTAssertTrue(usernameField.waitForExistence(timeout: 30))
            // Typing while the sign-in page still settles loses keystrokes.
            sleep(3)
            fill(usernameField, with: username)
            XCTAssertEqual(usernameField.value as? String, username, "The username didn't stick")
            let passwordField = app.webViews.secureTextFields.firstMatch
            passwordField.tap()
            passwordField.typeText(password)
            app.webViews.buttons["Sign in"].firstMatch.tap()
            XCTAssertTrue(signInSheet.waitForNonExistence(timeout: 60), "Didn't get past signing in")
        }

        XCTAssertTrue(signedIn.waitForExistence(timeout: 60), "No logs after signing in")
        sleep(5)
    }

    /// Types into a web field until it holds the text: a busy simulator drops keystrokes.
    @MainActor
    private func fill(_ field: XCUIElement, with text: String) {
        for _ in 0 ..< 3 {
            field.tap()
            let current = (field.value as? String) ?? ""
            if !current.isEmpty {
                field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
            }
            field.typeText(text)
            if field.value as? String == text { return }
            sleep(1)
        }
    }

    /// The tab bar shrinks to a single button while a page scrolls down on iOS 26
    /// and later; scroll back up until the tab is there again.
    @MainActor
    private func tab(_ title: String) {
        if !tabButton(title).exists {
            // Tapping the status bar scrolls the page back to the top.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01)).tap()
            sleep(2)
        }
        for _ in 0 ..< 8 where !tabButton(title).exists {
            let webView = app.webViews.firstMatch
            webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.35))
                .press(forDuration: 0.05, thenDragTo: webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75)))
            sleep(1)
        }
        tabButton(title).tap()
    }

    /// iPad's floating tab bar on iOS 26 and later isn't a tab bar to XCUITest,
    /// only buttons.
    @MainActor
    private func tabButton(_ title: String) -> XCUIElement {
        let inTabBar = app.tabBars.buttons[title]
        return inTabBar.exists ? inTabBar : app.buttons[title].firstMatch
    }

    /// Drags the page by whole steps from the same spot, so every run frames the same content.
    @MainActor
    private func scroll(_ steps: Int) {
        let webView = app.webViews.firstMatch
        for _ in 0 ..< steps {
            // Along the edge, so the drag never lands on a chart and raises its tooltip.
            let start = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.03, dy: 0.78))
            let end = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.03, dy: 0.29))
            start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.3)
            sleep(2)
        }
    }

    @MainActor
    private func closeSheet() {
        let close = app.navigationBars.buttons["close-sheet"]
        if close.waitForExistence(timeout: 5) {
            close.tap()
            sleep(2)
        }
    }

    /// The whole screen, status bar included, between two ticks of the attack timer.
    @MainActor
    private func capture(_ name: String) {
        let fraction = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 1)
        Thread.sleep(forTimeInterval: 1.55 - fraction)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
