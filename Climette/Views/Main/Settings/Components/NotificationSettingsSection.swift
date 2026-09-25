import SwiftUI
import SwiftData

struct NotificationSettingsSection: View {
    @Bindable var userProfile: UserProfileEntity
    var notificationService: NotificationServiceProtocol = NotificationService()
    
    @State private var weekdayDate: Date = .now
    @State private var nightDate: Date = .now

    var body: some View {
        Section {
            DatePicker(
                "Recomendación matutina",
                selection: $weekdayDate,
                displayedComponents: .hourAndMinute
            )
            .onChange(of: weekdayDate) { _, newValue in
                let comp = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                userProfile.weekdayMorningHour = comp.hour ?? 7
                userProfile.weekdayMorningMinute = comp.minute ?? 45
                updateSchedule()
            }

            DatePicker(
                "Valoración nocturna",
                selection: $nightDate,
                displayedComponents: .hourAndMinute
            )
            .onChange(of: nightDate) { _, newValue in
                let comp = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                userProfile.nightFeedbackHour = comp.hour ?? 20
                userProfile.nightFeedbackMinute = comp.minute ?? 30
                updateSchedule()
            }

            Toggle("Desactivar en fin de semana", isOn: $userProfile.isWeekendMuted)
                .onChange(of: userProfile.isWeekendMuted) { _, _ in
                    updateSchedule()
                }
        } header: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notificaciones y Rutinas")
                Text("Establece los momentos del día en que Climette evalúa el clima.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listRowBackground(Color("SurfaceElevated"))
        .task {
            syncDatesFromModel()
        }
    }

    private func syncDatesFromModel() {
        var c1 = DateComponents()
        c1.hour = userProfile.weekdayMorningHour
        c1.minute = userProfile.weekdayMorningMinute
        weekdayDate = Calendar.current.date(from: c1) ?? .now

        var c3 = DateComponents()
        c3.hour = userProfile.nightFeedbackHour
        c3.minute = userProfile.nightFeedbackMinute
        nightDate = Calendar.current.date(from: c3) ?? .now
    }

    private func updateSchedule() {
        userProfile.updatedAt = .now
        let alertTimes = userProfile.toDomain().alertTimes
        Task {
            try? await notificationService.scheduleRoutineNotifications(alertTimes: alertTimes)
        }
    }
}
