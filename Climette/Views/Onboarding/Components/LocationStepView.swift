import SwiftUI

struct LocationStepView: View {
    @Binding var selectedLocationMode: LocationSelectionMode
    @Binding var manualCityName: String

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                OnboardingHeaderView(
                    title: "Condiciones Locales",
                    description: "Climette necesita contrastar las condiciones microclimáticas de tu entorno real con tus capas de abrigo."
                )

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Origen de datos")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)

                        Picker("Modo de Ubicación", selection: $selectedLocationMode) {
                            Text("GPS Automático").tag(LocationSelectionMode.gps)
                            Text("Ingreso Manual").tag(LocationSelectionMode.manual)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Selección del origen de datos de ubicación")

                        Text(selectedLocationMode == .gps ? "Mantiene calibrada la recomendación climática local sin intervención manual." : "Establece una ubicación fija predeterminada para consultar el reporte.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if selectedLocationMode == .manual {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ubicación específica")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)

                            TextField("Ciudad (ej. Madrid)", text: $manualCityName)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .accessibilityLabel("Nombre de la ciudad")
                                .accessibilityHint("Introduce la ciudad para las previsiones climáticas.")
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
