import SwiftUI

struct AppRootView: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            Tab {
                NavigationStack {
                    LaunchesView(
                        dependencies: dependencies.launches,
                        rockets: dependencies.rockets
                    )
                }
            } label: {
                tabLabel("app.root.launchesTab", icon: TabIcon.launches)
                    .accessibilityIdentifier("root.launchesTab")
            }

            Tab {
                NavigationStack {
                    RocketsView(dependencies: dependencies.rockets)
                }
            } label: {
                tabLabel("app.root.rocketsTab", icon: TabIcon.rockets)
                    .accessibilityIdentifier("root.rocketsTab")
            }
        }
        .tint(DesignSystem.Colors.accent)
    }

    private func tabLabel(_ titleKey: LocalizedStringKey, icon: String) -> some View {
        Label {
            Text(titleKey)
        } icon: {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: DesignSystem.Size.tabIcon, height: DesignSystem.Size.tabIcon)
        }
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
