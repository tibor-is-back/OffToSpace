import UIKit
import XCTest

final class OffToSpaceAccessibilityTests: XCTestCase {
    private let timeout: TimeInterval = 5
    private let maximumScrollAttempts = 20

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainScreensPassAccessibilityAudit() throws {
        // Given
        let app = launchApp()
        let launches = app.scrollViews["launches.list"]
        XCTAssertTrue(launches.waitForExistence(timeout: timeout))

        // When / Then: audit loaded content at each navigation destination.
        try app.performAccessibilityAudit()
        let launchDetails = openLaunchDetails(in: app)
        try app.performAccessibilityAudit()
        openLaunchRocket(in: app, details: launchDetails)
        try app.performAccessibilityAudit()

        // Given: reset navigation before testing the other tab.
        app.terminate()
        app.launch()

        // When / Then
        let rockets = openRockets(in: app)
        try app.performAccessibilityAudit()
        openListRocket(in: app, list: rockets)
        try app.performAccessibilityAudit()
    }

    @MainActor
    func testBothNavigationFlowsRemainUsableAtLargestAccessibilityTextSize() {
        // Given
        let app = launchApp(contentSize: .accessibilityExtraExtraExtraLarge)
        XCTAssertTrue(app.scrollViews["launches.list"].waitForExistence(timeout: timeout))

        // When
        let details = openLaunchDetails(in: app)
        openLaunchRocket(in: app, details: details)

        // Then
        assertRocketDescriptionIsReachable(in: app)

        // Given: retain the same text size with a fresh navigation stack.
        app.terminate()
        app.launch()

        // When
        let rockets = openRockets(in: app)
        openListRocket(in: app, list: rockets)

        // Then
        assertRocketDescriptionIsReachable(in: app)
    }

    @MainActor
    private func launchApp(contentSize: UIContentSizeCategory? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "uiTesting", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"
        ]
        if let contentSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSize.rawValue]
        }
        app.launch()
        return app
    }

    @MainActor
    private func openLaunchDetails(in app: XCUIApplication) -> XCUIElement {
        let mission = app.buttons["launches.launch.starlink-6-40"]
        XCTAssertTrue(mission.waitForExistence(timeout: timeout))
        mission.tap()
        let details = app.scrollViews["launchDetails.screen"]
        XCTAssertTrue(details.waitForExistence(timeout: timeout))
        XCTAssertTrue(details.staticTexts["Starlink Group 6-40"].exists)
        return details
    }

    @MainActor
    private func openLaunchRocket(in app: XCUIApplication, details: XCUIElement) {
        let rocket = app.buttons["launchDetails.rocket"]
        scrollTo(rocket, in: details)
        rocket.tap()
        assertRocketLoaded(in: app)
    }

    @MainActor
    private func openRockets(in app: XCUIApplication) -> XCUIElement {
        let tab = app.buttons["root.rocketsTab"]
        XCTAssertTrue(tab.waitForExistence(timeout: timeout))
        tab.tap()
        let list = app.scrollViews["rockets.list"]
        XCTAssertTrue(list.waitForExistence(timeout: timeout))
        return list
    }

    @MainActor
    private func openListRocket(in app: XCUIApplication, list: XCUIElement) {
        let rocket = app.buttons["rockets.rocket.falcon-9"]
        scrollTo(rocket, in: list)
        rocket.tap()
        assertRocketLoaded(in: app)
    }

    @MainActor
    private func assertRocketLoaded(in app: XCUIApplication) {
        let screen = app.scrollViews["rocketDetails.screen"]
        XCTAssertTrue(screen.waitForExistence(timeout: timeout))
        XCTAssertTrue(screen.staticTexts["Falcon 9"].waitForExistence(timeout: timeout))
    }

    @MainActor
    private func assertRocketDescriptionIsReachable(in app: XCUIApplication) {
        let screen = app.scrollViews["rocketDetails.screen"]
        let description = screen.staticTexts["A reusable two-stage rocket."]
        scrollTo(description, in: screen)
        XCTAssertTrue(description.isHittable)
    }

    @MainActor
    private func scrollTo(
        _ element: XCUIElement,
        in scrollView: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for _ in 0..<maximumScrollAttempts {
            if element.exists && element.isHittable {
                return
            }
            scrollView.swipeUp()
        }
        XCTFail("Element is not reachable after scrolling: \(element)", file: file, line: line)
    }
}
