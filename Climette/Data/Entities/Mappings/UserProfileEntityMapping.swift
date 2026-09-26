import Foundation

@MainActor
extension UserProfileEntity {
    public func toDomain() -> UserProfile {
        let alertTimes = NotificationAlertTimes(
            weekdayMorning: DateComponents(hour: weekdayMorningHour, minute: weekdayMorningMinute),
            nightFeedback: DateComponents(hour: nightFeedbackHour, minute: nightFeedbackMinute),
            isWeekendMuted: isWeekendMuted
        )
        
        return UserProfile(
            id: id,
            sensitivity: ThermalSensitivity(rawValue: sensitivityRaw) ?? .normal,
            clothingPreference: ClothingPreference(rawValue: clothingPreferenceRaw) ?? .both,
            alertTimes: alertTimes,
            lastActiveTimestamp: lastActiveTimestamp,
            updatedAt: updatedAt
        )
    }
    
    public convenience init(from domain: UserProfile) {
        self.init(
            id: domain.id,
            sensitivityRaw: domain.sensitivity.rawValue,
            clothingPreferenceRaw: domain.clothingPreference.rawValue,
            weekdayMorningHour: domain.alertTimes.weekdayMorning.hour ?? 7,
            weekdayMorningMinute: domain.alertTimes.weekdayMorning.minute ?? 45,
            nightFeedbackHour: domain.alertTimes.nightFeedback.hour ?? 20,
            nightFeedbackMinute: domain.alertTimes.nightFeedback.minute ?? 30,
            isWeekendMuted: domain.alertTimes.isWeekendMuted,
            lastActiveTimestamp: domain.lastActiveTimestamp,
            updatedAt: domain.updatedAt
        )
    }
}
