import Foundation

public struct ClimateDemand: Sendable, Equatable {
    public let thermal: Int
    public let wind: Int
    public let humidity: Int
    public let requiresRainProtection: Bool
    
    public init(thermal: Int, wind: Int, humidity: Int, requiresRainProtection: Bool) {
        self.thermal = thermal
        self.wind = wind
        self.humidity = humidity
        self.requiresRainProtection = requiresRainProtection
    }
}

public enum HierarchyResult: Sendable {
    case validated(garments: [Garment], message: String)
    case warning(suggestedGarments: [[Garment]], notice: String)
    case discovery(demand: ClimateDemand)
}

public struct ThermalEngine: Sendable {
    
    public init() {}
    
    public func resolveWithHistory(
        currentDemand: ClimateDemand,
        history: [FeedbackRecord],
        wardrobe: [Garment]
    ) -> HierarchyResult {
        let validHistory = history.filter { !$0.isIndoorDistortion }
        
        var bestMatch: (record: FeedbackRecord, distance: Int)?
        var closestWarning: (record: FeedbackRecord, distance: Int)?
        
        for record in validHistory {
            let historicalDemand = normalizeDemand(from: record.weatherSnapshot)
            
            let diffT = abs(currentDemand.thermal - historicalDemand.thermal)
            let diffV = abs(currentDemand.wind - historicalDemand.wind)
            let diffH = abs(currentDemand.humidity - historicalDemand.humidity)
            
            let totalDistance = (diffT * 2) + diffV + diffH
            
            if totalDistance <= 1 && record.perception == .perfect {
                if let current = bestMatch {
                    if totalDistance < current.distance {
                        bestMatch = (record, totalDistance)
                    }
                } else {
                    bestMatch = (record, totalDistance)
                }
            }
            
            if diffT <= 1 && (record.perception == .feltCold || record.perception == .feltHot) {
                if let current = closestWarning {
                    if totalDistance < current.distance {
                        closestWarning = (record, totalDistance)
                    }
                } else {
                    closestWarning = (record, totalDistance)
                }
            }
        }
        
        if let match = bestMatch {
            return .validated(
                garments: match.record.wornOutfit.garments,
                message: "Condiciones idénticas a un día validado previamente. Ropa confirmada."
            )
        }
        
        if let failure = closestWarning {
            switch failure.record.perception {
            case .feltCold:
                let adjustedDemand = ClimateDemand(
                    thermal: min(currentDemand.thermal + 1, 10),
                    wind: currentDemand.wind,
                    humidity: currentDemand.humidity,
                    requiresRainProtection: currentDemand.requiresRainProtection
                )
                let garments = evaluateCompatibility(demand: adjustedDemand, wardrobe: wardrobe)
                return .warning(
                    suggestedGarments: garments,
                    notice: "Aviso: La última vez pasaste frío con este clima. Se añade mayor aislamiento."
                )
                
            case .feltHot:
                let adjustedDemand = ClimateDemand(
                    thermal: max(currentDemand.thermal - 1, 1),
                    wind: currentDemand.wind,
                    humidity: currentDemand.humidity,
                    requiresRainProtection: currentDemand.requiresRainProtection
                )
                let garments = evaluateCompatibility(demand: adjustedDemand, wardrobe: wardrobe)
                return .warning(
                    suggestedGarments: garments,
                    notice: "Aviso: La última vez pasaste calor con este clima. Se reduce la carga térmica."
                )
                
            default:
                break
            }
        }
        
        return .discovery(demand: currentDemand)
    }
    
    private func evaluateCompatibility(demand: ClimateDemand, wardrobe: [Garment]) -> [[Garment]] {
        return []
    }
    
    private func normalizeDemand(from weather: Weather) -> ClimateDemand {
        let normalizedThermal = max(1, min(10, Int((weather.personalThermalIndex + 10) / 4.0)))
        let normalizedWind = max(1, min(10, Int(weather.windSpeedKmh / 10.0)))
        let normalizedHumidity = weather.precipitation == .rainy ? 8 : 3
        
        return ClimateDemand(
            thermal: normalizedThermal,
            wind: normalizedWind,
            humidity: normalizedHumidity,
            requiresRainProtection: weather.precipitation == .rainy
        )
    }
}
