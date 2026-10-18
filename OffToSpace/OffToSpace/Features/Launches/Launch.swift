import Foundation

nonisolated struct Launch: Sendable, Equatable {
    let id: String
    let name: String
    let details: String?
    let imageURL: URL?
    let launchSite: String
    let date: Date
    let status: Status
    let webcastURL: URL?
    let rocket: Rocket

    nonisolated enum Status: Sendable, Equatable {
        case upcoming
        case successful
        case failed
        case unknown
    }

    nonisolated struct Rocket: Sendable, Equatable {
        let id: String
        let name: String
        let type: String
    }
}
