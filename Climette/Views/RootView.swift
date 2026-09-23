import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    init() {
        #if DEBUG
        if CommandLine.arguments.contains("-resetOnboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        }
        #endif
    }
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                NavigationStack {
                    Text("Pantalla Principal de Climette")
                        .font(.title2)
                }
            } else {
                OnboardingView()
            }
        }
        #if DEBUG
        .onAppear {
            if CommandLine.arguments.contains("-resetOnboarding") {
                hasCompletedOnboarding = false
            }
        }
        #endif
    }
}
