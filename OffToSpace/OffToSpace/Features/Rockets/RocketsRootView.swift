import SwiftUI

struct RocketsRootView: View {
    @State private var path: [RocketsRoute] = []
    private let rockets: AppDependencies.Rockets

    init(rockets: AppDependencies.Rockets) {
        self.rockets = rockets
    }

    var body: some View {
        NavigationStack(path: $path) {
            RocketsView(viewModel: rockets.makeViewModel()) { id in
                path.append(.rocket(id))
            }
            .navigationDestination(for: RocketsRoute.self) { route in
                switch route {
                case .rocket(let id):
                    RocketDetailsView(viewModel: rockets.makeDetailsViewModel(rocketID: id))
                }
            }
        }
    }
}

private enum RocketsRoute: Hashable {
    case rocket(String)
}

#Preview("Light") {
    RocketsRootView(rockets: AppDependencies(isUITesting: true).rockets)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RocketsRootView(rockets: AppDependencies(isUITesting: true).rockets)
        .preferredColorScheme(.dark)
}
