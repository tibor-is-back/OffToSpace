import Foundation

struct AppDependencies {
    let launches: Launches
    let rockets: Rockets
    private let apiClient: any APIClient

    init(isUITesting: Bool = AppEnvironment.isUITesting) {
        let apiClient = DefaultAPIClient()
        self.apiClient = apiClient
        guard let baseURL = URL(string: "http://localhost:3000") else {
            preconditionFailure("The configured SpaceX API URL must be valid.")
        }
        launches = Launches(apiClient: apiClient, baseURL: baseURL, isUITesting: isUITesting)
        rockets = Rockets(apiClient: apiClient, baseURL: baseURL, isUITesting: isUITesting)
    }

    struct Launches {
        private let repository: any LaunchesRepository
        private let interactor: any LaunchesInteractor
        private let filter: LaunchFilter

        init(apiClient: any APIClient, baseURL: URL, isUITesting: Bool) {
            if isUITesting {
                repository = UITestingLaunchesRepository()
            } else {
                repository = DefaultLaunchesRepository(apiClient: apiClient, baseURL: baseURL)
            }
            let calendar = Calendar.current
            let referenceDate = isUITesting ? UITestingData.launchDate : .now
            guard let year = calendar.dateInterval(of: .year, for: referenceDate),
                  let yearEnd = calendar.date(byAdding: .second, value: -1, to: year.end) else {
                preconditionFailure("The current calendar must provide the current year's date range.")
            }
            filter = LaunchFilter(startDate: year.start, endDate: yearEnd)
            interactor = DefaultLaunchesInteractor(repository: repository, filter: filter)
        }

        func makeViewModel() -> LaunchesViewModel {
            LaunchesViewModel(interactor: interactor, filter: filter)
        }

        func makeDetailsViewModel(launchID: String) -> LaunchDetailsViewModel {
            LaunchDetailsViewModel(launchID: launchID, interactor: interactor)
        }
    }

    struct Rockets {
        private let repository: any RocketsRepository
        private let interactor: any RocketsInteractor

        init(apiClient: any APIClient, baseURL: URL, isUITesting: Bool) {
            if isUITesting {
                repository = UITestingRocketsRepository()
            } else {
                repository = DefaultRocketsRepository(apiClient: apiClient, baseURL: baseURL)
            }
            interactor = DefaultRocketsInteractor(repository: repository)
        }

        func makeViewModel() -> RocketsViewModel {
            RocketsViewModel(interactor: interactor)
        }

        func makeDetailsViewModel(rocketID: String) -> RocketDetailsViewModel {
            RocketDetailsViewModel(rocketID: rocketID, interactor: interactor)
        }
    }
}
