import Foundation
import HealthKit

public enum HealthKitPermissionStatus: Sendable {
    case notDetermined
    case authorized
    case denied
}

public enum HealthKitServiceError: Error, Sendable, LocalizedError {
    case healthDataUnavailable
    case sampleTypeUnavailable
    case authorizationFailed
    case noDataFound

    public var errorDescription: String? {
        switch self {
        case .healthDataUnavailable:
            return "HealthKit no está soportado en este dispositivo."
        case .sampleTypeUnavailable:
            return "El tipo de dato de análisis de sueño no se encuentra disponible."
        case .authorizationFailed:
            return "No se concedió acceso a los datos de descanso."
        case .noDataFound:
            return "No se encontraron muestras recientes de sueño."
        }
    }
}

public protocol HealthKitServiceProtocol: Sendable {
    var isHealthDataAvailable: Bool { get }
    func requestSleepAuthorization() async throws -> Bool
    func fetchRecentSleepSchedule() async throws -> SleepSchedule?
}
