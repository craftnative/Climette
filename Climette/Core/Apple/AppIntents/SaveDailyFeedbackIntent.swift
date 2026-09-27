import AppIntents
import Foundation
import SwiftData

public struct SaveDailyFeedbackIntent: AppIntent {
    public static var title: LocalizedStringResource { "Registrar Sensación Térmica" }
    public static var description: IntentDescription { IntentDescription("Guarda cómo te sentiste con la ropa que llevabas hoy.") }
    
    @Parameter(title: "Sensación Térmica", default: .perfect)
    public var perception: ThermalPerception
    
    @Parameter(title: "Momento del Día", default: .allDay)
    public var period: DayEvaluationPeriod

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = SharedModelContainer.shared.mainContext
        
        let weatherEntity = WeatherSnapshotEntity(
            temperature: 20.0,
            personalThermalIndex: 20.0,
            windSpeedKmh: 5.0,
            precipitationRaw: PrecipitationState.dry.rawValue,
            skyCoverRaw: SkyCover.clear.rawValue,
            minTemperature: 15.0,
            maxTemperature: 25.0,
            recordedAt: .now
        )
        
        let collectionState: DailyCollectionState = (perception == .perfect) ? .correct : .incorrect

        let newRecord = FeedbackRecordEntity(
            timestamp: .now,
            weatherSnapshot: weatherEntity,
            originPriorityRaw: RecommendationPriority.priority3ColdStart.rawValue,
            evaluatedPeriodRaw: period.rawValue,
            wornGarments: [],
            perceptionRaw: perception.rawValue,
            isIndoorDistortion: false,
            physicalReactionRaw: nil,
            adjustedGarment: nil,
            postAdjustmentStateRaw: nil,
            collectionStateRaw: collectionState.rawValue
        )
        
        context.insert(weatherEntity)
        context.insert(newRecord)
        try context.save()
        
        return .result(dialog: "Registro guardado correctamente. Climette ha calibrado tu Índice Térmico.")
    }
}
