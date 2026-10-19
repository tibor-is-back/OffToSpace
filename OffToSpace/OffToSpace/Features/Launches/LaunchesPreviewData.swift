import Foundation

enum LaunchesPreviewData {
    static func makeViewModel(content: LaunchesViewState.Content) -> LaunchesViewModel {
        LaunchesViewModel(
            interactor: PreviewLaunchesInteractor(),
            filter: LaunchFilter(startDate: rangeStart, endDate: rangeEnd),
            content: content
        )
    }

    static let rangeStart = Date(timeIntervalSince1970: 1_704_110_400)
    static let rangeEnd = Date(timeIntervalSince1970: 1_735_646_400)

    static let listItems = [successful, failed, upcoming, unknownWithoutImage]

    static let successful = LaunchesListItemViewData(
        id: "crew-8",
        name: "Crew-8",
        imageURL: URL(string: "https://picsum.photos/seed/crew8/200"),
        launchSite: "Kennedy Space Center, FL",
        date: Date(timeIntervalSince1970: 1_709_506_380).formatted(dateFormat),
        status: .successful
    )

    static let failed = LaunchesListItemViewData(
        id: "falcon-sat",
        name: "FalconSat",
        imageURL: URL(string: "https://picsum.photos/seed/falconsat/200"),
        launchSite: "Kwajalein Atoll",
        date: Date(timeIntervalSince1970: 1_143_235_800).formatted(dateFormat),
        status: .failed
    )

    static let upcoming = LaunchesListItemViewData(
        id: "starlink-10",
        name: "Starlink Group 10-1",
        imageURL: URL(string: "https://picsum.photos/seed/starlink/200"),
        launchSite: "Cape Canaveral, FL",
        date: Date(timeIntervalSince1970: 1_735_689_600).formatted(dateFormat),
        status: .upcoming
    )

    static let unknownWithoutImage = LaunchesListItemViewData(
        id: "unknown-1",
        name: "Unknown Mission",
        imageURL: nil,
        launchSite: "Unknown site",
        date: Date(timeIntervalSince1970: 1_600_000_000).formatted(dateFormat),
        status: .unknown
    )
    private static let dateFormat = Date.FormatStyle()
        .month(.abbreviated)
        .day(.defaultDigits)
        .year()
        .hour(.twoDigits(amPM: .omitted))
        .minute()
}

private final class PreviewLaunchesInteractor: LaunchesInteractor {
    var hasNextPage: Bool { false }

    func updateFilter(_ filter: LaunchFilter) {}

    func loadNextPage() async throws -> [Launch] {
        throw CancellationError()
    }
}
