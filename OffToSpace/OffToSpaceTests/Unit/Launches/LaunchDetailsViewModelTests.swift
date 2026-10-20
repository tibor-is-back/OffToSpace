import XCTest
@testable import OffToSpace

@MainActor
final class LaunchDetailsViewModelTests: XCTestCase {
    func testStartsLoading() {
        // Given
        let launch = makeLaunch()

        // When
        let viewModel = makeViewModel(launch: launch)

        // Then
        guard case .loading = viewModel.state else {
            return XCTFail("Expected loading before appearance")
        }
    }

    func testAppearanceMapsLaunchDetails() {
        // Given
        let launch = makeLaunch()
        let viewModel = makeViewModel(launch: launch)

        // When
        viewModel.handle(event: .appeared)

        // Then
        guard case .loaded(let data) = viewModel.state else {
            return XCTFail("Expected loaded details")
        }
        XCTAssertEqual(data.name, launch.name)
        XCTAssertEqual(data.imageURL, launch.imageURL)
        XCTAssertEqual(data.location, launch.launchSiteFullName)
        XCTAssertEqual(data.description, launch.details)
        XCTAssertEqual(data.webcastURL, launch.webcastURL)
        XCTAssertNil(data.subtitle)
        XCTAssertEqual(data.date, launch.date.formatted(.dateTime.month(.wide).day().year().hour().minute().timeZone()))
        XCTAssertEqual(data.rocket.id, launch.rocket.id)
        XCTAssertEqual(data.rocket.name, launch.rocket.name)
        XCTAssertEqual(data.rocket.type, launch.rocket.type)
        XCTAssertEqual(data.rocket.imageURL, launch.rocket.imageURL)
    }

    func testMissingOptionalDetailsRemainAbsent() {
        // Given
        let viewModel = makeViewModel(launch: makeLaunch(hasOptionalDetails: false))

        // When
        viewModel.handle(event: .appeared)

        // Then
        guard case .loaded(let data) = viewModel.state else {
            return XCTFail("Expected loaded details without optional content")
        }
        XCTAssertNil(data.imageURL)
        XCTAssertNil(data.description)
        XCTAssertNil(data.webcastURL)
        XCTAssertNil(data.rocket.imageURL)
    }

    func testAppearanceMapsEveryStatusToBadgeTextAndStyle() {
        // Given
        let cases: [Launch.Status: (text: String, style: BadgeView.Style)] = [
            .upcoming: (String(localized: "launches.badge.upcoming"), .info),
            .successful: (String(localized: "launches.badge.successful"), .success),
            .failed: (String(localized: "launches.badge.failed"), .error),
            .unknown: (String(localized: "launches.badge.unknown"), .neutral)
        ]

        for (status, expected) in cases {
            let viewModel = makeViewModel(launch: makeLaunch(status: status))

            // When
            viewModel.handle(event: .appeared)

            // Then
            guard case .loaded(let data) = viewModel.state else {
                return XCTFail("Expected loaded details for \(status)")
            }
            XCTAssertEqual(data.statusText, expected.text)
            XCTAssertEqual(data.statusStyle, expected.style)
        }
    }

    func testCacheMissShowsErrorAndRetryRecovers() {
        // Given
        let interactor = LaunchDetailsInteractorStub(launch: nil)
        let viewModel = LaunchDetailsViewModel(launchID: "crew-8", interactor: interactor)

        // When
        viewModel.handle(event: .appeared)

        // Then
        guard case .error = viewModel.state else {
            return XCTFail("Expected an error for a missing launch")
        }

        // When
        interactor.launch = makeLaunch()
        viewModel.handle(event: .retryTapped)

        // Then
        guard case .loaded(let data) = viewModel.state else {
            return XCTFail("Expected retry to load the launch")
        }
        XCTAssertEqual(data.name, "Crew-8")
    }

    private func makeViewModel(launch: Launch) -> LaunchDetailsViewModel {
        LaunchDetailsViewModel(launchID: launch.id, interactor: LaunchDetailsInteractorStub(launch: launch))
    }

    private func makeLaunch(status: Launch.Status = .successful, hasOptionalDetails: Bool = true) -> Launch {
        Launch(
            id: "crew-8",
            name: "Crew-8",
            details: hasOptionalDetails ? "Crew rotation mission" : nil,
            imageURL: hasOptionalDetails ? URL(string: "https://example.com/launch.png") : nil,
            launchSite: "KSC LC-39A",
            launchSiteFullName: "Kennedy Space Center Historic Launch Complex 39A",
            date: Date(timeIntervalSince1970: 1_709_506_380),
            status: status,
            webcastURL: hasOptionalDetails ? URL(string: "https://example.com/watch") : nil,
            rocket: .init(id: "falcon-9", name: "Falcon 9", type: "rocket",
                          imageURL: hasOptionalDetails ? URL(string: "https://example.com/rocket.png") : nil)
        )
    }
}

@MainActor
private final class LaunchDetailsInteractorStub: LaunchesInteractor {
    var launch: Launch?

    init(launch: Launch?) {
        self.launch = launch
    }

    var hasNextPage: Bool { false }
    func updateFilter(_ filter: LaunchFilter) {}
    func loadNextPage() async throws -> [Launch] { [] }

    func loadLaunch(id: String) throws -> Launch {
        guard let launch, launch.id == id else { throw LaunchDetailsError.notFound }
        return launch
    }
}
