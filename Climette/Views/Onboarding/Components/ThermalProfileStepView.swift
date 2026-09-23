import SwiftUI

struct ThermalProfileStepView: View {
    @Binding var selectedSensitivity: ThermalSensitivity

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                OnboardingHeaderView(
                    title: "Sensibilidad Térmica",
                    description: "Calibra cómo percibes las variaciones de temperatura para ajustar tu Índice Térmico Personalizado."
                )

                VStack(spacing: 16) {
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
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                if selectedSensitivity == sensitivity {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.accentColor)
                                        .accessibilityHidden(true)
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .tint(.primary)
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(selectedSensitivity == sensitivity ? [.isButton, .isSelected] : .isButton)
                        .accessibilityHint("Selecciona tu perfil de sensibilidad térmica.")
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
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
