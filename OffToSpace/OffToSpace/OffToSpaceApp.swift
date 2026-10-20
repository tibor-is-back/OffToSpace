//
//  OffToSpaceApp.swift
//  OffToSpace
//
//  Created by Kántor Tibor on 18/10/2026.
//

import SwiftUI

@main
struct OffToSpaceApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            AppRootView(dependencies: dependencies)
        }
    }
}
