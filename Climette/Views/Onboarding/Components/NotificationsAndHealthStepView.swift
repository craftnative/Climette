import SwiftUI

struct NotificationsAndHealthStepView: View {
    @Binding var weekdayWakeUp: Date
    @Binding var nightReview: Date
    @Binding var muteWeekends: Bool

    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(
                title: "Rutina",
                description: "Sincroniza la recomendación matutina y el registro nocturno según tus horarios."
            )

            Form {
                Section {
                    DatePicker(
                        selection: $weekdayWakeUp,
                        displayedComponents: .hourAndMinute
                    ) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Recomendación de ropa")
                            Text("Al despertar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    DatePicker(
                        selection: $nightReview,
                        displayedComponents: .hourAndMinute
                    ) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Valoración del día")
                            Text("Al acostarse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Toggle(
                        "Desactivar en fin de semana",
                        isOn: $muteWeekends
                    )
                } header: {
                    Text("Horarios diarios")
                }

                Section {
                    Button {
                        // Acción de sincronización con HealthKit
                    } label: {
                        HStack {
                            Text("Ajustar según horario de sueño")
                            Spacer()
                            Image(systemName: "bed.double.fill")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                } header: {
                    Text("Salud")
                } footer: {
                    Text("Utiliza los datos de descanso para sincronizar automáticamente las horas de aviso.")
                }
            }
        }
    }
}
