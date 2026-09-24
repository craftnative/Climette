import SwiftUI
import CoreLocation

struct LocationStepView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    
    @Binding var selectedLocationMode: LocationSelectionMode
    @Binding var manualCityName: String
    
    var locationService: LocationServiceProtocol = LocationService()
    
    @FocusState private var isFocused: Bool
    @State private var isLocating: Bool = false
    @State private var locationErrorMessage: String?
    @State private var isUnauthorized: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(
                title: "Condiciones Locales",
                description: "Ajusta las recomendaciones según el clima de tu zona."
            )

            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Origen de datos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Picker("Origen de datos", selection: $selectedLocationMode) {
                        Text("Manual").tag(LocationSelectionMode.manual)
                        Text("GPS").tag(LocationSelectionMode.gps)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
            
            VStack {
                switch selectedLocationMode {
                case .gps:
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            if isLocating {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(Color.accentColor)
                                    .accessibilityHidden(true)
                            }

                            Text("Mantiene calibrada la recomendación climática local sin intervención manual.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let locationErrorMessage {
                            Text(locationErrorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if isUnauthorized {
                            Button {
                                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                    openURL(settingsURL)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Abrir Ajustes")
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption2)
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                case .manual:
                    InteractiveCityMapView(cityName: $manualCityName)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.bottom, 24)
        .task(id: selectedLocationMode) {
            guard selectedLocationMode == .gps else {
                locationErrorMessage = nil
                isLocating = false
                isUnauthorized = false
                return
            }
            await resolveGPSLocation()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, selectedLocationMode == .gps else { return }
            Task { @MainActor in
                await resolveGPSLocation()
            }
        }
    }

    private func resolveGPSLocation() async {
        isLocating = true
        locationErrorMessage = nil
        isUnauthorized = false

        let status = await locationService.requestAuthorization()
        guard status == .authorized else {
            isLocating = false
            isUnauthorized = true
            locationErrorMessage = LocationServiceError.unauthorized.localizedDescription
            return
        }

        do {
            let coordinate = try await locationService.getCurrentLocation()
            if let resolvedCity = try await locationService.reverseGeocode(coordinate: coordinate) {
                manualCityName = resolvedCity
            }
        } catch let error as LocalizedError {
            locationErrorMessage = error.errorDescription ?? error.localizedDescription
        } catch {
            locationErrorMessage = error.localizedDescription
        }

        isLocating = false
    }
}

#Preview {
    LocationStepView(
        selectedLocationMode: .constant(.manual),
        manualCityName: .constant("")
    )
}
