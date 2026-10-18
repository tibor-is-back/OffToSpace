import Foundation

nonisolated final class DefaultRocketsRepository: RocketsRepository {
    private let apiClient: any APIClient
    private let baseURL: URL

    init(apiClient: any APIClient, baseURL: URL) {
        self.apiClient = apiClient
        self.baseURL = baseURL
    }

    @concurrent
    func fetchRockets(page: Int, limit: Int) async throws -> Page<Rocket> {
        let urlRequest = try RocketsEndpoint.rocketsQuery(
            page: page,
            limit: limit
        ).urlRequest(baseURL: baseURL)
        let dto: RocketsQueryDTO = try await apiClient.request(urlRequest)
        return RocketsPageMapper.map(dto)
    }

    @concurrent
    func fetchRocket(id: String) async throws -> Rocket {
        let urlRequest = try RocketsEndpoint.rocket(id: id).urlRequest(baseURL: baseURL)
        let dto: RocketDTO = try await apiClient.request(urlRequest)
        return RocketMapper.map(dto)
    }
}
