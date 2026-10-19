import Synchronization
import XCTest
@testable import OffToSpace

@MainActor
final class DefaultLaunchesInteractorTests: XCTestCase {
    private let filter = LaunchFilter(
        startDate: Date(timeIntervalSince1970: 1_000_000_000),
        endDate: Date(timeIntervalSince1970: 1_100_000_000)
    )
    private let pageSize = 10

    func testHasNextPageBeforeAnyLoad() {
        // Given
        let repository = LaunchesRepositoryMock()
        let interactor = makeInteractor(repository: repository)

        // Then
        XCTAssertTrue(interactor.hasNextPage)
    }

    func testLoadFirstPageUsesFilterAndPageSize() async throws {
        // Given
        let launches = [makeLaunch(id: "launch-1"), makeLaunch(id: "launch-2")]
        let page = makePage(items: launches, page: 1, hasNextPage: true)
        let repository = LaunchesRepositoryMock(pages: page)
        let interactor = makeInteractor(repository: repository)

        // When
        let items = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(items, launches)
        XCTAssertTrue(interactor.hasNextPage)
        XCTAssertEqual(repository.fetchCalls, [
            .init(page: 1, limit: pageSize, startDate: filter.startDate, endDate: filter.endDate)
        ])
    }

    func testLoadNextPageRequestsFollowingPage() async throws {
        // Given
        let firstLaunches = [makeLaunch(id: "launch-1")]
        let secondLaunches = [makeLaunch(id: "launch-2")]
        let repository = LaunchesRepositoryMock(pages:
            makePage(items: firstLaunches, page: 1, hasNextPage: true),
            makePage(items: secondLaunches, page: 2, hasNextPage: true)
        )
        let interactor = makeInteractor(repository: repository)

        // When
        let firstItems = try await interactor.loadNextPage()
        let secondItems = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(firstItems, firstLaunches)
        XCTAssertEqual(secondItems, secondLaunches)
        XCTAssertEqual(repository.fetchCalls.map(\.page), [1, 2])
        XCTAssertTrue(interactor.hasNextPage)
    }

    func testLoadLastPageStopsPagination() async throws {
        // Given
        let lastLaunches = [makeLaunch(id: "launch-last")]
        let repository = LaunchesRepositoryMock(pages:
            makePage(items: lastLaunches, page: 1, totalPages: 1, hasNextPage: false)
        )
        let interactor = makeInteractor(repository: repository)

        // When
        let items = try await interactor.loadNextPage()
        let extraItems = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(items, lastLaunches)
        XCTAssertTrue(extraItems.isEmpty)
        XCTAssertFalse(interactor.hasNextPage)
        XCTAssertEqual(repository.fetchCalls.count, 1)
    }

    func testEmptyPageStillAdvancesPagination() async throws {
        // Given
        let nextLaunches = [makeLaunch(id: "launch-2")]
        let repository = LaunchesRepositoryMock(pages:
            makePage(items: [], page: 1, hasNextPage: true),
            makePage(items: nextLaunches, page: 2, hasNextPage: false)
        )
        let interactor = makeInteractor(repository: repository)

        // When
        let firstItems = try await interactor.loadNextPage()
        let secondItems = try await interactor.loadNextPage()

        // Then
        XCTAssertTrue(firstItems.isEmpty)
        XCTAssertEqual(secondItems, nextLaunches)
        XCTAssertEqual(repository.fetchCalls.map(\.page), [1, 2])
    }

    func testLoadNextPageForwardsNilEndDate() async throws {
        // Given
        let openEndedFilter = LaunchFilter(startDate: filter.startDate, endDate: nil)
        let repository = LaunchesRepositoryMock(pages: makePage(items: [makeLaunch()]))
        let interactor = DefaultLaunchesInteractor(
            repository: repository,
            filter: openEndedFilter,
            pageSize: pageSize
        )

        // When
        _ = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(repository.fetchCalls.first?.endDate, nil)
        XCTAssertEqual(repository.fetchCalls.first?.startDate, openEndedFilter.startDate)
    }

    func testUpdateFilterResetsPaginationAndAppliesNewDates() async throws {
        // Given
        let updatedFilter = LaunchFilter(
            startDate: Date(timeIntervalSince1970: 1_200_000_000),
            endDate: Date(timeIntervalSince1970: 1_300_000_000)
        )
        let repository = LaunchesRepositoryMock(pages:
            makePage(items: [makeLaunch(id: "launch-1")], page: 1, hasNextPage: true),
            makePage(items: [makeLaunch(id: "launch-2")], page: 1, hasNextPage: true)
        )
        let interactor = makeInteractor(repository: repository)
        _ = try await interactor.loadNextPage()

        // When
        interactor.updateFilter(updatedFilter)
        let items = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(items.map(\.id), ["launch-2"])
        XCTAssertTrue(interactor.hasNextPage)
        XCTAssertEqual(repository.fetchCalls.map(\.page), [1, 1])
        XCTAssertEqual(
            repository.fetchCalls.last,
            .init(
                page: 1,
                limit: pageSize,
                startDate: updatedFilter.startDate,
                endDate: updatedFilter.endDate
            )
        )
    }

