import XCTest

@MainActor
final class OffToSpaceUITests: XCTestCase {
    private let timeout: TimeInterval = 5

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchesNavigatesThroughDetailsToRocketDetails() {
        // Given
        let app = launchApp()
        let list = app.scrollViews["launches.list"]
        XCTAssertTrue(list.waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["launches.launch.starlink-6-40"].exists)

        // When: scroll through the first page to a mission on the second page.
        let launch = app.buttons["launches.launch.crew-8"]
        scrollTo(launch, in: list)
        launch.tap()

        // Then
        let details = app.scrollViews["launchDetails.screen"]
        XCTAssertTrue(details.waitForExistence(timeout: timeout))
        XCTAssertTrue(details.staticTexts["Crew-8"].exists)
        XCTAssertTrue(details.staticTexts["Kennedy Space Center Launch Complex 39A"].exists)

        // When
        let rocket = app.buttons["launchDetails.rocket"]
        scrollTo(rocket, in: details)
        rocket.tap()

        // Then
        assertRocketDetails(in: app)
    }

    func testRocketsNavigatesToRocketDetails() {
        // Given
        let app = launchApp()

        // When
        let rocketsTab = app.buttons["root.rocketsTab"]
        XCTAssertTrue(rocketsTab.waitForExistence(timeout: timeout), app.debugDescription)
        rocketsTab.tap()
        let list = app.scrollViews["rockets.list"]
        XCTAssertTrue(list.waitForExistence(timeout: timeout))

        // Then
        XCTAssertTrue(app.buttons["rockets.rocket.falcon-1"].exists)

        // When
        let rocket = app.buttons["rockets.rocket.falcon-9"]
        scrollTo(rocket, in: list)
        rocket.tap()

        // Then
        assertRocketDetails(in: app)
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["uiTesting", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        return app
    }

    private func scrollTo(
        _ element: XCUIElement,
        in scrollView: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for _ in 0..<20 {
            if element.exists && element.isHittable {
                return
            }
            scrollView.swipeUp()
        }
        XCTAssertTrue(element.waitForExistence(timeout: timeout), file: file, line: line)
        let hittable = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [hittable], timeout: timeout), .completed, file: file, line: line)
    }

    private func assertRocketDetails(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let screen = app.scrollViews["rocketDetails.screen"]
        XCTAssertTrue(screen.waitForExistence(timeout: timeout), file: file, line: line)
        XCTAssertTrue(screen.staticTexts["Falcon 9"].waitForExistence(timeout: timeout), file: file, line: line)
        let description = screen.staticTexts["A reusable two-stage rocket."]
        scrollTo(description, in: screen, file: file, line: line)
        XCTAssertTrue(description.exists, file: file, line: line)
    }
}
