import SwiftUI
import SwiftData

@MainActor
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    @State private var currentTab: Int = 0
    private let totalTabs: Int = 3

    @State private var selectedSensitivity: ThermalSensitivity = .normal
    @State private var selectedLocationMode: LocationSelectionMode = .gps
    @State private var manualCityName: String = ""

    @State private var weekdayWakeUp: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 45)) ?? .now
    @State private var weekendWakeUp: Date = Calendar.current.date(from: DateComponents(hour: 10, minute: 30)) ?? .now
    @State private var nightReview: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 30)) ?? .now
    @State private var muteWeekends: Bool = false

    private var isCurrentStepValid: Bool {
        if currentTab == 1 && selectedLocationMode == .manual {
            return !manualCityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentTab) {
                ThermalProfileStepView(selectedSensitivity: $selectedSensitivity)
                    .tag(0)

                LocationStepView(
                    selectedLocationMode: $selectedLocationMode,
                    manualCityName: $manualCityName
                )
                    .tag(1)

                NotificationsAndHealthStepView(
                    weekdayWakeUp: $weekdayWakeUp,
                    nightReview: $nightReview,
                    muteWeekends: $muteWeekends
                )
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Se oculta el nativo superpuesto para usar el integrado en BottomBar
            .padding(.bottom, 80)

            OnboardingBottomBar(
                currentTab: $currentTab,
                totalTabs: totalTabs,
                isValid: isCurrentStepValid,
                onComplete: completeOnboarding
            )
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private func completeOnboarding() {
        let calendar = Calendar.current
        let weekdayComponents = calendar.dateComponents([.hour, .minute], from: weekdayWakeUp)
        let weekendComponents = calendar.dateComponents([.hour, .minute], from: weekendWakeUp)
        let nightComponents = calendar.dateComponents([.hour, .minute], from: nightReview)

        let alertTimes = NotificationAlertTimes(
            weekdayMorning: DateComponents(hour: weekdayComponents.hour ?? 7, minute: weekdayComponents.minute ?? 45),
            weekendMorning: DateComponents(hour: weekendComponents.hour ?? 10, minute: weekendComponents.minute ?? 30),
            nightFeedback: DateComponents(hour: nightComponents.hour ?? 20, minute: nightComponents.minute ?? 30),
            isWeekendMuted: muteWeekends
        )

        let userProfile = UserProfile(
            sensitivity: selectedSensitivity,
            alertTimes: alertTimes,
            lastActiveTimestamp: .now,
            updatedAt: .now
        )
        let profileEntity = UserProfileEntity(from: userProfile)
        modelContext.insert(profileEntity)

        let trimmedCity = manualCityName.trimmingCharacters(in: .whitespacesAndNewlines)
        let locationMode: LocationMode
        if selectedLocationMode == .manual && !trimmedCity.isEmpty {
            locationMode = .manualCity(
                name: trimmedCity,
                coordinate: GeographicCoordinate(latitude: 0.0, longitude: 0.0)
            )
        } else {
            locationMode = .foregroundGPS
        }

        let locationState = LocationState(
            mode: locationMode,
            currentCoordinate: nil,
            lastResolvedCityName: selectedLocationMode == .manual ? trimmedCity : nil,
            lastUpdated: .now
        )
        let locationEntity = LocationStateEntity(from: locationState)
        modelContext.insert(locationEntity)

        do {
            try modelContext.save()
            withAnimation {
                hasCompletedOnboarding = true
            }
        } catch {
            assertionFailure("Error al persistir Onboarding en ModelContext: \(error)")
        }
    }
}
