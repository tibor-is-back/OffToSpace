import Foundation

nonisolated protocol RocketsRepository: Sendable {
    @concurrent
    func fetchRockets(page: Int, limit: Int) async throws -> Page<Rocket>

    @concurrent
    func fetchRocket(id: String) async throws -> Rocket
}
