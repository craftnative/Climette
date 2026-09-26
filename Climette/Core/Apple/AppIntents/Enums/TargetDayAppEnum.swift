import AppIntents
import Foundation

public enum TargetDayAppEnum: String, AppEnum, Sendable {
    case yesterday = "Ayer"
    case today = "Hoy"
    case tomorrow = "Mañana"

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Día Objetivo"
    }

    public static var caseDisplayRepresentations: [TargetDayAppEnum: DisplayRepresentation] {
        [
            .yesterday: "Ayer",
            .today: "Hoy",
            .tomorrow: "Mañana"
        ]
    }
    
    public func targetDate() -> Date {
        let calendar = Calendar.current
        switch self {
        case .yesterday:
            return calendar.date(byAdding: .day, value: -1, to: .now) ?? .now
        case .today:
            return .now
        case .tomorrow:
            return calendar.date(byAdding: .day, value: 1, to: .now) ?? .now
        }
    }
}
