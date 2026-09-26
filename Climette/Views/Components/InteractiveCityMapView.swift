import SwiftUI
import MapKit
import CoreLocation

struct InteractiveCityMapView: View {
    @Binding var cityName: String
    @Binding var coordinate: GeographicCoordinate?
    
    @Environment(LocationService.self) private var locationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var mapCenter: CLLocationCoordinate2D?
    @State private var isGeocoding: Bool = false
    @State private var mapErrorMessage: String?
    
    @State private var searchViewModel = LocationSearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color("AccentColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .accessibilityLabel("Confirmar Ubicación")
            .accessibilityHint("Establece la ubicación en el centro actual del mapa")
            
            // Solo muestra errores críticos reales, suprimiendo fallos transitorios de búsqueda
            if let mapErrorMessage {
                Text(mapErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            
            // 3. Mapa y buscador integrado
            MapReader { proxy in
                ZStack(alignment: .top) {
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
                    .onTapGesture { screenPosition in
                        isSearchFocused = false
                        if let tappedCoord = proxy.convert(screenPosition, from: .local) {
                            selectedCoordinate = tappedCoord
                            coordinate = GeographicCoordinate(latitude: tappedCoord.latitude, longitude: tappedCoord.longitude)
                            Task {
                                await resolveCoordinate(tappedCoord)
                            }
                        }
                    }
                    .overlay(alignment: .center) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundStyle(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Mapa interactivo de ciudad")
                    .accessibilityHint("Toca directamente sobre el mapa o usa el botón Confirmar Ubicación para seleccionar el centro.")
                    
                    if isGeocoding {
                        ProgressView()
                            .controlSize(.small)
                            .padding(8)
                            .glassEffect(.regular, in: Circle())
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(.top, 64)
                            .padding(.trailing, 12)
                    }
                    
                    // Buscador integrado Glass
                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            
                            TextField("Buscar dirección o ciudad...", text: $searchViewModel.queryText)
                                .focused($isSearchFocused)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .onSubmit {
                                    isSearchFocused = false
                                    Task {
                                        await searchLocation(for: searchViewModel.queryText)
                                    }
                                }
                            
                            if !searchViewModel.queryText.isEmpty {
                                Button {
                                    searchViewModel.queryText = ""
                                    searchViewModel.results = []
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                        
                        // Menú desplegable sobre el mapa
                        if isSearchFocused && !searchViewModel.results.isEmpty {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(searchViewModel.results, id: \.self) { result in
                                        Button {
                                            isSearchFocused = false
                                            searchViewModel.queryText = result.title
                                            Task {
                                                await selectCompletion(result)
                                            }
                                        } label: {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(result.title)
                                                    .font(.subheadline.weight(.medium))
                                                    .foregroundStyle(.primary)
                                                if !result.subtitle.isEmpty {
                                                    Text(result.subtitle)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        
                                        Divider()
                                            .padding(.leading, 14)
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            // Inicializa la posición inicial si ya existen coordenadas previas
            if let existingCoord = coordinate, selectedCoordinate == nil {
                let center = CLLocationCoordinate2D(latitude: existingCoord.latitude, longitude: existingCoord.longitude)
                selectedCoordinate = center
                position = .region(
                    MKCoordinateRegion(
                        center: center,
                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                    )
                )
            }
        }
    }
    
    // Geocodificación precisa a partir del objeto MKLocalSearchCompletion nativo
    @MainActor
    private func selectCompletion(_ completion: MKLocalSearchCompletion) async {
        isGeocoding = true
        mapErrorMessage = nil
        defer { isGeocoding = false }
        
        let request = MKLocalSearch.Request(completion: completion)
        request.resultTypes = [.address, .pointOfInterest]
        
        do {
            let response = try await MKLocalSearch(request: request).start()
            if let item = response.mapItems.first {
                let mapCoord = item.location.coordinate
                selectedCoordinate = mapCoord
                coordinate = GeographicCoordinate(latitude: mapCoord.latitude, longitude: mapCoord.longitude)
                cityName = item.name ?? completion.title
                
                withAnimation(.easeInOut) {
                    position = .region(
                        MKCoordinateRegion(
                            center: mapCoord,
                            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                        )
                    )
                }
            }
        } catch {
            // Suprime el mensaje de error si la búsqueda no encuentra punto exacto
            print("MKLocalSearchCompletion error: \(error.localizedDescription)")
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
                searchViewModel.queryText = resolved
            }
        } catch {
            print("ReverseGeocode warning: \(error.localizedDescription)")
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
        request.resultTypes = [.address, .pointOfInterest]
        
        do {
            let response = try await MKLocalSearch(request: request).start()
            if let item = response.mapItems.first {
                let mapCoord = item.location.coordinate
                selectedCoordinate = mapCoord
                coordinate = GeographicCoordinate(latitude: mapCoord.latitude, longitude: mapCoord.longitude)
                cityName = item.name ?? trimmed
                
                withAnimation(.easeInOut) {
                    position = .region(
                        MKCoordinateRegion(
                            center: mapCoord,
                            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                        )
                    )
                }
            }
        } catch {
            print("SearchLocation warning: \(error.localizedDescription)")
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
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.results = []
    }
}
