import XCTest
@testable import OffToSpace

@MainActor
final class UITestingRepositoriesTests: XCTestCase {
    func testLaunchPaginationReachesCrewMissionAndFinishes() async throws {
        // Given
        let repository = UITestingLaunchesRepository()
        let filter = LaunchFilter(startDate: UITestingData.launchDate, endDate: nil)
        let interactor = DefaultLaunchesInteractor(repository: repository, filter: filter)

        // When
        let first = try await interactor.loadNextPage()
        let hasSecondPage = interactor.hasNextPage
        let second = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(first.count, 10)
        XCTAssertTrue(hasSecondPage)
        XCTAssertEqual(second.map(\.id), ["polaris-dawn", "crew-8"])
        XCTAssertFalse(interactor.hasNextPage)
        XCTAssertEqual(Set((first + second).map(\.id)).count, 12)
    }

    func testLaunchFilterUsesInclusiveDateBoundaries() async throws {
        // Given
        let repository = UITestingLaunchesRepository()
        let date = UITestingData.launchDate

        // When
        let page = try await repository.fetchLaunches(page: 1, limit: 10, startDate: date, endDate: date)

        // Then
        XCTAssertEqual(page.items.map(\.id), ["starlink-6-40"])
        XCTAssertFalse(page.hasNextPage)
    }

    func testRocketDetailsUsesListDataAndBundledImageExists() async throws {
        // Given
        let repository = UITestingRocketsRepository()

        // When
        let page = try await repository.fetchRockets(page: 1, limit: 20)
        let rocket = try await repository.fetchRocket(id: "falcon-9")

        // Then
        XCTAssertEqual(page.items.count, 3)
        XCTAssertEqual(page.items.last, rocket)
        let imageURL = try XCTUnwrap(rocket.imageURL)
        XCTAssertTrue(imageURL.isFileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: imageURL.path))
    }
}
