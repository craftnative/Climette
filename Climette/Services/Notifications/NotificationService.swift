import Foundation
import UserNotifications

public final class NotificationService: NotificationServiceProtocol {
    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
        configureCategories()
    }

    private func configureCategories() {
        // Define una categoría con .customDismissAction para interceptar cuando el usuario descarta manualmente la alerta (estado: ignorado notificacion).
        let feedbackCategory = UNNotificationCategory(
            identifier: "NIGHT_FEEDBACK_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        center.setNotificationCategories([feedbackCategory])
    }

    public func getAuthorizationStatus() async -> NotificationPermissionStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .authorized
        @unknown default: return .notDetermined
        }
    }

    public func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await center.requestAuthorization(options: options)
    }

    public func scheduleRoutineNotifications(alertTimes: NotificationAlertTimes) async throws {
        let status = await getAuthorizationStatus()
        guard status == .authorized || status == .provisional else {
            throw NotificationServiceError.permissionDenied
        }

        await removeAllPendingNotifications()

        let weekdays = [2, 3, 4, 5, 6]
        let weekends = [1, 7]

        for weekday in weekdays {
            try await scheduleMorningAlert(
                hour: alertTimes.weekdayMorning.hour ?? 7,
                minute: alertTimes.weekdayMorning.minute ?? 45,
                weekday: weekday,
                identifier: "climette.alert.morning.weekday.\(weekday)"
            )
        }

        if !alertTimes.isWeekendMuted {
            for weekendDay in weekends {
                try await scheduleMorningAlert(
                    hour: alertTimes.weekdayMorning.hour ?? 7,
                    minute: alertTimes.weekdayMorning.minute ?? 45,
                    weekday: weekendDay,
                    identifier: "climette.alert.morning.weekend.\(weekendDay)"
                )
            }
        }

        for day in 1...7 {
            if alertTimes.isWeekendMuted && weekends.contains(day) { continue }
            try await scheduleNightFeedback(
                hour: alertTimes.nightFeedback.hour ?? 20,
                minute: alertTimes.nightFeedback.minute ?? 30,
                weekday: day,
                identifier: "climette.alert.night.\(day)"
            )
        }
    }

    public func removeAllPendingNotifications() async {
        center.removeAllPendingNotificationRequests()
    }

    private func scheduleMorningAlert(
        hour: Int,
        minute: Int,
        weekday: Int,
        identifier: String
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Recomendación de ropa")
        content.body = String(localized: "Consulta el atuendo calibrado para el clima de hoy.")
        content.sound = .default

        var triggerComponents = DateComponents()
        triggerComponents.weekday = weekday
        triggerComponents.hour = hour
        triggerComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await center.add(request)
    }

    private func scheduleNightFeedback(
        hour: Int,
        minute: Int,
        weekday: Int,
        identifier: String
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Valoración del día")
        content.body = String(localized: "¿Acertó tu ropa hoy? Valora tu confort térmico para calibrar el sistema.")
        content.sound = .default
        
        // Enlace al categoryIdentifier que expone la acción delegada cuando se ignora
        content.categoryIdentifier = "NIGHT_FEEDBACK_CATEGORY"

        var triggerComponents = DateComponents()
        triggerComponents.weekday = weekday
        triggerComponents.hour = hour
        triggerComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await center.add(request)
    }
}
