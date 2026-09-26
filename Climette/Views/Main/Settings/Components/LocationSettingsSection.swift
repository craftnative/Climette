import SwiftUI
import SwiftData

struct LocationSettingsSection: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var locationState: LocationStateEntity
    var locationService: LocationServiceProtocol = LocationService()

    @State private var modeSelection: LocationMode = .gps
    @State private var tempCityName: String = ""
    @State private var tempCoordinate: GeographicCoordinate? = nil
    @State private var showMapSheet: Bool = false
    @State private var isSyncingFromModel: Bool = false

    var body: some View {
        Section {
            Picker("Origen de datos", selection: $modeSelection) {
                Text("GPS").tag(LocationMode.gps)
                Text("Manual").tag(LocationMode.manual)
            }
            .pickerStyle(.segmented)
            .onChange(of: modeSelection) { _, newMode in
                guard !isSyncingFromModel else { return }
                applyModeChange(newMode)
            }

            if modeSelection == .manual {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ubicación configurada")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text((locationState.manualCityName?.isEmpty ?? true) ? "Sin ubicación definida" : locationState.manualCityName!)
                            .font(.body)
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    Spacer()
                    Button("Cambiar") {
                        tempCityName = locationState.manualCityName ?? ""
                        if let lat = locationState.manualLatitude, let lon = locationState.manualLongitude {
                            tempCoordinate = GeographicCoordinate(latitude: lat, longitude: lon)
                        } else {
                            tempCoordinate = nil
                        }
                        showMapSheet = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
                }
                .sheet(isPresented: $showMapSheet) {
                    NavigationStack {
                        VStack {
                            InteractiveCityMapView(
                                cityName: $tempCityName,
                                coordinate: $tempCoordinate
                            )
                        }
                        .padding()
                        .background(Color("BackgroundBase"))
                        .navigationTitle("Seleccionar ciudad")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Listo") {
                                    locationState.manualCityName = tempCityName
                                    if let c = tempCoordinate {
                                        locationState.manualLatitude = c.latitude
                                        locationState.manualLongitude = c.longitude
                                    }
                                    locationState.modeRaw = LocationMode.manual.rawValue
                                    locationState.lastUpdated = .now
                                    
                                    persistContext()
                                    showMapSheet = false
                                }
                            }
                        }
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(locationState.gpsCityName != nil ? Color("AccentColor") : .red)
                    
                    if let cityName = locationState.gpsCityName {
                        Text(cityName)
                            .font(.body)
                            .foregroundStyle(Color("TextPrimary"))
                    } else {
                        Text("No hay permiso de localización")
                            .font(.body)
                            .foregroundStyle(.red)
                    }
                }
            }
        } header: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ubicación y Clima")
                Text("El Índice Térmico requiere condiciones locales.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listRowBackground(Color("SurfaceElevated"))
        .task(id: locationState.modeRaw) {
            syncStateFromModel()
        }
    }

    private func syncStateFromModel() {
        isSyncingFromModel = true
        modeSelection = LocationMode(rawValue: locationState.modeRaw) ?? .gps
        isSyncingFromModel = false
    }

    private func applyModeChange(_ mode: LocationMode) {
        locationState.modeRaw = mode.rawValue
        locationState.lastUpdated = .now
        persistContext()
        
        if mode == .gps {
            Task {
                let status = await locationService.requestAuthorization()
                if status == .authorized {
                    if let coord = try? await locationService.getCurrentLocation() {
                        locationState.gpsLatitude = coord.latitude
                        locationState.gpsLongitude = coord.longitude
                        locationState.gpsCityName = try? await locationService.reverseGeocode(coordinate: coord)
                        locationState.lastUpdated = .now
                        persistContext()
                    }
                }
            }
        }
    }

    private func persistContext() {
        do {
            try modelContext.save()
        } catch {
            print("⚠️ Error al persistir LocationStateEntity en Settings: \(error)")
        }
    }
}
