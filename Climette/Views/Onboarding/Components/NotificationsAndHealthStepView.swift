import SwiftUI

struct NotificationsAndHealthStepView: View {
    @Binding var weekdayWakeUp: Date
    @Binding var nightReview: Date
    @Binding var muteWeekends: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                OnboardingHeaderView(
                    title: "Rutina",
                    description: "Sincroniza la recomendación matutina y el registro nocturno según tus horarios."
                )

                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        DatePicker(
                            selection: $weekdayWakeUp,
                            displayedComponents: .hourAndMinute
                        ) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recomendación de ropa")
                                    .font(.headline)
                                Text("Al despertar")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Hora de recomendación de ropa al despertar")

                        Divider()

                        DatePicker(
                            selection: $nightReview,
                            displayedComponents: .hourAndMinute
                        ) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Valoración del día")
                                    .font(.headline)
                                Text("Al acostarse")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Hora de valoración del día al acostarse")

                        Divider()

                        Toggle(
                            "Desactivar en fin de semana",
                            isOn: $muteWeekends
                        )
                        .font(.headline)
                        .accessibilityHint("Evita recibir notificaciones durante los fines de semana.")
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            // Acción de sincronización con HealthKit
                        } label: {
                            HStack {
                                Text("Ajustar según horario de sueño")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "bed.double.fill")
                                    .foregroundStyle(Color.accentColor)
                                    .accessibilityHidden(true)
                            }
                        }
                        .tint(.primary)
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("Sincroniza automáticamente las horas de aviso utilizando tus datos de descanso de Apple Health.")

                        Text("Utiliza los datos de descanso para sincronizar automáticamente las horas de aviso.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
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
