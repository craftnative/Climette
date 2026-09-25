import SwiftUI
import SwiftData
import WeatherKit
import CoreLocation
import MapKit

@Observable
@MainActor
final class WeatherViewModel {
    var domainWeather: Weather?
    var hourlyForecast: [HourlyForecastDTO] = []
    var attribution: WeatherAttribution?
    var isLoading: Bool = false
    var errorMessage: String? = nil

    func fetchWeather(for location: CLLocation, sensitivity: ThermalSensitivity) async {
        isLoading = true
        errorMessage = nil

        do {
            let (current, hourly, daily) = try await WeatherService.shared.weather(for: location, including: .current, .hourly, .daily)
            self.attribution = try await WeatherService.shared.attribution

            let now = Date.now
            let calendar = Calendar.current

            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
                  let endOfTomorrow = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: tomorrow) else {
                isLoading = false
                return
            }

            let filteredHourly = hourly.filter { forecast in
                forecast.date >= now && forecast.date <= endOfTomorrow
            }

            self.hourlyForecast = filteredHourly.map {
                HourlyForecastDTO(
                    date: $0.date,
                    temperature: $0.temperature.value,
                    apparentTemperature: $0.apparentTemperature.value,
                    windSpeedKmh: $0.wind.speed.converted(to: .kilometersPerHour).value,
                    precipitationChance: $0.precipitationChance,
                    cloudCoverFraction: $0.cloudCover
                )
            }

            guard let todayDaily = daily.first(where: { calendar.isDate($0.date, inSameDayAs: now) }) else {
                isLoading = false
                return
            }

            let dailyDTO = DailyForecastDTO(
                date: todayDaily.date,
                minTemperature: todayDaily.lowTemperature.value,
                maxTemperature: todayDaily.highTemperature.value
            )

            let responseDTO = WeatherResponseDTO(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                fetchedAt: now,
                currentTemperature: current.temperature.value,
                currentApparentTemperature: current.apparentTemperature.value,
                currentWindSpeedKmh: current.wind.speed.converted(to: .kilometersPerHour).value,
                hourlyForecast: self.hourlyForecast,
                dailyForecast: dailyDTO
            )

            self.domainWeather = responseDTO.toDomain(sensitivity: sensitivity)

        } catch {
            self.errorMessage = "No se pudieron obtener las condiciones actuales."
            print("⚠️ WeatherKit Error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}

struct WeatherView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var locationStates: [LocationStateEntity]
    @Query private var userProfiles: [UserProfileEntity]

    @State private var viewModel = WeatherViewModel()
    @State private var resolvedLocation: CLLocation?
    @State private var locationPrimary: String = ""
    @State private var locationCountry: String = ""

    private var locationService: LocationServiceProtocol = LocationService()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let state = locationStates.first {
                    headerView(for: state)
                    clothingBanner()

                    if viewModel.isLoading {
                        ProgressView("Cargando clima...")
                            .padding(.top, 48)
                    } else if let error = viewModel.errorMessage {
                        errorView(message: error)
                    } else if !viewModel.hourlyForecast.isEmpty {
                        hourlyForecastTable()

                        if let attribution = viewModel.attribution {
                            Link(destination: attribution.legalPageURL) {
                                AsyncImage(url: colorScheme == .dark ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 15)
                                } placeholder: {
                                    Text("Datos de Apple Weather")
                                        .font(.caption)
                                }
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                        }
                    }
                } else {
                    emptyStateView()
                }
            }
            .padding(.vertical)
        }
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Tiempo"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await resolveAndFetchWeather()
        }
        .onChange(of: locationStates.first?.lastUpdated) { _, _ in
            Task {
                await resolveAndFetchWeather()
            }
        }
        .onChange(of: userProfiles.first?.updatedAt) { _, _ in
            Task {
                await resolveAndFetchWeather()
            }
        }
    }
}

// MARK: - Subviews & Components

extension WeatherView {

