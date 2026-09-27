import SwiftUI
import WeatherKit

struct ClothingRecommendationView: View {
    // Datos de hoy
    let domainWeather: Weather?
    let resolvedOutfit: Outfit?
    let recommendationNotice: String?
    let matchStatus: HistoryMatchStatus

    // Datos de mañana que faltan:
    let tomorrowWeather: Weather?
    let tomorrowOutfit: Outfit?
    let tomorrowNotice: String?
    let tomorrowMatchStatus: HistoryMatchStatus

    let hourlyForecast: [HourlyForecastDTO]
    var onSelectFeedback: ((UUID) -> Void)? = nil

    @State private var selectedDayIndex: Int = 0

    private var tomorrowTemperatures: (min: Double, max: Double)? {
        let calendar = Calendar.current
        let tomorrowHours = hourlyForecast.filter { calendar.isDateInTomorrow($0.date) }
        guard !tomorrowHours.isEmpty else { return nil }
        let temps = tomorrowHours.map(\.temperature)
        guard let min = temps.min(), let max = temps.max() else { return nil }
        return (min, max)
    }

    var body: some View {
        VStack(spacing: 14) {
            daySelector

            TabView(selection: $selectedDayIndex) {
                dayCard(isToday: true)
                    .tag(0)

                dayCard(isToday: false)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(minHeight: 270)
        }
        .padding()
        .background(Color("SurfaceElevated"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var daySelector: some View {
        HStack(spacing: 8) {
            selectorButton(title: "Hoy", index: 0)
            selectorButton(title: "Mañana", index: 1)
        }
        .padding(3)
        .background(Color.secondary.opacity(0.12))
        .clipShape(Capsule())
    }

    private func selectorButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDayIndex = index
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selectedDayIndex == index ? Color("TextPrimary") : Color("TextSecondary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background {
                    if selectedDayIndex == index {
                        Capsule()
                            .fill(Color("SurfaceElevated"))
                            .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func dayCard(isToday: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Cabecera de temperatura
            HStack(spacing: 12) {
                Image(systemName: isToday ? "tshirt.fill" : "sun.max.fill")
                    .font(.title2)
                    .foregroundStyle(Color("BrandWarmth"))
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    if isToday {
                        if let weather = domainWeather {
                            Text("Sensación: \(Int(weather.personalThermalIndex))°")
                                .font(.headline)
                                .foregroundStyle(Color("TextPrimary"))
                            
                            Text(weather.hasThermalDistortion ? "Cambios de temperatura hoy" : "Temperatura estable")
                                .font(.subheadline)
                                .foregroundStyle(Color("TextSecondary"))
                        } else {
                            Text("Calculando temperatura...")
                                .font(.subheadline)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    } else {
                        if let temps = tomorrowTemperatures {
                            Text("Mín: \(Int(temps.min))° / Máx: \(Int(temps.max))°")
                                .font(.headline)
                                .foregroundStyle(Color("TextPrimary"))

                            Text("Pronóstico para mañana")
                                .font(.subheadline)
                                .foregroundStyle(Color("TextSecondary"))
                        } else {
                            Text("Pronóstico disponible en unas horas")
                                .font(.subheadline)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }
                }
                Spacer(minLength: 0)
            }

            if isToday {
                historyStatusBadge(status: matchStatus, notice: recommendationNotice)
            } else {
                historyStatusBadge(status: tomorrowMatchStatus, notice: tomorrowNotice)
            }

            Divider()
                .background(Color("SeparatorBase"))

            // Lista de prendas según el día activo
            let targetOutfit = isToday ? resolvedOutfit : tomorrowOutfit
            if let outfit = targetOutfit, !outfit.garments.isEmpty {
                garmentList(outfit: outfit)
            } else {
                Text(isToday ? "Calculando prendas..." : "Revisión de prendas para mañana disponible al actualizar.")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func historyStatusBadge(status: HistoryMatchStatus, notice: String?) -> some View {
        switch status {
        case .none:
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                Text(notice ?? "Sin datos previos similares. Recomendación base.")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 48)
            .background(Color.secondary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))

        case .exact:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text(notice ?? "Condiciones idénticas a un día validado previamente. Ropa confirmada.")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color("TextPrimary"))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 48)
            .background(Color.green.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))

        case .adjusted(let feedbackId):
            Button {
                onSelectFeedback?(feedbackId)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text(notice ?? "Ajustado por experiencia previa fallida.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color("TextPrimary"))
                        .lineLimit(2)
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("TextSecondary"))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 48)
                .background(Color.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    private func garmentList(outfit: Outfit) -> some View {
        VStack(spacing: 10) {
            ForEach(BodyZone.allCases, id: \.self) { zone in
                if let garmentsInZone = outfit.garmentsByZone[zone], !garmentsInZone.isEmpty {
                    ForEach(garmentsInZone) { garment in
                        GarmentRowView(zone: zone, garment: garment)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
