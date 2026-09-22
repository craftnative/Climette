import SwiftUI

struct ThermalProfileStepView: View {
    @Binding var selectedSensitivity: ThermalSensitivity

    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(
                title: "Sensibilidad Térmica",
                description: "Calibra cómo percibes las variaciones de temperatura para ajustar tu Índice Térmico Personalizado."
            )

            Form {
                Section {
                    ForEach(ThermalSensitivity.allCases, id: \.self) { sensitivity in
                        Button {
                            selectedSensitivity = sensitivity
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(sensitivity.rawValue)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(description(for: sensitivity))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedSensitivity == sensitivity {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .tint(.primary)
                    }
                }
            }
            .scrollDisabled(true)
        }
    }

    private func description(for sensitivity: ThermalSensitivity) -> String {
        switch sensitivity {
        case .friolero: return "Sueles necesitar una capa adicional frente a la media."
        case .normal: return "Equilibrio estándar respecto a las condiciones registradas."
        case .caluroso: return "Prefieres prendas más ligeras o toleras menor abrigo."
        }
    }
}
