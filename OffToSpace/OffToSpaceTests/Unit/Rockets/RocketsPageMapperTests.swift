import XCTest
@testable import OffToSpace

final class RocketsPageMapperTests: XCTestCase {
    func testMapsDocsAndPagination() {
        // Given
        let first = RocketDTOFixture.make(id: "rocket-1", name: "Falcon 1")
        let second = RocketDTOFixture.make(id: "rocket-2", name: "Falcon 9", active: true)
        let dto = RocketDTOFixture.query(
            docs: [first, second],
            page: 2,
            totalPages: 2,
            hasNextPage: false
        )

        // When
        let page = RocketsPageMapper.map(dto)

        // Then
        XCTAssertEqual(page.items, [RocketMapper.map(first), RocketMapper.map(second)])
        XCTAssertEqual(page.page, 2)
        XCTAssertEqual(page.totalPages, 2)
        XCTAssertFalse(page.hasNextPage)
    }

    func testMapsEmptyDocsToEmptyPage() {
        // Given
        let dto = RocketDTOFixture.query(
            docs: [],
            page: 1,
            totalPages: 1,
            hasNextPage: false
        )

        // When
        let page = RocketsPageMapper.map(dto)

        // Then
        XCTAssertTrue(page.items.isEmpty)
        XCTAssertEqual(page.page, 1)
        XCTAssertEqual(page.totalPages, 1)
        XCTAssertFalse(page.hasNextPage)
    }
}
