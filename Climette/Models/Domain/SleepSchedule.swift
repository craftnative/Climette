import Foundation

public struct SleepSchedule: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var bedtime: DateComponents
    public var wakeUp: DateComponents
    
    public init(id: UUID = UUID(), bedtime: DateComponents, wakeUp: DateComponents) {
        self.id = id
        self.bedtime = bedtime
        self.wakeUp = wakeUp
    }
}
