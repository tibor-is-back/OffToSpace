import Synchronization
import XCTest
@testable import OffToSpace

@MainActor
final class DefaultRocketsInteractorTests: XCTestCase {
    private let pageSize = 10

    func testHasNextPageBeforeAnyLoad() {
        // Given
        let repository = RocketsRepositoryMock()
        let interactor = makeInteractor(repository: repository)

        // Then
        XCTAssertTrue(interactor.hasNextPage)
    }

    func testLoadFirstPageUsesPageSize() async throws {
        // Given
        let rockets = [makeRocket(id: "rocket-1"), makeRocket(id: "rocket-2")]
        let page = makePage(items: rockets, page: 1, hasNextPage: true)
        let repository = RocketsRepositoryMock(pages: page)
        let interactor = makeInteractor(repository: repository)

        // When
        let items = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(items, rockets)
        XCTAssertTrue(interactor.hasNextPage)
        XCTAssertEqual(repository.fetchCalls, [
            .init(page: 1, limit: pageSize)
        ])
    }

    func testLoadNextPageRequestsFollowingPage() async throws {
        // Given
        let firstRockets = [makeRocket(id: "rocket-1")]
        let secondRockets = [makeRocket(id: "rocket-2")]
        let repository = RocketsRepositoryMock(pages:
            makePage(items: firstRockets, page: 1, hasNextPage: true),
            makePage(items: secondRockets, page: 2, hasNextPage: true)
        )
        let interactor = makeInteractor(repository: repository)

        // When
        let firstItems = try await interactor.loadNextPage()
        let secondItems = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(firstItems, firstRockets)
        XCTAssertEqual(secondItems, secondRockets)
        XCTAssertEqual(repository.fetchCalls.map(\.page), [1, 2])
        XCTAssertTrue(interactor.hasNextPage)
    }

    func testLoadLastPageStopsPagination() async throws {
        // Given
        let lastRockets = [makeRocket(id: "rocket-last")]
        let repository = RocketsRepositoryMock(pages:
            makePage(items: lastRockets, page: 1, totalPages: 1, hasNextPage: false)
        )
        let interactor = makeInteractor(repository: repository)

        // When
        let items = try await interactor.loadNextPage()
        let extraItems = try await interactor.loadNextPage()

        // Then
        XCTAssertEqual(items, lastRockets)
        XCTAssertTrue(extraItems.isEmpty)
        XCTAssertFalse(interactor.hasNextPage)
        XCTAssertEqual(repository.fetchCalls.count, 1)
    }

    func testEmptyPageStillAdvancesPagination() async throws {
        // Given
        let nextRockets = [makeRocket(id: "rocket-2")]
        let repository = RocketsRepositoryMock(pages:
            makePage(items: [], page: 1, hasNextPage: true),
            makePage(items: nextRockets, page: 2, hasNextPage: false)
        )
        let interactor = makeInteractor(repository: repository)

        // When
        let firstItems = try await interactor.loadNextPage()
        let secondItems = try await interactor.loadNextPage()

        // Then
        XCTAssertTrue(firstItems.isEmpty)
        XCTAssertEqual(secondItems, nextRockets)
        XCTAssertEqual(repository.fetchCalls.map(\.page), [1, 2])
    }

    func testLoadNextPagePropagatesRepositoryError() async {
        // Given
        let repository = RocketsRepositoryMock(throwing: .noConnection)
        let interactor = makeInteractor(repository: repository)

        // When
        let error = await loadError(from: interactor)

        // Then
        assertNetworkError(error, equals: .noConnection)
        XCTAssertTrue(interactor.hasNextPage)
    }

    func testFailedLoadDoesNotAdvancePagination() async throws {
        // Given
        let rockets = [makeRocket(id: "rocket-1")]
        let repository = RocketsRepositoryMock(results: [
            .failure(.timeout),
            .success(makePage(items: rockets, page: 1, hasNextPage: true))
        ])
        let interactor = makeInteractor(repository: repository)

        // When
        let error = await loadError(from: interactor)
        let items = try await interactor.loadNextPage()

        // Then
        assertNetworkError(error, equals: .timeout)
        XCTAssertEqual(items, rockets)
        XCTAssertEqual(repository.fetchCalls.map(\.page), [1, 1])
    }

    private func makeInteractor(repository: RocketsRepositoryMock) -> DefaultRocketsInteractor {
        DefaultRocketsInteractor(repository: repository, pageSize: pageSize)
    }

    private func loadError(from interactor: DefaultRocketsInteractor) async -> NetworkError? {
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

nonisolated private final class RocketsRepositoryMock: RocketsRepository {
    struct FetchCall: Equatable, Sendable {
        let page: Int
        let limit: Int
    }

    private let queuedResults: Mutex<[Result<Page<Rocket>, NetworkError>]>
    private let recordedCalls: Mutex<[FetchCall]>

    init(results: [Result<Page<Rocket>, NetworkError>] = []) {
        queuedResults = Mutex(results)
        recordedCalls = Mutex([])
    }

    convenience init(pages: Page<Rocket>...) {
        self.init(results: pages.map { .success($0) })
    }

    convenience init(throwing error: NetworkError) {
        self.init(results: [.failure(error)])
    }

    var fetchCalls: [FetchCall] {
        recordedCalls.withLock { $0 }
    }

    @concurrent
    func fetchRockets(page: Int, limit: Int) async throws -> Page<Rocket> {
        recordedCalls.withLock {
            $0.append(FetchCall(page: page, limit: limit))
        }

        let result = queuedResults.withLock { results -> Result<Page<Rocket>, NetworkError>? in
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

    @concurrent
    func fetchRocket(id: String) async throws -> Rocket {
        throw NetworkError.invalidResponse
    }
}

private func makeRocket(id: String = "rocket-1") -> Rocket {
    Rocket(
        id: id,
        name: "Falcon 1",
        type: "rocket",
        description: "The Falcon 1 was an expendable launch system.",
        imageURL: URL(string: "https://example.com/falcon-1-a.png"),
        successRatePercent: 40,
        isActive: false,
        engineCount: 1,
        engineType: "merlin"
    )
}

private func makePage(
    items: [Rocket],
    page: Int = 1,
    totalPages: Int = 2,
    hasNextPage: Bool = true
) -> Page<Rocket> {
    Page(items: items, page: page, totalPages: totalPages, hasNextPage: hasNextPage)
}
