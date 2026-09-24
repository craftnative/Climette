import SwiftUI

struct RoutineStepView: View {
    @Binding var weekdayMorningAlert: Date
    @Binding var nightReview: Date
    @Binding var muteWeekends: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                OnboardingHeaderView(
                    title: "Rutina",
                    description: "Configura las horas de aviso para la recomendación matutina y el registro nocturno."
                )

                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        DatePicker(
                            selection: $weekdayMorningAlert,
                            displayedComponents: .hourAndMinute
                        ) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recomendación de ropa")
                                    .font(.headline)
                                Text("Por la mañana")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                        }

                        Divider()

                        DatePicker(
                            selection: $nightReview,
                            displayedComponents: .hourAndMinute
                        ) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Valoración del día")
                                    .font(.headline)
                                Text("Por la noche")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                        }

                        Divider()

                        Toggle(
                            "Desactivar en fin de semana",
                            isOn: $muteWeekends
                        )
                        .font(.headline)
                        .accessibilityHint(String(localized: "Evita recibir notificaciones durante los fines de semana."))
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
    }
}
