import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
public final class OnboardingState {
    public var currentTab: Int = 0
    public let totalTabs: Int = 3

    public var selectedSensitivity: ThermalSensitivity = .normal
    public var selectedLocationMode: LocationSelectionMode = .manual
    public var manualCityName: String = ""

    public var weekdayMorningAlert: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 45)) ?? .now
    public var weekendMorningAlert: Date = Calendar.current.date(from: DateComponents(hour: 10, minute: 30)) ?? .now
    public var nightReview: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 30)) ?? .now
    public var muteWeekends: Bool = false

    public var isCurrentStepValid: Bool {
        if currentTab == 1 && selectedLocationMode == .manual {
            return !manualCityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    public func advance(reduceMotion: Bool) {
        guard currentTab < totalTabs - 1 else { return }
        withAnimation(reduceMotion ? nil : .easeInOut) {
            currentTab += 1
        }
    }
    
    public func goBack(reduceMotion: Bool) {
        guard currentTab > 0 else { return }
        withAnimation(reduceMotion ? nil : .easeInOut) {
            currentTab -= 1
        }
    }

    public func createNotificationAlertTimes() -> NotificationAlertTimes {
        let calendar = Calendar.current
        let weekdayComponents = calendar.dateComponents([.hour, .minute], from: weekdayMorningAlert)
        let nightComponents = calendar.dateComponents([.hour, .minute], from: nightReview)

        return NotificationAlertTimes(
            weekdayMorning: DateComponents(hour: weekdayComponents.hour ?? 7, minute: weekdayComponents.minute ?? 45),
            nightFeedback: DateComponents(hour: nightComponents.hour ?? 20, minute: nightComponents.minute ?? 30),
            isWeekendMuted: muteWeekends
        )
    }

    public func saveAndComplete(context: ModelContext) {
        let alertTimes = createNotificationAlertTimes()

        let userProfile = UserProfile(
            sensitivity: selectedSensitivity,
            alertTimes: alertTimes,
            lastActiveTimestamp: .now,
            updatedAt: .now
        )
        let profileEntity = UserProfileEntity(from: userProfile)
        context.insert(profileEntity)

        let trimmedCity = manualCityName.trimmingCharacters(in: .whitespacesAndNewlines)
        let locationMode: LocationMode
        if selectedLocationMode == .manual && !trimmedCity.isEmpty {
            locationMode = .manualCity(name: trimmedCity, coordinate: GeographicCoordinate(latitude: 0.0, longitude: 0.0))
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
        context.insert(locationEntity)

        do {
            try context.save()
        } catch {
            print("⚠️ CRITICAL - Error al persistir Onboarding en ModelContext: \(error.localizedDescription)")
            print("⚠️ Detalles técnicos: \(error)")
        }
    }
}
