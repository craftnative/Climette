import SwiftUI
import SwiftData

@main
struct ClimetteApp: App {

    #if DEBUG
    init() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
    #endif

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfileEntity.self,
            LocationStateEntity.self,
            FeedbackRecordEntity.self,
            ClothingItemEntity.self,
            WeatherSnapshotEntity.self,
            WeatherEntity.self
        ])

        let syncEnabled = UserDefaults.standard.bool(forKey: "isCloudKitSyncEnabled")

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: syncEnabled ? .automatic : .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
