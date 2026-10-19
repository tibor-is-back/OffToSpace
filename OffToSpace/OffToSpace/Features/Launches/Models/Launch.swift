import Foundation

nonisolated struct Launch: Equatable {
    let id: String
    let name: String
    let details: String?
    let imageURL: URL?
    let launchSite: String
    let launchSiteFullName: String
    let date: Date
    let status: Status
    let webcastURL: URL?
    let rocket: Rocket

    nonisolated enum Status: Equatable {
        case upcoming
        case successful
        case failed
        case unknown
    }

    nonisolated struct Rocket: Equatable {
        let id: String
        let name: String
        let type: String
    }
}