    private func headerView(for state: LocationStateEntity) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(locationPrimary.isEmpty ? activeCityName : locationPrimary)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("TextPrimary"))

            if !locationCountry.isEmpty {
                Text(locationCountry)
                    .font(.footnote)
                    .foregroundStyle(Color("TextSecondary"))
            }

            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
                .textCase(.uppercase)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func clothingBanner() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "tshirt.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color("BrandWarmth"))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Recomendación de ropa")
                        .font(.headline)
                        .foregroundStyle(Color("TextPrimary"))

                    if let weather = viewModel.domainWeather {
                        Text("ITP Activo: \(weather.personalThermalIndex.formatted())°")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AccentColor"))

                        Text(weather.hasThermalDistortion ? "Fuerte amplitud térmica diaria" : "Condiciones estables")
                            .font(.caption)
                            .foregroundStyle(Color("TextSecondary"))
                    } else {
                        Text("Calculando Índice Térmico...")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
                Spacer()
            }
            
            // Placeholder para inyectar Outfit estructurado si estuviera en viewModel
            // Ejemplo de renderizado de la recomendación multi-zona iterando BodyZone
            /*
            if let recommendation = viewModel.currentRecommendation {
                Divider().background(Color("SeparatorBase"))
                ForEach(BodyZone.allCases, id: \.self) { zone in
                    if let garments = recommendation.outfit.garmentsByZone[zone], !garments.isEmpty {
                        HStack {
                            Text(zone.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color("TextSecondary"))
                                .frame(width: 80, alignment: .leading)
                            
                            Text(garments.map { $0.resolvedDisplayName }.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(Color("TextPrimary"))
                        }
                    }
                }
            }
            */
        }
        .padding()
        .background(Color("SurfaceElevated"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func hourlyForecastTable() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Previsión por horas")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))
                .padding(.horizontal)

            HStack(spacing: 0) {
                // Columna fija de etiquetas
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

                // Contenido desplazable horizontalmente
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 24) {
                        ForEach(viewModel.hourlyForecast, id: \.date) { hour in
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

    private func errorView(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            Text(message)
                .font(.body)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 48)
    }

    private func emptyStateView() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("BrandWarmth"))
                .accessibilityHidden(true)

            Text("weather_empty_title")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color("TextPrimary"))

            Text("weather_empty_description")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("TextSecondary"))
                .padding(.horizontal, 32)
        }
        .padding(.top, 48)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Logic & Location Resolution

extension WeatherView {

    private var activeCityName: String {
        guard let state = locationStates.first else { return "Ubicación desconocida" }
        let mode = LocationMode(rawValue: state.modeRaw) ?? .gps
        return mode == .manual ? (state.manualCityName ?? "Desconocido") : (state.gpsCityName ?? "Desconocido")
    }

    private var currentSensitivity: ThermalSensitivity {
        guard let rawValue = userProfiles.first?.sensitivityRaw else { return .normal }
        return ThermalSensitivity(rawValue: rawValue) ?? .normal
    }

    private func updatePlacemarkDetails(for location: CLLocation) async {
        guard let request = MKReverseGeocodingRequest(location: location) else { return }
        guard let mapItem = try? await request.mapItems.first else { return }

        let address = mapItem.address
        let locality = address?.shortAddress ?? ""
        
        self.locationPrimary = locality
        self.locationCountry = mapItem.name ?? ""
    }

    private func resolveAndFetchWeather() async {
        guard let state = locationStates.first else { return }
        let mode = LocationMode(rawValue: state.modeRaw) ?? .gps

        if mode == .manual {
            if let lat = state.manualLatitude, let lon = state.manualLongitude {
                let location = CLLocation(latitude: lat, longitude: lon)
                self.resolvedLocation = location
                await updatePlacemarkDetails(for: location)
                await viewModel.fetchWeather(for: location, sensitivity: currentSensitivity)
            }
        } else {
            if let lat = state.gpsLatitude, let lon = state.gpsLongitude {
                let location = CLLocation(latitude: lat, longitude: lon)
                self.resolvedLocation = location
                await updatePlacemarkDetails(for: location)
                await viewModel.fetchWeather(for: location, sensitivity: currentSensitivity)
            } else {
                let auth = await locationService.requestAuthorization()
                if auth == .authorized {
                    if let coord = try? await locationService.getCurrentLocation() {
                        state.gpsLatitude = coord.latitude
                        state.gpsLongitude = coord.longitude
                        state.gpsCityName = try? await locationService.reverseGeocode(coordinate: coord)
                        state.lastUpdated = .now
                        try? modelContext.save()

                        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                        self.resolvedLocation = location
                        await updatePlacemarkDetails(for: location)
                        await viewModel.fetchWeather(for: location, sensitivity: currentSensitivity)
                    }
                }
            }
        }
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
