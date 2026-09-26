import SwiftUI

struct ClothingPreferenceStepView: View {
    @Binding var selectedPreference: ClothingPreference

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                OnboardingHeaderView(
                    title: "¿Qué tipo de prendas sueles usar?",
                    description: "Ayúdanos a filtrar tu armario para sugerirte solo el estilo que prefieras llevar."
                )

                VStack(spacing: 16) {
                    ForEach(ClothingPreference.allCases, id: \.self) { preference in
                        Button {
                            selectedPreference = preference
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey(preference.rawValue))
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(description(for: preference))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                if selectedPreference == preference {
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
                        .accessibilityAddTraits(selectedPreference == preference ? [.isButton, .isSelected] : .isButton)
                        .accessibilityHint(String(localized: "Selecciona tu preferencia de prendas para el tren inferior."))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
    }

    private func description(for preference: ClothingPreference) -> LocalizedStringKey {
        switch preference {
        case .pantsOnly: return "Solo se sugerirán pantalones o pantalones cortos."
        case .skirtsAndDressesOnly: return "Solo se sugerirán faldas o vestidos enteros."
        case .both: return "El sistema elegirá libremente entre ambas opciones."
        }
    }
}
