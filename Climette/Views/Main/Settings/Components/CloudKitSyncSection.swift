import SwiftUI
import CloudKit
import Network

struct CloudKitSyncSection: View {
    @AppStorage("isCloudKitSyncEnabled") private var isCloudKitSyncEnabled: Bool = true
    @State private var accountStatus: CKAccountStatus = .couldNotDetermine
    @State private var isCheckingStatus: Bool = false
    @State private var isNetworkAvailable: Bool = true

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    var body: some View {
        Section {
            Toggle(isOn: $isCloudKitSyncEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sincronizar con iCloud")
                    
                    Text("Los cambios en la sincronización se aplicarán al reiniciar la aplicación.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(Color("AccentColor"))

            HStack {
                Text("Estado de iCloud")
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                if isCheckingStatus {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text(syncStatusDescription)
                        .font(.subheadline)
                        .foregroundStyle(syncStatusColor)
                }
            }

            if accountStatus == .noAccount && isCloudKitSyncEnabled {
                Text("Inicia sesión en Ajustes del sistema para respaldar datos.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Almacenamiento")
                Text("Sincroniza historial y armario privadamente.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listRowBackground(Color("SurfaceElevated"))
        .task {
            startNetworkMonitoring()
            await checkAccountStatus()
        }
    }

    private var syncStatusDescription: String {
        guard isCloudKitSyncEnabled else { return "Desactivado" }
        guard isNetworkAvailable else { return "Sin conexión" }

        switch accountStatus {
        case .available: return "Conectado"
        case .noAccount: return "Sin cuenta"
        case .restricted: return "Restringido"
        case .couldNotDetermine: return "No disponible"
        case .temporarilyUnavailable: return "Error temporal"
        @unknown default: return "Desconocido"
        }
    }

    private var syncStatusColor: Color {
        guard isCloudKitSyncEnabled else { return .secondary }
        guard isNetworkAvailable else { return .orange }

        switch accountStatus {
        case .available: return .green
        case .noAccount, .restricted, .temporarilyUnavailable: return .orange
        default: return .secondary
        }
    }

    private func checkAccountStatus() async {
        isCheckingStatus = true
        defer { isCheckingStatus = false }
        do {
            let container = CKContainer(identifier: "iCloud.craftnative.studio.Climette")
            accountStatus = try await container.accountStatus()
        } catch {
            accountStatus = .couldNotDetermine
        }
    }

    private func startNetworkMonitoring() {
        pathMonitor.pathUpdateHandler = { path in
            Task { @MainActor in
                self.isNetworkAvailable = (path.status == .satisfied)
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }
}
