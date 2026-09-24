import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var notificationService: NotificationServiceProtocol = NotificationService()
    var locationService: LocationServiceProtocol = LocationService()
    var healthKitService: HealthKitServiceProtocol = HealthKitService()
    
    @State private var state = OnboardingState()
    @State private var isProcessingCompletion: Bool = false

    var body: some View {
        TabView(selection: $state.currentTab) {
            ThermalProfileStepView(selectedSensitivity: $state.selectedSensitivity)
                .tag(0)

            LocationStepView(
                selectedLocationMode: $state.selectedLocationMode,
                manualCityName: $state.manualCityName,
                locationService: locationService
            )
            .tag(1)

            NotificationsAndHealthStepView(
                weekdayWakeUp: $state.weekdayWakeUp,
                nightReview: $state.nightReview,
                muteWeekends: $state.muteWeekends,
                healthKitService: healthKitService
            )
            .tag(2)
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
            // Continúa la finalización si el permiso es denegado o falla la programación
        }

        state.saveAndComplete(context: modelContext)

        withAnimation(reduceMotion ? nil : .easeInOut) {
            hasCompletedOnboarding = true
        }

        isProcessingCompletion = false
    }
}

#Preview {
    OnboardingView()
}
