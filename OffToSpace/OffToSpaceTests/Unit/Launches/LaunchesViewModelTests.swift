import Observation
import XCTest
@testable import OffToSpace

@MainActor
final class LaunchesViewModelTests: XCTestCase {
    private let filter = LaunchFilter(
        startDate: Date(timeIntervalSince1970: 1_700_000_000),
        endDate: Date(timeIntervalSince1970: 1_710_000_000)
    )

    func testLoadSuccessShowsMappedItems() async {
        // Given
        let interactor = ViewModelLaunchesInteractorMock()
        let viewModel = LaunchesViewModel(interactor: interactor, filter: filter)

        // When
        await request(.appeared, from: viewModel, using: interactor)
        await complete(.success(.init(launches: [launch("first")], hasNextPage: false)),
                       request: 0, viewModel: viewModel, interactor: interactor)
        viewModel.handle(event: .appeared)

        // Then
        guard case .loaded(let items, .finished) = viewModel.state.content else {
            return XCTFail("Expected loaded items with finished pagination")
        }
        XCTAssertEqual(items.map(\.id), ["first"])
        XCTAssertEqual(items.first?.name, "Mission first")
        XCTAssertEqual(items.first?.launchSite, "Launch site")
        XCTAssertFalse(items.first?.date.isEmpty ?? true)
        XCTAssertEqual(items.first?.status.style, .success)
        XCTAssertEqual(interactor.requestCount, 1)
    }

    func testPaginationAppendsItemsAndStopsAtLastPage() async {
        // Given
        let interactor = ViewModelLaunchesInteractorMock()
        let viewModel = LaunchesViewModel(interactor: interactor, filter: filter)
        await request(.appeared, from: viewModel, using: interactor)
        await complete(.success(.init(launches: [launch("first")], hasNextPage: true)),
                       request: 0, viewModel: viewModel, interactor: interactor)

        // When
        await request(.nextPageRequested, from: viewModel, using: interactor)
        viewModel.handle(event: .nextPageRequested)
        await complete(.success(.init(launches: [launch("second")], hasNextPage: false)),
                       request: 1, viewModel: viewModel, interactor: interactor)
        viewModel.handle(event: .nextPageRequested)

        // Then
        guard case .loaded(let items, .finished) = viewModel.state.content else {
            return XCTFail("Expected finished pagination")
        }
        XCTAssertEqual(items.map(\.id), ["first", "second"])
        XCTAssertEqual(interactor.requestCount, 2)
    }

    func testLoadFailureShowsErrorAndRetryRecovers() async {
        // Given
        let interactor = ViewModelLaunchesInteractorMock()
        let viewModel = LaunchesViewModel(interactor: interactor, filter: filter)
        await request(.appeared, from: viewModel, using: interactor)

        // When
        await complete(.failure(NetworkError.timeout), request: 0, viewModel: viewModel, interactor: interactor)

        // Then
        guard case .error = viewModel.state.content else {
            return XCTFail("Expected an error state")
        }

        // When
        await request(.retryTapped, from: viewModel, using: interactor)
        await complete(.success(.init(launches: [launch("retry")], hasNextPage: false)),
                       request: 1, viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let items, _) = viewModel.state.content else {
            return XCTFail("Expected retry to load items")
        }
        XCTAssertEqual(items.map(\.id), ["retry"])
    }

    func testPaginationFailurePreservesItems() async {
        // Given
        let interactor = ViewModelLaunchesInteractorMock()
        let viewModel = LaunchesViewModel(interactor: interactor, filter: filter)
        await request(.appeared, from: viewModel, using: interactor)
        await complete(.success(.init(launches: [launch("first")], hasNextPage: true)),
                       request: 0, viewModel: viewModel, interactor: interactor)

        // When
        await request(.nextPageRequested, from: viewModel, using: interactor)
        await complete(.failure(NetworkError.timeout), request: 1, viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let items, .error) = viewModel.state.content else {
            return XCTFail("Expected a pagination error with existing items")
        }
        XCTAssertEqual(items.map(\.id), ["first"])
    }

