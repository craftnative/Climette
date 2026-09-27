import SwiftUI
import SwiftData
import CoreLocation
import MapKit

struct WeatherView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @Query private var locationStates: [LocationStateEntity]
    @Query private var userProfiles: [UserProfileEntity]
    @Query(sort: \FeedbackRecordEntity.timestamp, order: .reverse) private var feedbackEntities: [FeedbackRecordEntity]
    @Query private var clothingEntities: [ClothingItemEntity]

    @State private var viewModel = WeatherMainViewModel()
    @State private var resolvedLocation: CLLocation?
    @State private var locationPrimary: String = ""
    @State private var selectedFeedbackRecord: FeedbackRecordEntity?
    
    private var locationService: LocationServiceProtocol = LocationService()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if locationStates.first != nil {
                    WeatherHeaderView(
                        cityName: locationPrimary.isEmpty ? activeCityName : locationPrimary
                    )

                    ClothingRecommendationView(
                        domainWeather: viewModel.domainWeather,
                        resolvedOutfit: viewModel.resolvedOutfit,
                        recommendationNotice: viewModel.recommendationNotice,
                        matchStatus: resolvedMatchStatus,
                        hourlyForecast: viewModel.hourlyForecast,
                        onSelectFeedback: { feedbackId in
                            selectedFeedbackRecord = feedbackEntities.first(where: { $0.id == feedbackId })
                        }
                    )

                    if viewModel.isLoading {
                        ProgressView("Cargando clima...")
                            .padding(.top, 48)
                    } else if let error = viewModel.errorMessage {
                        WeatherErrorView(message: error)
                    } else if !viewModel.hourlyForecast.isEmpty {
                        HourlyForecastCalendarView(forecasts: viewModel.hourlyForecast)

                        if let attribution = viewModel.attribution {
                            WeatherAttributionView(attribution: attribution)
                        }
                    }
                } else {
                    WeatherEmptyStateView()
                }
            }
            .padding(.vertical)
        }
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Tiempo"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedFeedbackRecord) { record in
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Detalle de experiencia previa")
                        .font(.headline)
                        .padding(.top)

                    Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(Color("TextSecondary"))

                    Spacer()
                }
                .padding()
                .navigationTitle("Registro histórico")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
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

    private var resolvedMatchStatus: HistoryMatchStatus {
        guard let weather = viewModel.domainWeather, !feedbackEntities.isEmpty else {
            return .none
        }

        let currentWeatherTemp = weather.personalThermalIndex

        // Coincidencia exacta (mismo rango térmico +-1°C con percepción perfecta)
        let exactMatch = feedbackEntities.first { record in
            guard let snapshot = record.weatherSnapshot else { return false }
            let isTempClose = abs(snapshot.personalThermalIndex - currentWeatherTemp) <= 1.0
            return isTempClose && record.perceptionRaw == ThermalPerception.perfect.rawValue
        }
        if exactMatch != nil {
            return .exact
        }

        // Coincidencia ajustada (experiencia previa en rango similar donde se pasó frío o calor)
        let adjustedMatch = feedbackEntities.first { record in
            guard let snapshot = record.weatherSnapshot else { return false }
            let isTempNear = abs(snapshot.personalThermalIndex - currentWeatherTemp) <= 2.5
            return isTempNear && record.perceptionRaw != ThermalPerception.perfect.rawValue
        }
        if let adjusted = adjustedMatch {
            return .adjusted(feedbackId: adjusted.id)
        }

        return .none
    }

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
}
