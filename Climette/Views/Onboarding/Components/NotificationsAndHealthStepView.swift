import SwiftUI

struct NotificationsAndHealthStepView: View {
    @Binding var weekdayWakeUp: Date
    @Binding var nightReview: Date
    @Binding var muteWeekends: Bool

    var healthKitService: HealthKitServiceProtocol = HealthKitService()

    @State private var isSyncingHealth: Bool = false
    @State private var healthErrorMessage: String?

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
                                Text("Al acostarse")
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

                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            Task { @MainActor in
                                await syncWithSleepSchedule()
                            }
                        } label: {
                            HStack {
                                Text("Ajustar según horario de sueño")
                                    .font(.headline)
                                Spacer()
                                if isSyncingHealth {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "bed.double.fill")
                                        .foregroundStyle(Color.accentColor)
                                        .accessibilityHidden(true)
                                }
                            }
                            .frame(minHeight: 44)
                        }
                        .disabled(isSyncingHealth)
                        .tint(.primary)

                        Text("Utiliza los datos de descanso para sincronizar automáticamente las horas de aviso.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let healthErrorMessage {
                            Text(healthErrorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }
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

    private func syncWithSleepSchedule() async {
        isSyncingHealth = true
        healthErrorMessage = nil

        do {
            _ = try await healthKitService.requestSleepAuthorization()
            if let schedule = try await healthKitService.fetchRecentSleepSchedule() {
                let calendar = Calendar.current
                let now = Date.now

                if let wakeHour = schedule.wakeUp.hour,
                   let wakeMinute = schedule.wakeUp.minute,
                   let calculatedWakeUp = calendar.date(bySettingHour: wakeHour, minute: wakeMinute, second: 0, of: now) {
                    weekdayWakeUp = calculatedWakeUp
                }

                if let bedHour = schedule.bedtime.hour,
                   let bedMinute = schedule.bedtime.minute,
                   let calculatedBedtime = calendar.date(bySettingHour: bedHour, minute: bedMinute, second: 0, of: now) {
                    nightReview = calculatedBedtime
                }
            } else {
                healthErrorMessage = HealthKitServiceError.noDataFound.localizedDescription
            }
        } catch let error as LocalizedError {
            healthErrorMessage = error.errorDescription ?? error.localizedDescription
        } catch {
            healthErrorMessage = error.localizedDescription
        }

        isSyncingHealth = false
    }
}
