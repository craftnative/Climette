import Foundation

extension WeatherResponseDTO {
    public func toDomain(sensitivity: ThermalSensitivity = .normal) -> Weather {
        let calendar = Calendar.current
        
        let daytimeHours = hourlyForecast.filter { forecast in
            let hour = calendar.component(.hour, from: forecast.date)
            return hour >= 8 && hour <= 20
        }

        let evaluatedSlice = daytimeHours.isEmpty ? hourlyForecast : daytimeHours

        let avgPrecipitationChance = evaluatedSlice.isEmpty ? 0.0 :
            evaluatedSlice.map(\.precipitationChance).reduce(0, +) / Double(evaluatedSlice.count)

        let avgCloudCover = evaluatedSlice.isEmpty ? 0.0 :
            evaluatedSlice.map(\.cloudCoverFraction).reduce(0, +) / Double(evaluatedSlice.count)

        let precipitationState: PrecipitationState = avgPrecipitationChance >= 0.30 ? .rainy : .dry
        let skyCoverState: SkyCover = avgCloudCover >= 0.50 ? .overcast : .clear

        let calculatedITP = calculatePersonalThermalIndex(
            apparentTemperature: currentApparentTemperature,
            windSpeedKmh: currentWindSpeedKmh,
            sensitivity: sensitivity
        )

        return Weather(
            id: UUID(),
            temperature: currentTemperature,
            personalThermalIndex: calculatedITP,
            windSpeedKmh: currentWindSpeedKmh,
            precipitation: precipitationState,
            skyCover: skyCoverState,
            minTemperature: dailyForecast.minTemperature,
            maxTemperature: dailyForecast.maxTemperature,
            recordedAt: fetchedAt
        )
    }

    private func calculatePersonalThermalIndex(
        apparentTemperature: Double,
        windSpeedKmh: Double,
        sensitivity: ThermalSensitivity
    ) -> Double {
        var itp = apparentTemperature

        switch sensitivity {
        case .friolero:
            itp -= 2.0
            if windSpeedKmh > 15.0 {
                itp -= 1.0
            }
        case .normal:
            break
        case .caluroso:
            itp += 2.0
            if windSpeedKmh > 15.0 {
                itp += 0.5
            }
        }

        return (itp * 10).rounded() / 10
    }
}
