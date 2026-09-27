import Foundation
import CoreLocation
import MapKit
import Observation

@Observable
@MainActor
public final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    @ObservationIgnored private let locationManager: CLLocationManager
    @ObservationIgnored private var authContinuations: [CheckedContinuation<LocationPermissionStatus, Never>] = []

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
        try await getCurrentLocation(timeout: .seconds(15))
    }

    public func getCurrentLocation(timeout: Duration) async throws -> GeographicCoordinate {
        guard authorizationStatus == .authorized else {
            throw LocationServiceError.unauthorized
        }

        return try await withThrowingTaskGroup(of: GeographicCoordinate.self) { group in
            group.addTask {
                for try await update in CLLocationUpdate.liveUpdates() {
                    try Task.checkCancellation()
                    if let location = update.location {
                        return await GeographicCoordinate(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    }
                }
                throw LocationServiceError.locationUnavailable
            }
            group.addTask {
                try await Task.sleep(for: timeout)
                throw LocationServiceError.locationUnavailable
            }

            do {
                guard let result = try await group.next() else {
                    throw LocationServiceError.locationUnavailable
                }
                group.cancelAll()
                return result
            } catch {
                group.cancelAll()
                throw error
            }
        }
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
