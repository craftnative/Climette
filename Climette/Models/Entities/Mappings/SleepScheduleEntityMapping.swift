import Foundation

extension SleepScheduleEntity {
    @MainActor public func toDomain() -> SleepSchedule {
        return SleepSchedule(
            id: id,
            bedtime: DateComponents(hour: bedtimeHour, minute: bedtimeMinute),
            wakeUp: DateComponents(hour: wakeUpHour, minute: wakeUpMinute)
        )
    }

    public convenience init(from domain: SleepSchedule) {
        self.init(
            id: domain.id,
            bedtimeHour: domain.bedtime.hour ?? 22,
            bedtimeMinute: domain.bedtime.minute ?? 0,
            wakeUpHour: domain.wakeUp.hour ?? 7,
            wakeUpMinute: domain.wakeUp.minute ?? 0
        )
    }
}
