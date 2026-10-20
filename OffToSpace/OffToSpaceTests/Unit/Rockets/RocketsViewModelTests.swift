import Observation
import XCTest
@testable import OffToSpace

@MainActor
final class RocketsViewModelTests: XCTestCase {
    func testAppearanceLoadsMappedItemsWithoutDuplicateRequests() async {
        // Given
        let interactor = RocketsViewModelInteractorMock()
        let viewModel = RocketsViewModel(interactor: interactor)
        let rocket = makeRocket("first")
        guard case .loading = viewModel.state else {
            return XCTFail("Expected initial loading state")
        }
        XCTAssertEqual(interactor.requestCount, 0)

        // When
        await request(.appeared, viewModel: viewModel, interactor: interactor)
        viewModel.handle(event: .appeared)
        await complete(.success([rocket]), hasNextPage: false, viewModel: viewModel, interactor: interactor)
        viewModel.handle(event: .appeared)

        // Then
        guard case .loaded(let items, .finished) = viewModel.state else {
            return XCTFail("Expected loaded items with finished pagination")
        }
        XCTAssertEqual(interactor.requestCount, 1)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.id, rocket.id)
        XCTAssertEqual(items.first?.name, rocket.name)
        XCTAssertEqual(items.first?.subtitle, rocket.type)
        XCTAssertEqual(items.first?.imageURL, rocket.imageURL)
        XCTAssertEqual(items.first?.successRate, 0.98.formatted(.percent.precision(.fractionLength(0))))

    }

    func testPaginationAppendsItemsAndStopsAtLastPage() async {
        // Given
        let interactor = RocketsViewModelInteractorMock()
        let viewModel = RocketsViewModel(interactor: interactor)
        await request(.appeared, viewModel: viewModel, interactor: interactor)
        await complete(.success([makeRocket("first")]), viewModel: viewModel, interactor: interactor)

        // When
        await request(.nextPageRequested, viewModel: viewModel, interactor: interactor)
        viewModel.handle(event: .nextPageRequested)
        guard case .loaded(let existing, .loading) = viewModel.state else {
            interactor.completion?.resume(throwing: CancellationError())
            return XCTFail("Expected existing items during pagination")
        }
        XCTAssertEqual(existing.map(\.id), ["first"])
        await complete(.success([makeRocket("second")]), hasNextPage: false, viewModel: viewModel, interactor: interactor)
        viewModel.handle(event: .nextPageRequested)

        // Then
        guard case .loaded(let items, .finished) = viewModel.state else {
            return XCTFail("Expected finished pagination")
        }
        XCTAssertEqual(items.map(\.id), ["first", "second"])
        XCTAssertEqual(interactor.requestCount, 2)
    }

    func testEmptyPageContinuesUntilPaginationFinishes() async {
        // Given
        let interactor = RocketsViewModelInteractorMock()
        let viewModel = RocketsViewModel(interactor: interactor)

        // When
        await request(.appeared, viewModel: viewModel, interactor: interactor)
        await complete(.success([]), viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let items, .idle) = viewModel.state else {
            return XCTFail("Expected pagination to remain available after an empty intermediate page")
        }
        XCTAssertTrue(items.isEmpty)

        // When
        await request(.nextPageRequested, viewModel: viewModel, interactor: interactor)
        await complete(.success([]), hasNextPage: false, viewModel: viewModel, interactor: interactor)

        // Then
        guard case .empty = viewModel.state else {
            return XCTFail("Expected empty state after the last empty page")
        }
    }

    func testLoadFailureShowsErrorAndRetryRecovers() async {
        // Given
        let interactor = RocketsViewModelInteractorMock()
        let viewModel = RocketsViewModel(interactor: interactor)
        await request(.appeared, viewModel: viewModel, interactor: interactor)

        // When
        await complete(.failure(NetworkError.timeout), viewModel: viewModel, interactor: interactor)

        // Then
        guard case .error = viewModel.state else {
            return XCTFail("Expected initial load failure to show an error")
        }

        // When
        await request(.retryTapped, viewModel: viewModel, interactor: interactor)
        await complete(.success([makeRocket("retry")]), hasNextPage: false, viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let items, _) = viewModel.state else {
            return XCTFail("Expected retry to load items")
        }
        XCTAssertEqual(items.map(\.id), ["retry"])
    }

    func testPaginationFailurePreservesItemsAndRetryAppends() async {
        // Given
        let interactor = RocketsViewModelInteractorMock()
        let viewModel = RocketsViewModel(interactor: interactor)
        await request(.appeared, viewModel: viewModel, interactor: interactor)
        await complete(.success([makeRocket("first")]), viewModel: viewModel, interactor: interactor)

        // When
        await request(.nextPageRequested, viewModel: viewModel, interactor: interactor)
        await complete(.failure(NetworkError.timeout), viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let existing, .error) = viewModel.state else {
            return XCTFail("Expected pagination failure to preserve existing items")
        }
        XCTAssertEqual(existing.map(\.id), ["first"])

        // When
        await request(.retryTapped, viewModel: viewModel, interactor: interactor)
        await complete(.success([makeRocket("second")]), hasNextPage: false, viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let items, .finished) = viewModel.state else {
            return XCTFail("Expected retry to finish pagination")
        }
        XCTAssertEqual(items.map(\.id), ["first", "second"])
    }

    private func request(
        _ event: RocketsViewEvent,
        viewModel: RocketsViewModel,
        interactor: RocketsViewModelInteractorMock
    ) async {
        let requested = expectation(description: "Page request starts")
        interactor.onRequest = { requested.fulfill() }
        viewModel.handle(event: event)
        await fulfillment(of: [requested], timeout: 2)
        interactor.onRequest = nil
    }

    private func complete(
        _ result: Result<[Rocket], any Error>,
        hasNextPage: Bool = true,
        viewModel: RocketsViewModel,
        interactor: RocketsViewModelInteractorMock
    ) async {
        let updated = expectation(description: "List state updates")
        withObservationTracking {
            _ = viewModel.state
        } onChange: {
            updated.fulfill()
        }
        interactor.hasNextPage = hasNextPage
        interactor.completion?.resume(with: result)
        interactor.completion = nil
        await fulfillment(of: [updated], timeout: 2)
    }

    private func makeRocket(_ id: String) -> Rocket {
        Rocket(id: id, name: "Rocket \(id)", type: "Orbital launch vehicle", description: "Reusable rocket",
               imageURL: URL(string: "https://example.com/rocket.png"), successRatePercent: 98,
               isActive: true, engineCount: 9, engineType: "Merlin")
    }
}

@MainActor
private final class RocketsViewModelInteractorMock: RocketsInteractor {
    var hasNextPage = true
    var onRequest: (() -> Void)?
    var completion: CheckedContinuation<[Rocket], any Error>?
    private(set) var requestCount = 0

    func loadNextPage() async throws -> [Rocket] {
        requestCount += 1
        return try await withCheckedThrowingContinuation { continuation in
            completion = continuation
            onRequest?()
        }
    }

    func loadRocket(id: String) async throws -> Rocket {
        XCTFail("The rockets list must not request rocket details")
        throw NetworkError.invalidResponse
    }
}
