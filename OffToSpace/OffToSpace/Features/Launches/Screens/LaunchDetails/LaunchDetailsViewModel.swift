import Foundation
import Observation

enum LaunchDetailsViewState {
    case loading
    case loaded(LaunchDetailsViewData)
}

@Observable
final class LaunchDetailsViewModel {
    private(set) var state: LaunchDetailsViewState = .loading

    private let launch: Launch

    init(launch: Launch) {
        self.launch = launch
    }

    func handle(event: LaunchDetailsViewEvent) {
        switch event {
        case .appeared:
            state = .loaded(map())
        case .rocketSelected:
            break
        }
    }

    private func map() -> LaunchDetailsViewData {
        let status: (text: String, style: BadgeView.Style) = switch launch.status {
        case .upcoming:
            (String(localized: "launches.badge.upcoming"), .info)
        case .successful:
            (String(localized: "launches.badge.successful"), .success)
        case .failed:
            (String(localized: "launches.badge.failed"), .error)
        case .unknown:
            (String(localized: "launches.badge.unknown"), .neutral)
        }

        return LaunchDetailsViewData(
            name: launch.name,
            subtitle: nil,
            imageURL: launch.imageURL,
            statusText: status.text,
            statusStyle: status.style,
            date: launch.date.formatted(.dateTime.month(.wide).day().year().hour().minute().timeZone()),
            location: launch.launchSiteFullName,
            description: launch.details,
            webcastURL: launch.webcastURL,
            rocket: .init(
                id: launch.rocket.id,
                name: launch.rocket.name,
                type: launch.rocket.type,
                imageURL: launch.rocket.imageURL
            )
        )
    }
}
