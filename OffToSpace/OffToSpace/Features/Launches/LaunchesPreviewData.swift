import Foundation

enum LaunchesPreviewData {
    static let detailsLaunch = Launch(
        id: "crew-8",
        name: "Crew-8",
        details: "Crew-8 carried four astronauts to the International Space Station for scientific research and maintenance.",
        imageURL: URL(string: "https://picsum.photos/seed/crew8/800"),
        launchSite: "KSC LC-39A",
        launchSiteFullName: "Kennedy Space Center Historic Launch Complex 39A",
        date: Date(timeIntervalSince1970: 1_709_506_380),
        status: .successful,
        webcastURL: URL(string: "https://example.com/watch"),
        rocket: .init(
            id: "falcon-9",
            name: "Falcon 9",
            type: "Block 5",
            imageURL: URL(string: "https://picsum.photos/seed/falcon9/800")
        )
    )

    static let minimalDetailsLaunch = Launch(
        id: "starlink-10",
        name: "Starlink Group 10-1",
        details: nil,
        imageURL: nil,
        launchSite: "CCSFS SLC-40",
        launchSiteFullName: "Cape Canaveral Space Force Station Space Launch Complex 40",
        date: Date(timeIntervalSince1970: 1_735_689_600),
        status: .upcoming,
        webcastURL: nil,
        rocket: .init(id: "falcon-9", name: "Falcon 9", type: "rocket", imageURL: nil)
    )

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
