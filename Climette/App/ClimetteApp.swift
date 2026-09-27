import SwiftUI
import SwiftData
import AppIntents

@main
struct ClimetteApp: App {
    @State private var locationService = LocationService()
    @State private var notificationService = NotificationService()
    @State private var speechService = SpeechService()

    public static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfileEntity.self,
            LocationStateEntity.self,
            FeedbackRecordEntity.self,
            ClothingItemEntity.self,
            WeatherSnapshotEntity.self,
            WeatherEntity.self
        ])

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
    }()

    init() {
        ClimetteShortcutsProvider.updateAppShortcutParameters()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                #if DEBUG
                .task {
                    await injectDebugData()
                }
                #endif
        }
        .modelContainer(Self.sharedModelContainer)
        .environment(locationService)
        .environment(notificationService)
        .environment(speechService)
    }
    
    #if DEBUG
    @MainActor
    private func injectDebugData() async {
        let context = Self.sharedModelContainer.mainContext
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now) ?? .now
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: yesterday) ?? yesterday
        
        let descriptor = FetchDescriptor<FeedbackRecordEntity>()
        let existingRecords = (try? context.fetch(descriptor)) ?? []
        
        let hasYesterdayRecord = existingRecords.contains {
            $0.timestamp >= startOfYesterday && $0.timestamp <= endOfYesterday
        }
        
        if !hasYesterdayRecord {
            let weatherSnapshot = WeatherSnapshotEntity(
                temperature: 15.0,
                personalThermalIndex: 14.0,
                windSpeedKmh: 10.0,
                precipitationRaw: PrecipitationState.dry.rawValue,
                skyCoverRaw: SkyCover.clear.rawValue,
                minTemperature: 10.0,
                maxTemperature: 20.0,
                recordedAt: yesterday
            )
            
            let mockRecord = FeedbackRecordEntity(
                timestamp: yesterday,
                weatherSnapshot: weatherSnapshot,
                originPriorityRaw: RecommendationPriority.priority3ColdStart.rawValue,
                evaluatedPeriodRaw: DayEvaluationPeriod.allDay.rawValue,
                recommendedGarments: [],
                wornGarments: [],
                perceptionRaw: ThermalPerception.perfect.rawValue,
                isIndoorDistortion: false,
                collectionStateRaw: DailyCollectionState.correct.rawValue
            )
            
            context.insert(weatherSnapshot)
            context.insert(mockRecord)
            try? context.save()
        }
    }
    #endif
}
