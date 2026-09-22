import Foundation

public enum ThermalSensitivity: String, Codable, CaseIterable, Sendable {
    case friolero = "Friolero"
    case normal = "Normal"
    case caluroso = "Caluroso"
}

public struct NotificationAlertTimes: Codable, Sendable, Equatable {
    public var weekdayMorning: DateComponents
    public var weekendMorning: DateComponents
    public var nightFeedback: DateComponents
    public var isWeekendMuted: Bool

    public init(
        weekdayMorning: DateComponents = DateComponents(hour: 7, minute: 45),
        weekendMorning: DateComponents = DateComponents(hour: 10, minute: 30),
        nightFeedback: DateComponents = DateComponents(hour: 20, minute: 30),
        isWeekendMuted: Bool = false
    ) {
        self.weekdayMorning = weekdayMorning
        self.weekendMorning = weekendMorning
        self.nightFeedback = nightFeedback
        self.isWeekendMuted = isWeekendMuted
    }
}

public struct UserProfile: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var sensitivity: ThermalSensitivity
    public var alertTimes: NotificationAlertTimes
    public var lastActiveTimestamp: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        sensitivity: ThermalSensitivity = .normal,
        alertTimes: NotificationAlertTimes = NotificationAlertTimes(),
        lastActiveTimestamp: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.sensitivity = sensitivity
        self.alertTimes = alertTimes
        self.lastActiveTimestamp = lastActiveTimestamp
        self.updatedAt = updatedAt
    }
}
