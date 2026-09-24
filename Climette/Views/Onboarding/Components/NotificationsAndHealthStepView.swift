import SwiftUI

enum SleepDataMode: Int, Sendable, Equatable {
    case manual
    case health
}

enum HealthSyncState: Equatable {
    case idle
    case syncing
    case success
    case permissionDenied(String)
    case noDataOrPermissionDenied(String)
    case failure(String)
}

struct NotificationsAndHealthStepView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @Binding var weekdayWakeUp: Date
    @Binding var nightReview: Date
    @Binding var muteWeekends: Bool

    var healthKitService: HealthKitServiceProtocol = HealthKitService()

    @State private var sleepDataMode: SleepDataMode = .manual
    @State private var syncState: HealthSyncState = .idle

    private var shouldDisablePickers: Bool {
        guard sleepDataMode == .health else { return false }
        switch syncState {
        case .idle, .syncing, .success:
            return true
        case .permissionDenied, .noDataOrPermissionDenied, .failure:
            return false
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                OnboardingHeaderView(
                    title: "Rutina",
                    description: "Sincroniza la recomendación matutina y el registro nocturno según tus horarios."
                )

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Origen de datos de sueño")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Picker("Origen de datos", selection: $sleepDataMode) {
                            Text("Manual").tag(SleepDataMode.manual)
                            Text("Salud").tag(SleepDataMode.health)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

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
                    .disabled(shouldDisablePickers)
                    .opacity(shouldDisablePickers ? 0.6 : 1.0)

                    if sleepDataMode == .health {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if case .syncing = syncState {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "bed.double.fill")
                                        .foregroundStyle(Color.accentColor)
                                        .accessibilityHidden(true)
                                }

                                Text("Sincronización con Salud")
                                    .font(.headline)
                            }
                            .frame(minHeight: 24)

                            switch syncState {
                            case .idle, .syncing:
                                Text("Utiliza los datos de descanso para sincronizar automáticamente las horas de aviso.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                            case .success:
                                Text("Horarios sincronizados con tus datos de Salud.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                            case .permissionDenied(let message):
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 4)

                                Text("1. Abre la app Salud.\n2. Pulsa tu foto de perfil > Apps y servicios.\n3. Selecciona esta app y activa el acceso a Sueño.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.vertical, 2)

                                Text("Se usarán los datos manuales hasta que se conceda el acceso.")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.bottom, 4)

                                Button {
                                    openHealthOrSettings()
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("Abrir app Salud")
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption2)
                                    }
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.accentColor)
                                }

                            case .noDataOrPermissionDenied(let message):
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 4)

                                Text("1. Abre la app Salud.\n2. Pulsa tu foto de perfil > Apps > Climette.\n3. Asegúrate de permitir el acceso a Sueño y tener datos registrados.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.vertical, 2)

                                Button {
                                    openHealthOrSettings()
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("Revisar en Salud")
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption2)
                                    }
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.accentColor)
                                }

                            case .failure(let message):
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 4)

                                Text("No se pudo completar la sincronización. Se mantendrán los valores manuales.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .onChange(of: sleepDataMode) { _, newValue in
            if newValue == .health {
                Task { @MainActor in
                    await syncWithSleepSchedule()
                }
            } else {
                syncState = .idle
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, sleepDataMode == .health else { return }
            Task { @MainActor in
                await syncWithSleepSchedule()
            }
        }
    }

    private func openHealthOrSettings() {
        if let healthURL = URL(string: "x-apple-health://"), UIApplication.shared.canOpenURL(healthURL) {
            openURL(healthURL)
        } else if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            openURL(settingsURL)
        }
    }

    private func syncWithSleepSchedule() async {
        syncState = .syncing

        do {
            let authorized = try await healthKitService.requestSleepAuthorization()
            guard authorized else {
                syncState = .permissionDenied("Permiso denegado para acceder a Salud.")
                return
            }

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

                syncState = .success
            } else {
                syncState = .noDataOrPermissionDenied("No se encontraron datos o el acceso de lectura fue denegado.")
            }
        } catch let error as HealthKitServiceError {
            switch error {
            case .noDataOrPermissionDenied:
                syncState = .noDataOrPermissionDenied(error.localizedDescription)
            case .authorizationFailed:
                syncState = .permissionDenied(error.localizedDescription)
            default:
                syncState = .failure(error.localizedDescription)
            }
        } catch {
            syncState = .failure(error.localizedDescription)
        }
    }
}
