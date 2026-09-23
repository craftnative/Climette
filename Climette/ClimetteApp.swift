import SwiftUI
import SwiftData

@main
struct ClimetteApp: App {

    #if DEBUG
    init() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
    #endif

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            UserProfileEntity.self,
            LocationStateEntity.self,
            FeedbackRecordEntity.self,
            ClothingItemEntity.self,
            WeatherSnapshotEntity.self,
            SleepScheduleEntity.self,
            WeatherEntity.self
        ])
    }
}
