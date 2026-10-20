import Foundation

nonisolated final class UITestingLaunchesRepository: LaunchesRepository {
    @concurrent
    func fetchLaunches(page: Int, limit: Int, startDate: Date, endDate: Date?) async throws -> Page<Launch> {
        try Task.checkCancellation()
        let items = UITestingData.launches.filter { launch in
            launch.date >= startDate && (endDate.map { launch.date <= $0 } ?? true)
        }
        return UITestingData.page(of: items, page: page, limit: limit)
    }
}
