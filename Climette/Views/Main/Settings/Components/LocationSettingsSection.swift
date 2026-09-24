import SwiftUI
import SwiftData

struct LocationSettingsSection: View {
    @Bindable var locationState: LocationStateEntity
    var locationService: LocationServiceProtocol = LocationService()

    @State private var modeSelection: LocationSelectionMode = .gps
    @State private var cityName: String = ""
    @State private var showMapSheet: Bool = false

    var body: some View {
        Section {
            Picker("Origen de datos", selection: $modeSelection) {
                Text("GPS").tag(LocationSelectionMode.gps)
                Text("Manual").tag(LocationSelectionMode.manual)
            }
            .pickerStyle(.segmented)
            .onChange(of: modeSelection) { _, newMode in
                applyModeChange(newMode)
            }

            if modeSelection == .manual {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ubicación configurada")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(cityName.isEmpty ? "Sin ubicación definida" : cityName)
                            .font(.body)
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    Spacer()
                    Button("Cambiar") {
                        showMapSheet = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(Color("AccentColor"))
                    Text(locationState.cityName ?? "Ubicación dinámica")
                        .font(.body)
                        .foregroundStyle(Color("TextPrimary"))
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
        .sheet(isPresented: $showMapSheet) {
            NavigationStack {
                VStack {
                    InteractiveCityMapView(cityName: $cityName, locationService: locationService)
                }
                .padding()
                .background(Color("BackgroundBase"))
                .navigationTitle("Seleccionar ciudad")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Listo") {
                            locationState.cityName = cityName
                            locationState.modeRaw = "manualCity"
                            locationState.lastUpdated = .now
                            showMapSheet = false
                        }
                    }
                }
            }
        }
        .task {
            if locationState.modeRaw == "manualCity" {
                modeSelection = .manual
                cityName = locationState.cityName ?? ""
            } else {
                modeSelection = .gps
            }
        }
    }

    private func applyModeChange(_ mode: LocationSelectionMode) {
        if mode == .gps {
            locationState.modeRaw = "foregroundGPS"
            locationState.lastUpdated = .now
            Task {
                if let coord = try? await locationService.getCurrentLocation() {
                    locationState.latitude = coord.latitude
                    locationState.longitude = coord.longitude
                    locationState.cityName = try? await locationService.reverseGeocode(coordinate: coord)
                }
            }
        } else {
            locationState.modeRaw = "manualCity"
            locationState.lastUpdated = .now
        }
    }
}
