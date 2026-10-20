import Foundation

nonisolated final class UITestingRocketsRepository: RocketsRepository {
    @concurrent
    func fetchRockets(page: Int, limit: Int) async throws -> Page<Rocket> {
        try Task.checkCancellation()
        return UITestingData.page(of: UITestingData.rockets, page: page, limit: limit)
    }

    @concurrent
    func fetchRocket(id: String) async throws -> Rocket {
        try Task.checkCancellation()
        guard let rocket = UITestingData.rockets.first(where: { $0.id == id }) else {
            throw URLError(.resourceUnavailable)
        }
        return rocket
    }
}
