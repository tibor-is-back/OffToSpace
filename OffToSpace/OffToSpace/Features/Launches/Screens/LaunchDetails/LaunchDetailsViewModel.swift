import Foundation
import Observation

@Observable
final class LaunchDetailsViewModel {
    private(set) var state: LaunchDetailsViewState

    private let launchID: String
    private let interactor: any LaunchesInteractor

    init(launchID: String, interactor: any LaunchesInteractor, state: LaunchDetailsViewState = .loading) {
        self.launchID = launchID
        self.interactor = interactor
        self.state = state
    }

    func handle(event: LaunchDetailsViewEvent) {
        switch event {
        case .appeared:
            guard case .loading = state else { return }
        case .retryTapped:
            break
        }
        do {
            let launch = try interactor.loadLaunch(id: launchID)
            state = .loaded(map(launch))
        } catch {
            state = .error
        }
    }

    private func map(_ launch: Launch) -> LaunchDetailsViewData {
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