    func testUpdateFilterRestoresPaginationAfterLastPage() async throws {
        // Given
        let repository = LaunchesRepositoryMock(pages:
            makePage(items: [makeLaunch(id: "launch-1")], page: 1, totalPages: 1, hasNextPage: false),
            makePage(items: [makeLaunch(id: "launch-2")], page: 1, hasNextPage: true)
        )
        let interactor = makeInteractor(repository: repository)
        _ = try await interactor.loadNextPage()
        XCTAssertFalse(interactor.hasNextPage)

        // When
        interactor.updateFilter(filter)

        // Then
        XCTAssertTrue(interactor.hasNextPage)

        let items = try await interactor.loadNextPage()
        XCTAssertEqual(items.map(\.id), ["launch-2"])
        XCTAssertEqual(repository.fetchCalls.map(\.page), [1, 1])
    }

    func testLoadNextPagePropagatesRepositoryError() async {
        // Given
        let repository = LaunchesRepositoryMock(throwing: .noConnection)
        let interactor = makeInteractor(repository: repository)

        // When
        let error = await loadError(from: interactor)

        // Then
        assertNetworkError(error, equals: .noConnection)
        XCTAssertTrue(interactor.hasNextPage)
    }

    func testFailedLoadDoesNotAdvancePagination() async throws {
        // Given
        let launches = [makeLaunch(id: "launch-1")]
        let repository = LaunchesRepositoryMock(results: [
            .failure(.timeout),
            .success(makePage(items: launches, page: 1, hasNextPage: true))
        ])
        let interactor = makeInteractor(repository: repository)

        // When
        let error = await loadError(from: interactor)
        let items = try await interactor.loadNextPage()

        // Then
        assertNetworkError(error, equals: .timeout)
        XCTAssertEqual(items, launches)
        XCTAssertEqual(repository.fetchCalls.map(\.page), [1, 1])
    }

    private func makeInteractor(repository: LaunchesRepositoryMock) -> DefaultLaunchesInteractor {
        DefaultLaunchesInteractor(repository: repository, filter: filter, pageSize: pageSize)
    }

    private func loadError(from interactor: DefaultLaunchesInteractor) async -> NetworkError? {
        do {
            _ = try await interactor.loadNextPage()
            return nil
        } catch let error as NetworkError {
            return error
        } catch {
            XCTFail("Unexpected error \(error)")
            return nil
        }
    }

    private func assertNetworkError(
        _ error: NetworkError?,
        equals expected: NetworkError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch (error, expected) {
        case (.noConnection, .noConnection),
             (.timeout, .timeout),
             (.invalidResponse, .invalidResponse),
             (.serverError, .serverError),
             (.decodingFailed, .decodingFailed):
            return
        default:
            XCTFail("Expected \(expected), got \(String(describing: error))", file: file, line: line)
        }
    }
}

nonisolated private final class LaunchesRepositoryMock: LaunchesRepository {
    struct FetchCall: Equatable, Sendable {
        let page: Int
        let limit: Int
        let startDate: Date
        let endDate: Date?
    }

    private let queuedResults: Mutex<[Result<Page<Launch>, NetworkError>]>
    private let recordedCalls: Mutex<[FetchCall]>

    init(results: [Result<Page<Launch>, NetworkError>] = []) {
        queuedResults = Mutex(results)
        recordedCalls = Mutex([])
    }

    convenience init(pages: Page<Launch>...) {
        self.init(results: pages.map { .success($0) })
    }

    convenience init(throwing error: NetworkError) {
        self.init(results: [.failure(error)])
    }

    var fetchCalls: [FetchCall] {
        recordedCalls.withLock { $0 }
    }

    @concurrent
    func fetchLaunches(
        page: Int,
        limit: Int,
        startDate: Date,
        endDate: Date?
    ) async throws -> Page<Launch> {
        recordedCalls.withLock {
            $0.append(FetchCall(page: page, limit: limit, startDate: startDate, endDate: endDate))
        }

        let result = queuedResults.withLock { results -> Result<Page<Launch>, NetworkError>? in
            guard !results.isEmpty else {
                return nil
            }
            return results.removeFirst()
        }

        guard let result else {
            throw NetworkError.invalidResponse
        }

        return try result.get()
    }
}

private func makeLaunch(id: String = "launch-1") -> Launch {
    Launch(
        id: id,
        name: "FalconSat",
        details: "Engine failure at 33 seconds.",
        imageURL: URL(string: "https://example.com/large.png"),
        launchSite: "Kwajalein Atoll Omelek Island",
        date: Date(timeIntervalSince1970: 1_143_235_800),
        status: .failed,
        webcastURL: URL(string: "https://example.com/watch"),
        rocket: Launch.Rocket(id: "rocket-1", name: "Falcon 1", type: "rocket")
    )
}

private func makePage(
    items: [Launch],
    page: Int = 1,
    totalPages: Int = 3,
    hasNextPage: Bool = true
) -> Page<Launch> {
    Page(items: items, page: page, totalPages: totalPages, hasNextPage: hasNextPage)
}
