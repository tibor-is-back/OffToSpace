import Observation
import XCTest
@testable import OffToSpace

@MainActor
final class RocketDetailsViewModelTests: XCTestCase {
    func testProvidedRocketMapsOnAppearanceWithoutInteractor() {
        // Given
        let rocket = makeRocket()
        let viewModel = RocketDetailsViewModel(rocket: rocket)

        // When
        viewModel.handle(event: .appeared)

        // Then
        guard case .loaded(let data) = viewModel.state else {
            return XCTFail("Expected supplied rocket to load synchronously")
        }
        XCTAssertEqual(data.name, rocket.name)
        XCTAssertEqual(data.imageURL, rocket.imageURL)
        XCTAssertEqual(data.description, rocket.description)
        XCTAssertEqual(data.engineType, rocket.engineType)
    }

    func testStartsLoading() {
        // Given
        let interactor = RocketDetailsInteractorMock()

        // When
        let viewModel = RocketDetailsViewModel(rocketID: "falcon-9", interactor: interactor)

        // Then
        guard case .loading = viewModel.state else {
            return XCTFail("Expected initial loading state")
        }
        XCTAssertTrue(interactor.requestedIDs.isEmpty)
    }

    func testAppearanceLoadsMappedDetailsWithoutDuplicateRequests() async {
        // Given
        let interactor = RocketDetailsInteractorMock()
        let viewModel = RocketDetailsViewModel(rocketID: "falcon-9", interactor: interactor)
        let rocket = makeRocket()

        // When
        await request(.appeared, viewModel: viewModel, interactor: interactor)
        viewModel.handle(event: .appeared)
        await complete(.success(rocket), viewModel: viewModel, interactor: interactor)
        viewModel.handle(event: .appeared)

        // Then
        guard case .loaded(let data) = viewModel.state else {
            return XCTFail("Expected loaded rocket details")
        }
        XCTAssertEqual(interactor.requestedIDs, ["falcon-9"])
        XCTAssertEqual(data.name, rocket.name)
        XCTAssertEqual(data.subtitle, String(localized: "rockets.details.subtitle"))
        XCTAssertEqual(data.imageURL, rocket.imageURL)
        XCTAssertEqual(data.type, rocket.type)
        XCTAssertEqual(data.description, rocket.description)
        XCTAssertEqual(data.engines, 9.formatted())
        XCTAssertEqual(data.engineType, rocket.engineType)
        XCTAssertEqual(data.successRate, 0.98.formatted(.percent.precision(.fractionLength(0))))
        guard case .active = data.status else {
            return XCTFail("Expected active status")
        }
    }

    func testFailureShowsErrorAndRetryRecovers() async {
        // Given
        let interactor = RocketDetailsInteractorMock()
        let viewModel = RocketDetailsViewModel(rocketID: "falcon-9", interactor: interactor)
        await request(.appeared, viewModel: viewModel, interactor: interactor)

        // When
        await complete(.failure(NetworkError.timeout), viewModel: viewModel, interactor: interactor)

        // Then
        guard case .error = viewModel.state else {
            return XCTFail("Expected error after failed loading")
        }

        // When
        await request(.retryTapped, viewModel: viewModel, interactor: interactor)
        guard case .loading = viewModel.state else {
            interactor.completion?.resume(throwing: CancellationError())
            return XCTFail("Expected loading while retrying")
        }
        await complete(.success(makeRocket()), viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let data) = viewModel.state else {
            return XCTFail("Expected retry to load details")
        }
        XCTAssertEqual(data.name, "Falcon 9")
        XCTAssertEqual(interactor.requestedIDs, ["falcon-9", "falcon-9"])
    }

    func testInactiveRocketWithoutImageLoadsDetails() async {
        // Given
        let interactor = RocketDetailsInteractorMock()
        let viewModel = RocketDetailsViewModel(rocketID: "falcon-9", interactor: interactor)

        // When
        await request(.appeared, viewModel: viewModel, interactor: interactor)
        await complete(.success(makeRocket(isActive: false, imageURL: nil)), viewModel: viewModel, interactor: interactor)

        // Then
        guard case .loaded(let data) = viewModel.state else {
            return XCTFail("Expected loaded details without an image")
        }
        XCTAssertNil(data.imageURL)
        guard case .inactive = data.status else {
            return XCTFail("Expected inactive status")
        }
    }

    private func request(
        _ event: RocketDetailsViewEvent,
        viewModel: RocketDetailsViewModel,
        interactor: RocketDetailsInteractorMock
    ) async {
        let requested = expectation(description: "Rocket request starts")
        interactor.onRequest = { requested.fulfill() }
        viewModel.handle(event: event)
        await fulfillment(of: [requested], timeout: 2)
        interactor.onRequest = nil
    }

    private func complete(
        _ result: Result<Rocket, any Error>,
        viewModel: RocketDetailsViewModel,
        interactor: RocketDetailsInteractorMock
    ) async {
        let updated = expectation(description: "Rocket state updates")
        withObservationTracking {
            _ = viewModel.state
        } onChange: {
            updated.fulfill()
        }
        interactor.completion?.resume(with: result)
        interactor.completion = nil
        await fulfillment(of: [updated], timeout: 2)
    }

    private func makeRocket(
        isActive: Bool = true,
        imageURL: URL? = URL(string: "https://example.com/rocket.png")
    ) -> Rocket {
        Rocket(id: "falcon-9", name: "Falcon 9", type: "rocket", description: "Reusable orbital launch vehicle",
               imageURL: imageURL, successRatePercent: 98, isActive: isActive, engineCount: 9, engineType: "Merlin 1D")
    }
}

@MainActor
private final class RocketDetailsInteractorMock: RocketsInteractor {
    var hasNextPage: Bool { false }
    var onRequest: (() -> Void)?
    var completion: CheckedContinuation<Rocket, any Error>?
    private(set) var requestedIDs: [String] = []

    func loadNextPage() async throws -> [Rocket] {
        XCTFail("Rocket details must not load a list page")
        return []
    }

    func loadRocket(id: String) async throws -> Rocket {
        requestedIDs.append(id)
        return try await withCheckedThrowingContinuation { continuation in
            completion = continuation
            onRequest?()
        }
    }
}
