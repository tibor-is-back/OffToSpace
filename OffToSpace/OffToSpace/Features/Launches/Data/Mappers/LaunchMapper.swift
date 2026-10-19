import Foundation

nonisolated enum LaunchMapper {
    static func map(_ dto: LaunchDTO) -> Launch {
        Launch(
            id: dto.id,
            name: dto.name,
            details: dto.details,
            imageURL: dto.links.patch.large.flatMap(URL.init(string:))
                ?? dto.links.patch.small.flatMap(URL.init(string:)),
            launchSite: dto.launchpad.name,
            launchSiteFullName: dto.launchpad.fullName,
            date: dto.dateUtc,
            status: status(upcoming: dto.upcoming, success: dto.success),
            webcastURL: dto.links.webcast.flatMap(URL.init(string:)),
            rocket: Launch.Rocket(
                id: dto.rocket.id,
                name: dto.rocket.name,
                type: dto.rocket.type,
                imageURL: dto.rocket.flickrImages.compactMap(URL.init(string:)).first
            )
        )
    }

    private static func status(upcoming: Bool, success: Bool?) -> Launch.Status {
        if upcoming {
            .upcoming
        } else if let success {
            success ? .successful : .failed
        } else {
            .unknown
        }
    }
}
