import Foundation
import SwiftData

@Model
public final class UserProfileEntity {
    @Attribute(.unique) public var id: UUID
    public var sensitivityRaw: String
    
    public var weekdayMorningHour: Int
    public var weekdayMorningMinute: Int
    public var weekendMorningHour: Int
    public var weekendMorningMinute: Int
    public var nightFeedbackHour: Int
    public var nightFeedbackMinute: Int
    public var isWeekendMuted: Bool
    
    public var lastActiveTimestamp: Date
    public var updatedAt: Date

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
