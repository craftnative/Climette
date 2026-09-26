#if DEBUG
import Foundation
import SwiftData

@MainActor
extension PreviewSampleData {
    public static func seedUserData(into context: ModelContext) {
        let now = Date.now
        
        let userProfile = UserProfileEntity(
            sensitivityRaw: ThermalSensitivity.normal.rawValue,
            weekdayMorningHour: 7,
            weekdayMorningMinute: 45,
            nightFeedbackHour: 20,
            nightFeedbackMinute: 30,
            isWeekendMuted: false,
            lastActiveTimestamp: now,
            updatedAt: now
        )
        context.insert(userProfile)
        
        let locationState = LocationStateEntity(
            modeRaw: LocationMode.gps.rawValue,
            gpsLatitude: 38.3452,
            gpsLongitude: -0.4810,
            gpsCityName: "Alicante",
            lastUpdated: now
        )
        context.insert(locationState)
    }
}
#endif
