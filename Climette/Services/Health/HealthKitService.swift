import Foundation
import HealthKit

public final class HealthKitService: HealthKitServiceProtocol {
    private let healthStore: HKHealthStore

    public init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }

    public var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public func requestSleepAuthorization() async throws -> Bool {
        guard isHealthDataAvailable else {
            throw HealthKitServiceError.healthDataUnavailable
        }

        let sleepType = HKCategoryType(.sleepAnalysis)
        let typesToRead: Set<HKObjectType> = [sleepType]

        let status = try await healthStore.statusForAuthorizationRequest(toShare: [], read: typesToRead)
        if status == .shouldRequest {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        }

        return true
    }

    public func fetchRecentSleepSchedule() async throws -> SleepSchedule? {
        guard isHealthDataAvailable else {
            throw HealthKitServiceError.healthDataUnavailable
        }

        let sleepType = HKCategoryType(.sleepAnalysis)
        let calendar = Calendar.current
        let endDate = Date.now

        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            throw HealthKitServiceError.noDataOrPermissionDenied
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: sleepType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 20
        )

        let samples = try await descriptor.result(for: healthStore)

        guard !samples.isEmpty else {
            throw HealthKitServiceError.noDataOrPermissionDenied
        }

        let validSleepSamples = samples.filter { sample in
            sample.value != HKCategoryValueSleepAnalysis.inBed.rawValue
        }

        guard let latestSample = validSleepSamples.first ?? samples.first else {
            throw HealthKitServiceError.noDataOrPermissionDenied
        }

        let bedtimeComponents = calendar.dateComponents([.hour, .minute], from: latestSample.startDate)
        let wakeUpComponents = calendar.dateComponents([.hour, .minute], from: latestSample.endDate)

        return SleepSchedule(
            bedtime: DateComponents(hour: bedtimeComponents.hour ?? 23, minute: bedtimeComponents.minute ?? 0),
            wakeUp: DateComponents(hour: wakeUpComponents.hour ?? 7, minute: wakeUpComponents.minute ?? 30)
        )
    }
}
