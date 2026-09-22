import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        
        if hasCompletedOnboarding {
            NavigationStack {
                Text("Pantalla Principal de Climette")
                    .font(.title2)
            }
        } else {
            OnboardingView()
        }
    }
}
