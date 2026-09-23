import SwiftUI

struct LocationStepView: View {
    @Binding var selectedLocationMode: LocationSelectionMode
    @Binding var manualCityName: String
    @FocusState private var isFocused: Bool

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
                        Text("Mantiene calibrada la recomendación climática local sin intervención manual.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .fixedSize(horizontal: false, vertical: true)

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
    }
}
