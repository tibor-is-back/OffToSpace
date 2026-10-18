import Foundation

nonisolated struct Rocket: Equatable {
    let id: String
    let name: String
    let type: String
    let description: String
    let imageURL: URL?
    let successRatePercent: Int
    let isActive: Bool
    let engineCount: Int
    let engineType: String
}
