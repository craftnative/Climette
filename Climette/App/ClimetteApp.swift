import SwiftUI
import SwiftData

@main
struct ClimetteApp: App {
    @State private var locationService = LocationService()
    @State private var notificationService = NotificationService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfileEntity.self,
            LocationStateEntity.self,
            FeedbackRecordEntity.self,
            ClothingItemEntity.self,
            WeatherSnapshotEntity.self,
            WeatherEntity.self
        ])

        #if DEBUG
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            Task { @MainActor in
                PreviewSampleData.seedSampleData(into: container.mainContext)
                // Opcional en desarrollo: omitir onboarding si se desea entrar directo a ver datos
                if UserDefaults.standard.object(forKey: "hasCompletedOnboarding") == nil {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
            }
            return container
        } catch {
            fatalError("No se pudo crear el ModelContainer de Debug: \(error)")
        }
        #else
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
        #endif
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
        .environment(locationService)
        .environment(notificationService)
    }
}
