import SwiftUI
import CoreLocation

struct LocationStepView: View {
    @Binding var selectedLocationMode: LocationSelectionMode
    @Binding var manualCityName: String
    
    var locationService: LocationServiceProtocol = LocationService()
    
    @FocusState private var isFocused: Bool
    @State private var isLocating: Bool = false
    @State private var locationErrorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                OnboardingHeaderView(
                    title: "Condiciones Locales",
                    description: "Ajusta las recomendaciones según el clima de tu zona."
                )

                VStack(spacing: 24) {
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    case .manual:
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ubicación específica")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                    .accessibilityHidden(true)

                                TextField("Buscar ubicación", text: $manualCityName, axis: .vertical)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .focused($isFocused)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        isFocused = false
                                    }
                                    .accessibilityLabel(String(localized: "Buscar ubicación"))
                            }
                            .padding(10)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                                    .frame(height: 200)

                                Text("MAPA")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(String(localized: "Área del mapa interactivo"))
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .task(id: selectedLocationMode) {
            guard selectedLocationMode == .gps else {
                locationErrorMessage = nil
                isLocating = false
                return
            }
            await resolveGPSLocation()
        }
    }

    private func resolveGPSLocation() async {
        isLocating = true
        locationErrorMessage = nil

        let status = await locationService.requestAuthorization()
        guard status == .authorized else {
            isLocating = false
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
