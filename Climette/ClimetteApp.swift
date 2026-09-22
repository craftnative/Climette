import SwiftUI

@main
struct ClimetteApp: App {
    init() {
        #if DEBUG
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
