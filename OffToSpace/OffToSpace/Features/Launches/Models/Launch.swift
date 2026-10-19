import Foundation

nonisolated struct Launch: Hashable {
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

    nonisolated enum Status: Hashable {
        case upcoming
        case successful
        case failed
        case unknown
    }

    nonisolated struct Rocket: Hashable {
        let id: String
        let name: String
        let type: String
        let imageURL: URL?
    }
}
