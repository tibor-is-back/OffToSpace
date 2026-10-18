import Foundation

nonisolated protocol APIClient: Sendable {
    func request<Response: Decodable & Sendable>(_ urlRequest: URLRequest) async throws -> Response
}
