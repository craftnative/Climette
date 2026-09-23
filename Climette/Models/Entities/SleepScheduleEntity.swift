import Foundation
import SwiftData

@Model
public final class SleepScheduleEntity {
    @Attribute(.unique) public var id: UUID
    public var bedtimeHour: Int
    public var bedtimeMinute: Int
    public var wakeUpHour: Int
    public var wakeUpMinute: Int

    public init(id: UUID = UUID(), bedtimeHour: Int, bedtimeMinute: Int, wakeUpHour: Int, wakeUpMinute: Int) {
        self.id = id
        self.bedtimeHour = bedtimeHour
        self.bedtimeMinute = bedtimeMinute
        self.wakeUpHour = wakeUpHour
        self.wakeUpMinute = wakeUpMinute
    }
}
