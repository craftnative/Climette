import AppIntents
import Foundation
import SwiftData
import FoundationModels

public struct SaveDailyFeedbackIntent: AppIntent {
    public static var title: LocalizedStringResource { "Registrar Sensación Térmica" }
    public static var description: IntentDescription { IntentDescription("Guarda cómo te sentiste con la ropa que llevabas hoy.") }
    
    // 1. CAMBIO: El parámetro debe ser opcional
    @Parameter(title: "Sensación y prendas")
    public var spokenFeedback: String?

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let textToProcess: String
        if let feedback = spokenFeedback {
            textToProcess = feedback
        } else {
            textToProcess = try await $spokenFeedback.requestValue("Dime cómo te sentiste y qué llevabas puesto.")
        }

        let extractedDTO = try await extractFeedbackWithAI(textToProcess)
        
        // 2. CAMBIO: Solicitar a Apple Intelligence/Siri el valor si viene vacío (ej. al pulsar el botón)
        
        let container = try ModelContainer(for: Schema([
            UserProfileEntity.self, LocationStateEntity.self, FeedbackRecordEntity.self,
            ClothingItemEntity.self, WeatherSnapshotEntity.self, WeatherEntity.self
        ]))
        let context = container.mainContext
        
        let catalog = (try? context.fetch(FetchDescriptor<ClothingItemEntity>())) ?? []
        
        let wornGarments = mapGarmentNames(extractedDTO.wornGarmentNames, catalog: catalog)
        let adjustedGarment = mapGarmentNames(extractedDTO.adjustedGarmentNames, catalog: catalog).first
        
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
        
        let collectionState: DailyCollectionState = {
            if extractedDTO.perception == .perfect {
                return .correct
            } else if adjustedGarment != nil || extractedDTO.physicalReaction == .adjustedClothing {
                return .adjusted
            } else {
                return .incorrect
            }
        }()

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
            collectionStateRaw: collectionState.rawValue
        )
        
        context.insert(weatherEntity)
        context.insert(newRecord)
        try? context.save()
        
        return .result(dialog: "Registro guardado correctamente. Climette ha calibrado tu Índice Térmico.")
    }
    
    private func extractFeedbackWithAI(_ text: String) async throws -> VoiceFeedbackExtractionDTO {
        let session = LanguageModelSession(
            instructions: "Tu tarea es analizar el texto del usuario sobre lo que vistió y cómo se sintió. Mapea la información estrictamente al esquema solicitado."
        )
        
        let response = try await session.respond(
            to: text,
            generating: VoiceFeedbackExtractionDTO.self
        )
        
        return response.content
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
