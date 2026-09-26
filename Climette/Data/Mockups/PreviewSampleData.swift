#if DEBUG
import Foundation
import SwiftData
import SwiftUI

@MainActor
public enum PreviewSampleData {
    public static func makeContainer() -> ModelContainer {
        let schema = Schema([
            UserProfileEntity.self,
            LocationStateEntity.self,
            FeedbackRecordEntity.self,
            ClothingItemEntity.self,
            WeatherSnapshotEntity.self,
            WeatherEntity.self
        ])
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            fatalError("No se pudo instanciar el ModelContainer en memoria.")
        }
        
        let context = container.mainContext
        seedSampleData(into: context)
        
        return container
    }

    public static func seedSampleData(into context: ModelContext) {
        var fetchCheck = FetchDescriptor<UserProfileEntity>()
        fetchCheck.fetchLimit = 1
        if let existing = try? context.fetch(fetchCheck), !existing.isEmpty {
            return
        }

        PreviewSampleData.seedUserData(into: context)
        PreviewSampleData.seedWardrobeData(into: context)
        PreviewSampleData.seedHistoryData(into: context)
        
        try? context.save()
    }
}

extension View {
    @MainActor
    public func withPreviewEnvironment() -> some View {
        self
            .modelContainer(PreviewSampleData.makeContainer())
            .environment(LocationService())
            .environment(NotificationService())
    }
}
#endif
