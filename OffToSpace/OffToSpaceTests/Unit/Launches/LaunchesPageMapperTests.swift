import XCTest
@testable import OffToSpace

final class LaunchesPageMapperTests: XCTestCase {
    func testMapsDocsAndPagination() {
        // Given
        let first = LaunchDTOFixture.make(id: "launch-1", name: "FalconSat")
        let second = LaunchDTOFixture.make(id: "launch-2", name: "DemoSat", success: true)
        let dto = LaunchDTOFixture.query(
            docs: [first, second],
            page: 2,
            totalPages: 5,
            hasNextPage: true
        )

        // When
        let page = LaunchesPageMapper.map(dto)

        // Then
        XCTAssertEqual(page.items, [LaunchMapper.map(first), LaunchMapper.map(second)])
        XCTAssertEqual(page.page, 2)
        XCTAssertEqual(page.totalPages, 5)
        XCTAssertTrue(page.hasNextPage)
    }

    func testMapsEmptyDocsToEmptyPage() {
        // Given
        let dto = LaunchDTOFixture.query(
            docs: [],
            page: 1,
            totalPages: 1,
            hasNextPage: false
        )

        // When
        let page = LaunchesPageMapper.map(dto)

        // Then
        XCTAssertTrue(page.items.isEmpty)
        XCTAssertEqual(page.page, 1)
        XCTAssertEqual(page.totalPages, 1)
        XCTAssertFalse(page.hasNextPage)
    }
}
