import SwiftUI
import SwiftData
import WeatherKit
import CoreLocation
import MapKit

// MARK: - WeatherViewModel

@Observable
@MainActor
final class WeatherViewModel {
    var domainWeather: Weather?
    var currentDemand: ClimateDemand?
    var resolvedOutfit: Outfit?
    var recommendationNotice: String?

    var hourlyForecast: [HourlyForecastDTO] = []
    var attribution: WeatherAttribution?
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let thermalEngine = ThermalEngine()

    func fetchWeather(
        for location: CLLocation,
        sensitivity: ThermalSensitivity,
        history: [FeedbackRecord],
        wardrobe: [Garment],
        preference: ClothingPreference
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let (current, hourly, daily) = try await WeatherService.shared.weather(
                for: location,
                including: .current, .hourly, .daily
            )
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

            let weather = responseDTO.toDomain(sensitivity: sensitivity)
            self.domainWeather = weather

            let demand = thermalEngine.normalizeDemand(from: weather)
            self.currentDemand = demand

            let result = thermalEngine.resolveWithHistory(
                currentDemand: demand,
                history: history,
                wardrobe: wardrobe,
                preference: preference
            )

            switch result {
            case .validated(let outfit, let message):
                self.resolvedOutfit = outfit
                self.recommendationNotice = message

            case .warning(let outfit, let notice):
                self.resolvedOutfit = outfit
                self.recommendationNotice = notice

            case .discovery(let outfit):
                self.resolvedOutfit = outfit
                self.recommendationNotice = nil
            }

        } catch {
            self.errorMessage = "No se pudieron obtener las condiciones actuales."
            print("⚠️ WeatherKit Error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}

// MARK: - WeatherView

struct WeatherView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @Query private var locationStates: [LocationStateEntity]
    @Query private var userProfiles: [UserProfileEntity]
    @Query(sort: \FeedbackRecordEntity.timestamp, order: .reverse) private var feedbackEntities: [FeedbackRecordEntity]
    @Query private var clothingEntities: [ClothingItemEntity]

    @State private var viewModel = WeatherViewModel()
    @State private var resolvedLocation: CLLocation?
    @State private var locationPrimary: String = ""

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
            seedDefaultCatalogIfNeeded()
            await resolveAndFetchWeather()
        }
        .onChange(of: locationStates.first?.lastUpdated) { _, _ in
            Task { await resolveAndFetchWeather() }
        }
        .onChange(of: userProfiles.first?.updatedAt) { _, _ in
            Task { await resolveAndFetchWeather() }
        }
        .onChange(of: feedbackEntities.count) { _, _ in
            Task { await resolveAndFetchWeather() }
        }
        .onChange(of: clothingEntities.count) { _, _ in
            Task { await resolveAndFetchWeather() }
        }
    }
}

// MARK: - Subviews & Visual Components

extension WeatherView {

    private func headerView(for state: LocationStateEntity) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(locationPrimary.isEmpty ? activeCityName : locationPrimary)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("TextPrimary"))

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

            if let notice = viewModel.recommendationNotice {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color("AccentColor"))
                    Text(notice)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color("TextPrimary"))
                }
                .padding(10)
                .background(Color("AccentColor").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if let outfit = viewModel.resolvedOutfit, !outfit.garments.isEmpty {
                Divider()
                    .background(Color("SeparatorBase"))

                VStack(spacing: 12) {
                    ForEach(BodyZone.allCases, id: \.self) { zone in
                        if let garmentsInZone = outfit.garmentsByZone[zone], !garmentsInZone.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                Text(shortZoneName(for: zone))
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color("TextSecondary"))
                                    .frame(width: 90, alignment: .leading)
                                    .padding(.top, 2)

                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(garmentsInZone) { garment in
                                        HStack(spacing: 6) {
                                            Text(garment.resolvedDisplayName)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(Color("TextPrimary"))

                                            if let layer = garment.archetype.supportedLayer {
                                                Text(layer.rawValue)
                                                    .font(.caption2)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.secondary.opacity(0.15))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color("SurfaceElevated"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func shortZoneName(for zone: BodyZone) -> String {
        let raw = zone.rawValue.lowercased()
        if raw.contains("cabeza") { return "Cabeza" }
        if raw.contains("superior") || raw.contains("torso") { return "Torso" }
        if raw.contains("cuerpo") || raw.contains("vestido") { return "Cuerpo Entero" }
        if raw.contains("inferior") || raw.contains("pierna") { return "Piernas" }
        if raw.contains("pie") || raw.contains("calzado") { return "Calzado" }
        if raw.contains("comple") || raw.contains("accesor") { return "Accesorios" }
        return zone.rawValue
    }

    private func hourlyForecastTable() -> some View {
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

    private var currentClothingPreference: ClothingPreference {
        guard let rawValue = userProfiles.first?.clothingPreferenceRaw else { return .both }
        return ClothingPreference(rawValue: rawValue) ?? .both
    }

    private func seedDefaultCatalogIfNeeded() {
        try? DefaultWardrobeCatalogData.seedDatabaseIfNeeded(context: modelContext)
    }

    private func updatePlacemarkDetails(for location: CLLocation) async {
        guard let request = MKReverseGeocodingRequest(location: location) else { return }
        guard let mapItem = try? await request.mapItems.first else { return }

        self.locationPrimary = mapItem.address?.shortAddress ?? mapItem.name ?? ""
    }

    private func resolveAndFetchWeather() async {
        guard let state = locationStates.first else { return }
        let mode = LocationMode(rawValue: state.modeRaw) ?? .gps

        let historyRecords = feedbackEntities.compactMap { $0.toDomain() }
        let wardrobeGarments = clothingEntities.map { $0.toDomain() }

        if mode == .manual {
            if let lat = state.manualLatitude, let lon = state.manualLongitude {
                let location = CLLocation(latitude: lat, longitude: lon)
                self.resolvedLocation = location
                await updatePlacemarkDetails(for: location)
                await viewModel.fetchWeather(
                    for: location,
                    sensitivity: currentSensitivity,
                    history: historyRecords,
                    wardrobe: wardrobeGarments,
                    preference: currentClothingPreference
                )
            }
        } else {
            if let lat = state.gpsLatitude, let lon = state.gpsLongitude {
                let location = CLLocation(latitude: lat, longitude: lon)
                self.resolvedLocation = location
                await updatePlacemarkDetails(for: location)
                await viewModel.fetchWeather(
                    for: location,
                    sensitivity: currentSensitivity,
                    history: historyRecords,
                    wardrobe: wardrobeGarments,
                    preference: currentClothingPreference
                )
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
                        await viewModel.fetchWeather(
                            for: location,
                            sensitivity: currentSensitivity,
                            history: historyRecords,
                            wardrobe: wardrobeGarments,
                            preference: currentClothingPreference
                        )
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
