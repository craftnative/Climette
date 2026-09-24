import SwiftUI
import MapKit
import CoreLocation

struct InteractiveCityMapView: View {
    @Binding var cityName: String
    var locationService: LocationServiceProtocol = LocationService()
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isGeocoding: Bool = false
    @State private var showSearchSheet: Bool = false
    
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
            
            MapReader { proxy in
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(alignment: .topTrailing) {
                    if isGeocoding {
                        ProgressView()
                            .controlSize(.small)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                            .padding(8)
                    }
                }
                .onTapGesture { screenCoord in
                    guard let location = proxy.convert(screenCoord, from: .local) else { return }
                    selectedCoordinate = location
                    Task {
                        await resolveCoordinate(location)
                    }
                }
            }
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
    private func resolveCoordinate(_ coordinate: CLLocationCoordinate2D) async {
        isGeocoding = true
        defer { isGeocoding = false }
        
        do {
            if let resolved = try await locationService.reverseGeocode(coordinate: GeographicCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)),
               !resolved.isEmpty,
               resolved != cityName {
                cityName = resolved
            }
        } catch {
            // Manejo silencioso de errores de resolución inversa
        }
    }
    
    @MainActor
    private func searchLocation(for query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isGeocoding = true
        defer { isGeocoding = false }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = .address
        
        do {
            let response = try await MKLocalSearch(request: request).start()
            guard let item = response.mapItems.first else { return }
            let coordinate = item.location.coordinate
            
            selectedCoordinate = coordinate
            withAnimation(.easeInOut) {
                position = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                    )
                )
            }
        } catch {
            // Manejo silencioso en caso de no encontrar coincidencia
        }
    }
}

// MARK: - Componentes de búsqueda y listado con MKLocalSearchCompleter

@Observable
final class LocationSearchViewModel: NSObject, MKLocalSearchCompleterDelegate {
    var queryText: String = "" {
        didSet {
            completer.queryFragment = queryText
        }
    }
    var results: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.results = []
    }
}

struct LocationSearchListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LocationSearchViewModel()
    var onSelect: (String) -> Void
    
    var body: some View {
        NavigationStack {
            List(viewModel.results, id: \.self) { result in
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
