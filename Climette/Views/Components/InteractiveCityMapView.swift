import SwiftUI
import MapKit
import CoreLocation

struct InteractiveCityMapView: View {
    @Binding var cityName: String
    @Binding var coordinate: GeographicCoordinate?
    @Environment(LocationService.self) private var locationService
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var mapCenter: CLLocationCoordinate2D?
    @State private var isGeocoding: Bool = false
    @State private var showSearchSheet: Bool = false
    @State private var mapErrorMessage: String?
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                showSearchSheet = true
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar")
                }
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
            
            if let mapErrorMessage {
                Text(mapErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
            
            ZStack(alignment: .bottom) {
                Map(position: $position) {
                    if let selectedCoordinate {
                        Annotation(cityName.isEmpty ? "Ubicación" : cityName, coordinate: selectedCoordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                                .background(Circle().fill(.white))
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    mapCenter = context.region.center
                }
                .overlay(alignment: .center) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundStyle(.blue)
                        .accessibilityHidden(true)
                }
                .overlay(alignment: .topTrailing) {
                    if isGeocoding {
                        ProgressView()
                            .controlSize(.small)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                            .padding(8)
                    }
                }
                .accessibilityLabel("Mapa interactivo de ciudad")
                .accessibilityHint("Usa el botón de confirmar para seleccionar el centro del mapa.")
                
                Button {
                    if let center = mapCenter {
                        selectedCoordinate = center
                        coordinate = GeographicCoordinate(latitude: center.latitude, longitude: center.longitude)
                        Task {
                            await resolveCoordinate(center)
                        }
                    }
                } label: {
                    Text("Confirmar Ubicación")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("AccentColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .accessibilityLabel("Confirmar Ubicación")
                .accessibilityHint("Establece la ubicación en el centro actual del mapa")
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showSearchSheet) {
            LocationSearchListView { selectedQuery in
                showSearchSheet = false
                cityName = selectedQuery
            }
        }
        .task(id: cityName) {
            await searchLocation(for: cityName)
        }
    }
    
    @MainActor
    private func resolveCoordinate(_ coord: CLLocationCoordinate2D) async {
        isGeocoding = true
        mapErrorMessage = nil
        defer { isGeocoding = false }
        
        do {
            if let resolved = try await locationService.reverseGeocode(
                coordinate: GeographicCoordinate(latitude: coord.latitude, longitude: coord.longitude)
            ),
            !resolved.isEmpty,
            resolved != cityName {
                cityName = resolved
            }
        } catch let error as LocalizedError {
            mapErrorMessage = error.errorDescription ?? error.localizedDescription
            print("⚠️ Error en reverseGeocode: \(error.localizedDescription)")
        } catch {
            mapErrorMessage = error.localizedDescription
            print("⚠️ Error inesperado en reverseGeocode: \(error)")
        }
    }
    
    @MainActor
    private func searchLocation(for query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        mapErrorMessage = nil
        
        if let existingCoord = coordinate, selectedCoordinate == nil {
            let center = CLLocationCoordinate2D(latitude: existingCoord.latitude, longitude: existingCoord.longitude)
            selectedCoordinate = center
            position = .region(
                MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                )
            )
            if trimmed.isEmpty { return }
        }
        
        guard !trimmed.isEmpty else { return }
        
        isGeocoding = true
        defer { isGeocoding = false }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = [.address, .pointOfInterest]
        
        do {
            let response = try await MKLocalSearch(request: request).start()
            guard let item = response.mapItems.first else {
                mapErrorMessage = "No se encontraron resultados para: \(trimmed)"
                return
            }
            let mapCoord = item.location.coordinate
            
            selectedCoordinate = mapCoord
            coordinate = GeographicCoordinate(latitude: mapCoord.latitude, longitude: mapCoord.longitude)
            
            withAnimation(.easeInOut) {
                position = .region(
                    MKCoordinateRegion(
                        center: mapCoord,
                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                    )
                )
            }
        } catch let error as MKError {
            mapErrorMessage = "Fallo al buscar ubicación: \(error.localizedDescription)"
            print("⚠️ Error MKLocalSearch: código \(error.errorCode), \(error.localizedDescription)")
        } catch {
            mapErrorMessage = error.localizedDescription
            print("⚠️ Error inesperado en searchLocation: \(error)")
        }
    }
}

@Observable
final class LocationSearchViewModel: NSObject, MKLocalSearchCompleterDelegate {
    var queryText: String = "" {
        didSet {
            completer.queryFragment = queryText
        }
    }
    var results: [MKLocalSearchCompletion] = []
    var completerErrorMessage: String?
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
        self.completerErrorMessage = nil
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.results = []
        self.completerErrorMessage = error.localizedDescription
        print("⚠️ Error en completer de búsqueda: \(error.localizedDescription)")
    }
}

struct LocationSearchListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LocationSearchViewModel()
    var onSelect: (String) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                if let error = viewModel.completerErrorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                ForEach(viewModel.results, id: \.self) { result in
                    Button {
                        let formatted = result.subtitle.isEmpty ? result.title : "\(result.title), \(result.subtitle)"
                        onSelect(formatted)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.title)
                                .foregroundStyle(.primary)
                                .font(.body)
                            if !result.subtitle.isEmpty {
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Buscar ubicación")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.queryText, prompt: "Buscar dirección o ciudad")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
