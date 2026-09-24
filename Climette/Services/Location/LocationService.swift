import Foundation
import CoreLocation
import MapKit

@MainActor
public final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    private var authContinuations: [CheckedContinuation<LocationPermissionStatus, Never>] = []

    public override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }

    public var authorizationStatus: LocationPermissionStatus {
        mapStatus(locationManager.authorizationStatus)
    }

    public func requestAuthorization() async -> LocationPermissionStatus {
        let currentStatus = authorizationStatus
        guard currentStatus == .notDetermined else {
            return currentStatus
        }

        return await withCheckedContinuation { continuation in
            authContinuations.append(continuation)
            locationManager.requestWhenInUseAuthorization()
        }
    }

    public func getCurrentLocation() async throws -> GeographicCoordinate {
        guard authorizationStatus == .authorized else {
            throw LocationServiceError.unauthorized
        }

        for try await update in CLLocationUpdate.liveUpdates() {
            guard !Task.isCancelled else { break }
            if let location = update.location {
                return GeographicCoordinate(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        }
        
        throw LocationServiceError.locationUnavailable
    }

    public func reverseGeocode(coordinate: GeographicCoordinate) async throws -> String? {
        guard let request = MKReverseGeocodingRequest(
            location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        ) else {
            throw LocationServiceError.geocodingFailed
        }

        do {
            let mapItems = try await request.mapItems
            guard let item = mapItems.first else { return nil }
            
            if let address = item.address {
                return address.shortAddress ?? address.fullAddress
            }
            
            return item.name
        } catch {
            throw LocationServiceError.geocodingFailed
        }
    }

    private func mapStatus(_ status: CLAuthorizationStatus) -> LocationPermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorizedAlways, .authorizedWhenInUse: return .authorized
        @unknown default: return .notDetermined
        }
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let rawStatus = manager.authorizationStatus
        let mapped = mapStatus(rawStatus)
        for continuation in authContinuations {
            continuation.resume(returning: mapped)
        }
        authContinuations.removeAll()
    }
}
