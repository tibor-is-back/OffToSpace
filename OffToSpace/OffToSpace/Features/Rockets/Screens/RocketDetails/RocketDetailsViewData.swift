import Foundation

struct RocketDetailsViewData {
    let name: String
    let subtitle: String
    let imageURL: URL?
    let status: Status
    let type: String
    let description: String
    let engines: String
    let engineType: String
    let successRate: String

    enum Status {
        case active
        case inactive

        var text: String {
            switch self {
            case .active:
                String(localized: "rockets.details.active")
            case .inactive:
                String(localized: "rockets.details.inactive")
            }
        }
    }
}
