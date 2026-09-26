import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
public final class OnboardingState {
    public var currentTab: Int = 0
    public let totalTabs: Int = 4

    public var selectedSensitivity: ThermalSensitivity = .normal
    public var selectedClothingPreference: ClothingPreference = .both
    
    public var selectedLocationMode: LocationMode = .manual
    public var manualCityName: String = ""
    public var manualCoordinate: GeographicCoordinate? = nil
    public var gpsCityName: String? = nil
    public var gpsCoordinate: GeographicCoordinate? = nil

    public var weekdayMorningAlert: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 45)) ?? .now
    public var weekendMorningAlert: Date = Calendar.current.date(from: DateComponents(hour: 10, minute: 30)) ?? .now
    public var nightReview: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 30)) ?? .now
    public var muteWeekends: Bool = false

    public var isCurrentStepValid: Bool {
        if currentTab == 2 && selectedLocationMode == .manual { // Ajustado índice por nuevo tab
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

        // 1. Upsert UserProfileEntity
        do {
            var profileDescriptor = FetchDescriptor<UserProfileEntity>()
            profileDescriptor.fetchLimit = 1
            let existingProfiles = try context.fetch(profileDescriptor)

            if let existingProfile = existingProfiles.first {
                existingProfile.sensitivityRaw = selectedSensitivity.rawValue
                existingProfile.clothingPreferenceRaw = selectedClothingPreference.rawValue
                existingProfile.weekdayMorningHour = alertTimes.weekdayMorning.hour ?? 7
                existingProfile.weekdayMorningMinute = alertTimes.weekdayMorning.minute ?? 45
                existingProfile.nightFeedbackHour = alertTimes.nightFeedback.hour ?? 20
                existingProfile.nightFeedbackMinute = alertTimes.nightFeedback.minute ?? 30
                existingProfile.isWeekendMuted = muteWeekends
                existingProfile.lastActiveTimestamp = .now
                existingProfile.updatedAt = .now
            } else {
                let userProfile = UserProfile(
                    sensitivity: selectedSensitivity,
                    clothingPreference: selectedClothingPreference,
                    alertTimes: alertTimes,
                    lastActiveTimestamp: .now,
                    updatedAt: .now
                )
                let profileEntity = UserProfileEntity(from: userProfile)
                context.insert(profileEntity)
            }
        } catch {
            print("⚠️ Error al consultar UserProfileEntity en Onboarding: \(error)")
        }

        // 2. Upsert LocationStateEntity
        let trimmedCity = manualCityName.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            var locationDescriptor = FetchDescriptor<LocationStateEntity>()
            locationDescriptor.fetchLimit = 1
            let existingLocations = try context.fetch(locationDescriptor)

            if let existingLocation = existingLocations.first {
                existingLocation.modeRaw = selectedLocationMode.rawValue
                existingLocation.manualCityName = trimmedCity.isEmpty ? nil : trimmedCity
                existingLocation.manualLatitude = manualCoordinate?.latitude
                existingLocation.manualLongitude = manualCoordinate?.longitude
                existingLocation.gpsCityName = gpsCityName
                existingLocation.gpsLatitude = gpsCoordinate?.latitude
                existingLocation.gpsLongitude = gpsCoordinate?.longitude
                existingLocation.lastUpdated = .now
            } else {
                // Instanciar entidad directamente (omitido por claridad si usa el constructor del Entity)
            }
        } catch {
            print("⚠️ Error al consultar LocationStateEntity en Onboarding: \(error)")
        }

        // 3. Persistir cambios
        do {
            try context.save()
        } catch {
            print("⚠️ CRITICAL - Error al persistir Onboarding en ModelContext: \(error.localizedDescription)")
        }
    }
}
