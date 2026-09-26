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
        // 1. Armario: debe existir y persistirse antes para que el historial pueda vincular prendas
        var wardrobeCheck = FetchDescriptor<ClothingItemEntity>()
        wardrobeCheck.fetchLimit = 1
        let hasWardrobe = (try? context.fetch(wardrobeCheck))?.isEmpty == false
        if !hasWardrobe {
            PreviewSampleData.seedWardrobeData(into: context)
            try? context.save()
        }

        // 2. Perfil de usuario y estado de ubicación
        var userCheck = FetchDescriptor<UserProfileEntity>()
        userCheck.fetchLimit = 1
        let hasUser = (try? context.fetch(userCheck))?.isEmpty == false
        if !hasUser {
            PreviewSampleData.seedUserData(into: context)
        }

        // 3. Historial de feedback
        var historyCheck = FetchDescriptor<FeedbackRecordEntity>()
        historyCheck.fetchLimit = 1
        let hasHistory = (try? context.fetch(historyCheck))?.isEmpty == false
        if !hasHistory {
            PreviewSampleData.seedHistoryData(into: context)
        }

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
