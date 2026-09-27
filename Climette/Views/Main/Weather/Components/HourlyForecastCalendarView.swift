import SwiftUI

struct HourlyForecastCalendarView: View {
    let forecasts: [HourlyForecastDTO]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Previsión por horas")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))
                .padding(.horizontal)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    tableLabel("Hora", icon: "clock")
                    tableLabel("Temp", icon: "thermometer.medium")
                    tableLabel("Lluvia", icon: "drop.fill")
                    tableLabel("Nubosidad", icon: "cloud.sun.fill")
                    tableLabel("Viento", icon: "wind")
                }
                .padding(.horizontal)
                .background(Color("SurfaceElevated"))
                .zIndex(1)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 24) {
                        ForEach(forecasts, id: \.date) { hour in
                            VStack(spacing: 20) {
                                tableCell(formatTime(hour.date), isHighlight: isNewDay(hour.date))
                                tableCell(String(format: "%.0f°", hour.temperature))
                                tableCell(hour.precipitationChance.formatted(.percent))
                                tableCell(hour.cloudCoverFraction.formatted(.percent))
                                tableCell(String(format: "%.0f km/h", hour.windSpeedKmh))
                            }
                        }
                    }
                    .padding(.trailing, 20)
                }
            }
        }
        .padding(.vertical)
        .background(Color("SurfaceElevated"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func tableLabel(_ text: String, icon: String? = nil) -> some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .frame(width: 16, alignment: .center)
            }
            Text(text)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Color("TextSecondary"))
        .frame(height: 24, alignment: .leading)
    }

    private func tableCell(_ text: String, isHighlight: Bool = false) -> some View {
        Text(text)
            .font(.subheadline.weight(isHighlight ? .bold : .regular))
            .foregroundStyle(isHighlight ? Color("AccentColor") : Color("TextPrimary"))
            .frame(height: 24, alignment: .center)
            .fixedSize(horizontal: true, vertical: false)
    }

    private func formatTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)

        if calendar.isDateInToday(date) {
            return String(format: "%02d:00", hour)
        } else if calendar.isDateInTomorrow(date) {
            return hour == 0 ? "Mañana" : String(format: "%02d:00", hour)
        } else {
            return String(format: "%02d:00", hour)
        }
    }

    private func isNewDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.hour, from: date) == 0
    }
}
