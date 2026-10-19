import XCTest
@testable import OffToSpace

final class LaunchMapperTests: XCTestCase {
    func testMapsLaunchFieldsFromDTO() throws {
        // Given
        let dto = LaunchDTOFixture.make()

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertEqual(launch.id, "launch-1")
        XCTAssertEqual(launch.name, "FalconSat")
        XCTAssertEqual(launch.details, "Engine failure at 33 seconds.")
        XCTAssertEqual(launch.imageURL, try XCTUnwrap(URL(string: "https://example.com/large.png")))
        XCTAssertEqual(launch.launchSite, "Kwajalein Atoll")
        XCTAssertEqual(launch.launchSiteFullName, "Kwajalein Atoll Omelek Island")
        XCTAssertEqual(launch.date, LaunchDTOFixture.date)
        XCTAssertEqual(launch.status, .failed)
        XCTAssertEqual(launch.webcastURL, try XCTUnwrap(URL(string: "https://example.com/watch")))
        XCTAssertEqual(launch.rocket, Launch.Rocket(id: "rocket-1", name: "Falcon 1", type: "rocket"))
    }

    func testPrefersLargePatchImage() {
        // Given
        let dto = LaunchDTOFixture.make(
            largePatch: "https://example.com/large.png",
            smallPatch: "https://example.com/small.png"
        )

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertEqual(launch.imageURL?.absoluteString, "https://example.com/large.png")
    }

    func testFallsBackToSmallPatchImage() {
        // Given
        let dto = LaunchDTOFixture.make(largePatch: nil, smallPatch: "https://example.com/small.png")

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertEqual(launch.imageURL?.absoluteString, "https://example.com/small.png")
    }

    func testOmitsImageWhenPatchURLsAreInvalid() {
        // Given
        let dto = LaunchDTOFixture.make(largePatch: "", smallPatch: "")

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertNil(launch.imageURL)
    }

    func testOmitsWebcastWhenURLIsInvalid() {
        // Given
        let dto = LaunchDTOFixture.make(webcast: "")

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertNil(launch.webcastURL)
    }

    func testMapsUpcomingStatus() {
        // Given
        let dto = LaunchDTOFixture.make(upcoming: true, success: nil)

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertEqual(launch.status, .upcoming)
    }

    func testUpcomingStatusOverridesSuccess() {
        // Given
        let dto = LaunchDTOFixture.make(upcoming: true, success: true)

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertEqual(launch.status, .upcoming)
    }

    func testMapsSuccessfulStatus() {
        // Given
        let dto = LaunchDTOFixture.make(upcoming: false, success: true)

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertEqual(launch.status, .successful)
    }

    func testMapsFailedStatus() {
        // Given
        let dto = LaunchDTOFixture.make(upcoming: false, success: false)

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertEqual(launch.status, .failed)
    }

    func testMapsUnknownStatusWhenSuccessIsMissing() {
        // Given
        let dto = LaunchDTOFixture.make(upcoming: false, success: nil)

        // When
        let launch = LaunchMapper.map(dto)

        // Then
        XCTAssertEqual(launch.status, .unknown)
    }
}
