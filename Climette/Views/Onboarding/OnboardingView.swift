import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(LocationService.self) private var locationService
    @Environment(NotificationService.self) private var notificationService
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var state = OnboardingState()
    @State private var isProcessingCompletion: Bool = false

    var body: some View {
        TabView(selection: $state.currentTab) {
            Group {
                ThermalProfileStepView(selectedSensitivity: $state.selectedSensitivity)
                    .tag(0)

                LocationStepView(state: state)
                    .tag(1)

                RoutineStepView(
                    weekdayMorningAlert: $state.weekdayMorningAlert,
                    nightReview: $state.nightReview,
                    muteWeekends: $state.muteWeekends
                )
                    .tag(2)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color(uiColor: .systemGroupedBackground))
        .disabled(isProcessingCompletion)
        .safeAreaInset(edge: .bottom) {
            OnboardingBottomBar(
                currentTab: state.currentTab,
                totalTabs: state.totalTabs,
                isValid: state.isCurrentStepValid && !isProcessingCompletion,
                onNext: { state.advance(reduceMotion: reduceMotion) },
                onComplete: {
                    Task { @MainActor in
                        await completeFlow()
                    }
                }
            )
        }
    }

    private func completeFlow() async {
        isProcessingCompletion = true

        let alertTimes = state.createNotificationAlertTimes()

        do {
            let isGranted = try await notificationService.requestAuthorization()
            if isGranted {
                try await notificationService.scheduleRoutineNotifications(alertTimes: alertTimes)
            }
        } catch {
        }

        state.saveAndComplete(context: modelContext)

        withAnimation(reduceMotion ? nil : .easeInOut) {
            hasCompletedOnboarding = true
        }

        isProcessingCompletion = false
    }
}
