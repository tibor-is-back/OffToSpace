import SwiftUI

struct AppRootView: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            Tab("app.root.launchesTab", image: TabIcon.launches) {
                LaunchesRootView(launches: dependencies.launches, rockets: dependencies.rockets)
            }
            .accessibilityIdentifier("root.launchesTab")

            Tab("app.root.rocketsTab", image: TabIcon.rockets) {
                RocketsRootView(rockets: dependencies.rockets)
            }
            .accessibilityIdentifier("root.rocketsTab")
        }
        .tint(DesignSystem.Colors.accent)
    }
}

private enum TabIcon {
    static let launches = "LaunchesIcon"
    static let rockets = "RocketIcon"
}

#Preview("Light") {
    AppRootView(dependencies: AppDependencies(isUITesting: true))
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AppRootView(dependencies: AppDependencies(isUITesting: true))
        .preferredColorScheme(.dark)
}
