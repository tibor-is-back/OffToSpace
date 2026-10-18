import Foundation

nonisolated final class DefaultLaunchesRepository: LaunchesRepository {
    private let apiClient: any APIClient
    private let baseURL: URL

    init(apiClient: any APIClient, baseURL: URL) {
        self.apiClient = apiClient
        self.baseURL = baseURL
    }

    @concurrent
    func fetchLaunches(page: Int, limit: Int, startDate: Date, endDate: Date? = nil) async throws -> Page<Launch> {
        let urlRequest = try LaunchesEndpoint.launchesQuery(
            page: page,
            limit: limit,
            startDate: startDate,
            endDate: endDate
        ).urlRequest(baseURL: baseURL)
        let dto: LaunchesQueryDTO = try await apiClient.request(urlRequest)
        return LaunchesPageMapper.map(dto)
    }
}
