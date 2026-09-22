import SwiftUI

struct LocationStepView: View {
    @Binding var selectedLocationMode: LocationSelectionMode
    @Binding var manualCityName: String

    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(
                title: "Condiciones Locales",
                description: "Climette necesita contrastar las condiciones microclimáticas de tu entorno real con tus capas de abrigo."
            )

            Form {
                Section {
                    Picker("Modo de Ubicación", selection: $selectedLocationMode) {
                        Text("GPS Automático").tag(LocationSelectionMode.gps)
                        Text("Ingreso Manual").tag(LocationSelectionMode.manual)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Origen de datos")
                } footer: {
                    Text(selectedLocationMode == .gps ? "Mantiene calibrada la recomendación climática local sin intervención manual." : "Establece una ubicación fija predeterminada para consultar el reporte.")
                }

                if selectedLocationMode == .manual {
                    Section {
                        TextField("Ciudad (ej. Madrid)", text: $manualCityName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Ubicación específica")
                    }
                }
            }
        }
    }
}
