import Foundation
import SwiftData

@Model
public final class UserProfileEntity {
    public var id: UUID = UUID()
    public var sensitivityRaw: String = ""
    
    public var weekdayMorningHour: Int = 0
    public var weekdayMorningMinute: Int = 0
    public var weekendMorningHour: Int = 0
    public var weekendMorningMinute: Int = 0
    public var nightFeedbackHour: Int = 0
    public var nightFeedbackMinute: Int = 0
    public var isWeekendMuted: Bool = false
    
    public var lastActiveTimestamp: Date = Date()
    public var updatedAt: Date = Date()

    public init(
        id: UUID = UUID(),
        sensitivityRaw: String,
        weekdayMorningHour: Int,
        weekdayMorningMinute: Int,
        weekendMorningHour: Int,
        weekendMorningMinute: Int,
        nightFeedbackHour: Int,
        nightFeedbackMinute: Int,
        isWeekendMuted: Bool,
        lastActiveTimestamp: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.sensitivityRaw = sensitivityRaw
        self.weekdayMorningHour = weekdayMorningHour
        self.weekdayMorningMinute = weekdayMorningMinute
        self.weekendMorningHour = weekendMorningHour
        self.weekendMorningMinute = weekendMorningMinute
        self.nightFeedbackHour = nightFeedbackHour
        self.nightFeedbackMinute = nightFeedbackMinute
        self.isWeekendMuted = isWeekendMuted
        self.lastActiveTimestamp = lastActiveTimestamp
        self.updatedAt = updatedAt
    }
}
