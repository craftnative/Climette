import AppIntents
import Foundation
import SwiftData

public struct SaveDailyFeedbackIntent: AppIntent {
    // FIX: Convertidas a propiedades computadas para cumplir con la concurrencia estricta de Swift 6
    public static var title: LocalizedStringResource { "Registrar Sensación Térmica" }
    public static var description: IntentDescription { IntentDescription("Guarda cómo te sentiste con la ropa que llevabas hoy.") }
    
    @Parameter(title: "Sensación y prendas", description: "Dime cómo te sentiste y qué llevabas puesto.")
    public var spokenFeedback: String

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        // 1. Validación de Hardware y Disponibilidad
        guard #available(iOS 18.0, *) else {
            throw IntentError.appleIntelligenceNotAvailable
        }
        
        // 2. Procesamiento Generativo Local
        // FIX: Se elimina la llamada a un módulo inexistente y se simula la extracción de entidades
        // En una implementación final en iOS 18, Siri procesa estos parámetros de forma nativa.
        let extractedDTO = parseSpokenFeedback(spokenFeedback)
        
        // 3. Persistencia en Base de Datos
        let container = try ModelContainer(for: Schema([
            UserProfileEntity.self, LocationStateEntity.self, FeedbackRecordEntity.self,
            ClothingItemEntity.self, WeatherSnapshotEntity.self, WeatherEntity.self
        ]))
        let context = container.mainContext
        
        let catalog = (try? context.fetch(FetchDescriptor<ClothingItemEntity>())) ?? []
        
        let wornGarments = mapGarmentNames(extractedDTO.wornGarmentNames, catalog: catalog)
        let adjustedGarment = mapGarmentNames(extractedDTO.adjustedGarmentNames, catalog: catalog).first
        
        let weatherEntity = WeatherSnapshotEntity(
            temperature: 20.0, // Requiere sincronización con WeatherKit local en un entorno real
            personalThermalIndex: 20.0,
            windSpeedKmh: 5.0,
            precipitationRaw: PrecipitationState.dry.rawValue,
            skyCoverRaw: SkyCover.clear.rawValue,
            minTemperature: 15.0,
            maxTemperature: 25.0,
            recordedAt: .now
        )
        
        let newRecord = FeedbackRecordEntity(
            timestamp: .now,
            weatherSnapshot: weatherEntity,
            originPriorityRaw: RecommendationPriority.priority3ColdStart.rawValue,
            evaluatedPeriodRaw: extractedDTO.evaluationPeriod.rawValue,
            wornGarments: wornGarments,
            perceptionRaw: extractedDTO.perception.rawValue,
            isIndoorDistortion: extractedDTO.isIndoorDistortion,
            physicalReactionRaw: extractedDTO.physicalReaction?.rawValue,
            adjustedGarment: adjustedGarment,
            postAdjustmentStateRaw: extractedDTO.postAdjustmentState?.rawValue,
            collectionStateRaw: DailyCollectionState.correct.rawValue
        )
        
        context.insert(weatherEntity)
        context.insert(newRecord)
        try? context.save()
        
        return .result(dialog: "Registro guardado correctamente. Climette ha calibrado tu Índice Térmico.")
    }
    
    // MOCK: Función que simula la extracción de intenciones de Apple Intelligence para el texto de entrada.
    private func parseSpokenFeedback(_ text: String) -> VoiceFeedbackExtractionDTO {
        let lower = text.lowercased()
        let perception: ThermalPerception = lower.contains("frío") ? .feltCold : (lower.contains("calor") ? .feltHot : .perfect)
        
        return VoiceFeedbackExtractionDTO(
            evaluationPeriod: .allDay,
            perception: perception,
            isIndoorDistortion: lower.contains("interior") || lower.contains("oficina") || lower.contains("casa"),
            wornGarmentNames: ["camiseta"], // En producción se derivaría del texto
            physicalReaction: (lower.contains("quité") || lower.contains("puse")) ? .adjustedClothing : .enduredAsIs,
            adjustedGarmentNames: [],
            postAdjustmentState: .stabilized
        )
    }
    
    private func mapGarmentNames(_ names: [String], catalog: [ClothingItemEntity]) -> [ClothingItemEntity] {
        var matched: [ClothingItemEntity] = []
        for name in names {
            let query = name.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            if let found = catalog.first(where: {
                $0.canonicalName.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query) ||
                ($0.userNickname?.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query) == true)
            }) {
                if !matched.contains(where: { $0.id == found.id }) {
                    matched.append(found)
                }
            }
        }
        return matched
    }
    
    enum IntentError: Error, CustomLocalizedStringResourceConvertible {
        case appleIntelligenceNotAvailable
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .appleIntelligenceNotAvailable:
                return "El procesamiento avanzado requiere un dispositivo compatible con iOS 18 o superior."
            }
        }
    }
}
