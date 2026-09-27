import SwiftData
import Foundation

public enum SharedModelContainer {
    
    private static let appGroupID = "group.com.tuempresa.climette"

    public static let schema = Schema([
        UserProfileEntity.self,
        LocationStateEntity.self,
        FeedbackRecordEntity.self,
        ClothingItemEntity.self,
        WeatherSnapshotEntity.self,
        WeatherEntity.self
    ])
    
    public static let shared: ModelContainer = {
        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("No se pudo crear el ModelContainer compartido: \(error)")
        }
    }()
    
    private static var storeURL: URL {
        guard let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        else {
            fatalError("App Group '\(appGroupID)' no configurado. Revisa Signing & Capabilities.")
        }
        return groupURL.appendingPathComponent("Climette.sqlite")
    }
}
