import XCTest
@testable import OffToSpace

final class RocketMapperTests: XCTestCase {
    func testMapsRocketFieldsFromDTO() throws {
        // Given
        let dto = RocketDTOFixture.make()

        // When
        let rocket = RocketMapper.map(dto)

        // Then
        XCTAssertEqual(rocket.id, "rocket-1")
        XCTAssertEqual(rocket.name, "Falcon 1")
        XCTAssertEqual(rocket.type, "rocket")
        XCTAssertEqual(rocket.description, "The Falcon 1 was an expendable launch system.")
        XCTAssertEqual(rocket.imageURL, try XCTUnwrap(URL(string: "https://example.com/falcon-1-a.png")))
        XCTAssertEqual(rocket.successRatePercent, 40)
        XCTAssertFalse(rocket.isActive)
        XCTAssertEqual(rocket.engineCount, 1)
        XCTAssertEqual(rocket.engineType, "merlin")
    }

    func testUsesFirstValidImage() {
        // Given
        let dto = RocketDTOFixture.make(
            flickrImages: ["", "https://example.com/valid.png"]
        )

        // When
        let rocket = RocketMapper.map(dto)

        // Then
        XCTAssertEqual(rocket.imageURL?.absoluteString, "https://example.com/valid.png")
    }

    func testOmitsImageWhenURLsAreInvalid() {
        // Given
        let dto = RocketDTOFixture.make(flickrImages: [""])

        // When
        let rocket = RocketMapper.map(dto)

        // Then
        XCTAssertNil(rocket.imageURL)
    }
}