    func testFilterChangeDiscardsCancelledResults() async {
        // Given
        let interactor = ViewModelLaunchesInteractorMock()
        let viewModel = LaunchesViewModel(interactor: interactor, filter: filter)
        await request(.appeared, from: viewModel, using: interactor)
        let start = Date(timeIntervalSince1970: 1_720_000_000)
        let end = Date(timeIntervalSince1970: 1_730_000_000)

        // When
        await request(.dateRangeSelected(startDate: start, endDate: end), from: viewModel, using: interactor)
        interactor.complete(.success(.init(launches: [launch("stale")], hasNextPage: true)), request: 0)
        await complete(.success(.init(launches: [launch("filtered")], hasNextPage: false)),
                       request: 1, viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let items, .finished) = viewModel.state.content else {
            return XCTFail("Expected only the new filter's items")
        }
        XCTAssertEqual(items.map(\.id), ["filtered"])
        XCTAssertEqual(viewModel.state.filter, LaunchFilter(startDate: start, endDate: end))
        XCTAssertEqual(interactor.filters, [viewModel.state.filter])
    }

    func testEmptyLastPageShowsEmptyState() async {
        // Given
        let interactor = ViewModelLaunchesInteractorMock()
        let viewModel = LaunchesViewModel(interactor: interactor, filter: filter)

        // When
        await request(.appeared, from: viewModel, using: interactor)
        await complete(.success(.init(launches: [], hasNextPage: false)),
                       request: 0, viewModel: viewModel, interactor: interactor)

        // Then
        guard case .empty = viewModel.state.content else {
            return XCTFail("Expected an empty state")
        }
    }

    private func request(
        _ event: LaunchesViewEvent,
        from viewModel: LaunchesViewModel,
        using interactor: ViewModelLaunchesInteractorMock
    ) async {
        let requested = expectation(description: "Interactor request starts")
        interactor.onRequest = { requested.fulfill() }
        viewModel.handle(event: event)
        await fulfillment(of: [requested], timeout: 2)
        interactor.onRequest = nil
    }

    private func complete(
        _ result: Result<ViewModelLaunchesInteractorMock.Response, any Error>,
        request: Int,
        viewModel: LaunchesViewModel,
        interactor: ViewModelLaunchesInteractorMock
    ) async {
        let updated = expectation(description: "View state updates")
        withObservationTracking {
            _ = viewModel.state
        } onChange: {
            updated.fulfill()
        }
        interactor.complete(result, request: request)
        await fulfillment(of: [updated], timeout: 2)
    }

    private func launch(_ id: String) -> Launch {
        Launch(id: id, name: "Mission \(id)", details: nil, imageURL: nil, launchSite: "Launch site",
               launchSiteFullName: "Launch site full name", date: filter.startDate, status: .successful, webcastURL: nil,
               rocket: Launch.Rocket(id: "rocket", name: "Rocket", type: "rocket", imageURL: nil))
    }
}

@MainActor
private final class ViewModelLaunchesInteractorMock: LaunchesInteractor {
    struct Response {
        let launches: [Launch]
        let hasNextPage: Bool
    }

    var hasNextPage = true
    var onRequest: (() -> Void)?
    private(set) var requestCount = 0
    private(set) var filters: [LaunchFilter] = []
    private var requests: [Int: CheckedContinuation<Response, any Error>] = [:]

    func updateFilter(_ filter: LaunchFilter) {
        filters.append(filter)
        hasNextPage = true
    }

    func loadLaunch(id: String) throws -> Launch {
        throw LaunchDetailsError.notFound
    }

    func loadNextPage() async throws -> [Launch] {
        let index = requestCount
        requestCount += 1
        let response = try await withCheckedThrowingContinuation { continuation in
            requests[index] = continuation
            onRequest?()
        }
        if !Task.isCancelled {
            hasNextPage = response.hasNextPage
        }
        return response.launches
    }

    func complete(_ result: Result<Response, any Error>, request: Int) {
        requests.removeValue(forKey: request)?.resume(with: result)
    }
}
