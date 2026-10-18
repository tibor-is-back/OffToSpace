import Foundation

nonisolated protocol LaunchesRepository: Sendable {
    @concurrent
    func fetchLaunches(page: Int, limit: Int, startDate: Date, endDate: Date?) async throws -> Page<Launch>
}
