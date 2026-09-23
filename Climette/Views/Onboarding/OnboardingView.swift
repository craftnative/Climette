import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var state = OnboardingState()

    var body: some View {
        TabView(selection: $state.currentTab) {
            ThermalProfileStepView(selectedSensitivity: $state.selectedSensitivity)
                .tag(0)

            LocationStepView(
                selectedLocationMode: $state.selectedLocationMode,
                manualCityName: $state.manualCityName
            )
            .tag(1)

            NotificationsAndHealthStepView(
                weekdayWakeUp: $state.weekdayWakeUp,
                nightReview: $state.nightReview,
                muteWeekends: $state.muteWeekends
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color(uiColor: .systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            OnboardingBottomBar(
                currentTab: state.currentTab,
                totalTabs: state.totalTabs,
                isValid: state.isCurrentStepValid,
                onNext: { state.advance(reduceMotion: reduceMotion) },
                onComplete: completeFlow
            )
        }
    }

    private func completeFlow() {
        state.saveAndComplete(context: modelContext)
        withAnimation(reduceMotion ? nil : .easeInOut) {
            hasCompletedOnboarding = true
        }
    }
}
