import Foundation

struct LaunchDetailsViewData {
    let name: String
    let subtitle: String?
    let imageURL: URL?
    let statusText: String
    let statusStyle: BadgeView.Style
    let date: String
    let location: String
    let description: String?
    let webcastURL: URL?
    let rocket: Rocket

    struct Rocket {
        let id: String
        let name: String
        let type: String
        let imageURL: URL?
    }
}
