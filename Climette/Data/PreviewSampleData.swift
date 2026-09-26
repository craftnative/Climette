import Foundation
import SwiftData

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
            fatalError("No se pudo instanciar el ModelContainer en memoria para el Preview.")
        }
        
        let context = container.mainContext
        let calendar = Calendar.current
        let now = Date.now
        
        // 1. Perfil de usuario y ubicación base
        let userProfile = UserProfileEntity(
            sensitivityRaw: ThermalSensitivity.normal.rawValue,
            weekdayMorningHour: 7,
            weekdayMorningMinute: 45,
            nightFeedbackHour: 20,
            nightFeedbackMinute: 30,
            isWeekendMuted: false,
            lastActiveTimestamp: now,
            updatedAt: now
        )
        context.insert(userProfile)
        
        let locationState = LocationStateEntity(
            modeRaw: LocationMode.gps.rawValue,
            gpsLatitude: 38.3452,
            gpsLongitude: -0.4810,
            gpsCityName: "Alicante",
            lastUpdated: now
        )
        context.insert(locationState)
        
        // 2. Prendas representativas
        let tShirt = ClothingItemEntity(
            archetypeId: "arch_top_base_cotton_tee",
            canonicalName: "Camiseta algodón",
            bodyZoneRaw: BodyZone.upperTorso.rawValue,
            layerRaw: ClothingLayer.base.rawValue,
            baseThermal: 2,
            baseWind: 1,
            baseWater: 1
        )
        let jeans = ClothingItemEntity(
            archetypeId: "arch_bot_jeans_standard",
            canonicalName: "Vaquero estándar",
            bodyZoneRaw: BodyZone.lowerBody.rawValue,
            baseThermal: 4,
            baseWind: 4,
            baseWater: 1
        )
        let jacket = ClothingItemEntity(
            archetypeId: "arch_top_outer_rain_jacket",
            canonicalName: "Chubasquero técnico",
            bodyZoneRaw: BodyZone.upperTorso.rawValue,
            layerRaw: ClothingLayer.outer.rawValue,
            baseThermal: 3,
            baseWind: 7,
            baseWater: 9
        )
        let sweater = ClothingItemEntity(
            archetypeId: "arch_top_mid_fine_knit",
            canonicalName: "Jersey de punto",
            bodyZoneRaw: BodyZone.upperTorso.rawValue,
            layerRaw: ClothingLayer.mid.rawValue,
            baseThermal: 4,
            baseWind: 2,
            baseWater: 1
        )
        
        context.insert(tShirt)
        context.insert(jeans)
        context.insert(jacket)
        context.insert(sweater)
        
        // 3. Registros de 90 días hacia atrás
        for daysAgo in 0..<90 {
            guard let targetDate = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
            
            let baseTemp = 24.0 - (Double(daysAgo) * 0.15)
            let tempVariance = Double((daysAgo * 7) % 9) - 4.0
            let temperature = (baseTemp + tempVariance).rounded()
            let windSpeed = Double(8 + ((daysAgo * 13) % 28))
            let isRain = (daysAgo % 5 == 0)
            let isSnow = (temperature <= 0.0)
            let isOvercast = isRain || (daysAgo % 3 == 0)
            
            let collectionState: DailyCollectionState = {
                if daysAgo == 1 {
                    return .adjusted
                }
                switch daysAgo % 7 {
                case 0, 1, 2, 3: return .correct
                case 4:          return .adjusted
                case 5:          return .ignored
                default:         return .deleted
                }
            }()
            
            let perception: ThermalPerception = switch collectionState {
            case .correct:  .perfect
            case .adjusted: (daysAgo % 2 == 0) ? .feltCold : .feltHot
            default:        .perfect
            }
            
            let weatherSnapshot = WeatherSnapshotEntity(
                id: UUID(),
                temperature: temperature,
                personalThermalIndex: temperature - 1.0,
                windSpeedKmh: windSpeed,
                precipitationRaw: (isRain || isSnow) ? PrecipitationState.rainy.rawValue : PrecipitationState.dry.rawValue,
                skyCoverRaw: isOvercast ? SkyCover.overcast.rawValue : SkyCover.clear.rawValue,
                minTemperature: temperature - 4.0,
                maxTemperature: temperature + 4.0,
                recordedAt: targetDate
            )
            context.insert(weatherSnapshot)
            
            let feedback = FeedbackRecordEntity(
                id: UUID(),
                timestamp: targetDate,
                weatherSnapshot: weatherSnapshot,
                originPriorityRaw: 1,
                evaluatedPeriodRaw: DayEvaluationPeriod.allDay.rawValue,
                wornGarments: nil,
                perceptionRaw: perception.rawValue,
                isIndoorDistortion: (daysAgo % 11 == 0),
                collectionStateRaw: collectionState.rawValue
            )
            context.insert(feedback)
            
            if daysAgo == 1 {
                // Modificación en los últimos 3 días: estado .adjusted y cambio explícito a chaqueta y vaquero por sensación de frío
                feedback.wornGarments = [tShirt, jacket, jeans]
            } else if isRain || isSnow {
                feedback.wornGarments = [tShirt, sweater, jacket, jeans]
            } else if temperature < 15.0 {
                feedback.wornGarments = [tShirt, sweater, jeans]
            } else {
                feedback.wornGarments = [tShirt, jeans]
            }
        }
        
        try? context.save()
        return container
    }
}
