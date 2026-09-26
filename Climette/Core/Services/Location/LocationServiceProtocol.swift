import Foundation
import CoreLocation

public enum LocationPermissionStatus: Sendable {
    case notDetermined
    case restricted
    case denied
    case authorized
}

public enum LocationServiceError: Error, Sendable, LocalizedError {
    case unauthorized
    case locationUnavailable
    case geocodingFailed
    case serviceDestroyed

    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "El acceso a la ubicación no ha sido autorizado."
        case .locationUnavailable:
            return "No se pudo obtener la posición geográfica actual."
        case .geocodingFailed:
            return "Error al resolver la localidad mediante geocodificación inversa."
        case .serviceDestroyed:
            return "El servicio de ubicación dejó de estar disponible durante la operación."
        }
    }
}

@MainActor
public protocol LocationServiceProtocol: Sendable {
    var authorizationStatus: LocationPermissionStatus { get }
    func requestAuthorization() async -> LocationPermissionStatus
    func getCurrentLocation() async throws -> GeographicCoordinate
    func reverseGeocode(coordinate: GeographicCoordinate) async throws -> String?
}
