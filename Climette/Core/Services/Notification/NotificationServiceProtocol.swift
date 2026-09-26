import Foundation
import UserNotifications

public enum NotificationPermissionStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case provisional
}

public enum NotificationServiceError: Error, Sendable, LocalizedError {
    case permissionDenied
    case schedulingFailed(String)

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permisos de notificación no otorgados."
        case .schedulingFailed(let reason):
            return "Fallo al programar la notificación: \(reason)"
        }
    }
}

public protocol NotificationServiceProtocol: Sendable {
    func getAuthorizationStatus() async -> NotificationPermissionStatus
    func requestAuthorization() async throws -> Bool
    func scheduleRoutineNotifications(alertTimes: NotificationAlertTimes) async throws
    func removeAllPendingNotifications() async
}
