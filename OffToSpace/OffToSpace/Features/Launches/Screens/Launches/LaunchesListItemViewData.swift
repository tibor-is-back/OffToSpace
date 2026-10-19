import Foundation

struct LaunchesListItemViewData {
    let id: String
    let name: String
    let imageURL: URL?
    let launchSite: String
    let date: String
    let status: Status

    enum Status {
        case upcoming
        case successful
        case failed
        case unknown

        var text: String {
            switch self {
            case .upcoming:
                String(localized: "launches.badge.upcoming")
            case .successful:
                String(localized: "launches.badge.successful")
            case .failed:
                String(localized: "launches.badge.failed")
            case .unknown:
                String(localized: "launches.badge.unknown")
            }
        }

        var style: BadgeView.Style {
            switch self {
            case .upcoming:
                .info
            case .successful:
                .success
            case .failed:
                .error
            case .unknown:
                .neutral
            }
        }
    }
}

extension LaunchesListItemViewData {
    init(launch: Launch) {
        id = launch.id
        name = launch.name
        imageURL = launch.imageURL
        launchSite = launch.launchSite
        date = launch.date.formatted(.dateTime.month(.abbreviated).day().year().hour().minute())
        switch launch.status {
        case .upcoming:
            status = .upcoming
        case .successful:
            status = .successful
        case .failed:
            status = .failed
        case .unknown:
            status = .unknown
        }
    }
}
