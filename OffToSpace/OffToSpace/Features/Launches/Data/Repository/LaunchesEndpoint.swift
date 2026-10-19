import Foundation

nonisolated enum LaunchesEndpoint {
    case launchesQuery(page: Int, limit: Int, startDate: Date, endDate: Date?)

    private static let versionPath = "v4"
    private static let launchesPath = "launches"
    private static let queryPath = "query"
    private static let postMethod = "POST"
    private static let jsonContentType = "application/json"
    private static let contentTypeHeader = "Content-Type"

    func urlRequest(baseURL: URL) throws -> URLRequest {
        switch self {
        case let .launchesQuery(page, limit, startDate, endDate):
            let url = baseURL
                .appending(path: Self.versionPath)
                .appending(path: Self.launchesPath)
                .appending(path: Self.queryPath)
            var request = URLRequest(url: url)
            request.httpMethod = Self.postMethod
            request.setValue(Self.jsonContentType, forHTTPHeaderField: Self.contentTypeHeader)
            let body = LaunchesQueryRequestDTO(
                page: page,
                limit: limit,
                startDate: startDate,
                endDate: endDate
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
            return request
        }
    }
}
