import SwiftUI
import CloudKit

struct CloudKitSyncSection: View {
    @AppStorage("isCloudKitSyncEnabled") private var isCloudKitSyncEnabled: Bool = true
    @State private var accountStatus: CKAccountStatus = .couldNotDetermine
    @State private var isCheckingStatus: Bool = false

    var body: some View {
        Section {
            Toggle("Sincronizar con iCloud", isOn: $isCloudKitSyncEnabled)
                .tint(Color("AccentColor"))

            HStack {
                Text("Estado de iCloud")
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                if isCheckingStatus {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text(accountStatusDescription)
                        .font(.subheadline)
                        .foregroundStyle(accountStatusColor)
                }
            }

            if accountStatus == .noAccount {
                Text("Inicia sesión en Ajustes del sistema para respaldar datos.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Almacenamiento")
        } footer: {
            Text("CloudKit sincroniza perfiles y armarios privadamente.")
        }
        .listRowBackground(Color("SurfaceElevated"))
        .task {
            await checkAccountStatus()
        }
    }

    private var accountStatusDescription: String {
        switch accountStatus {
        case .available: return "Conectado"
        case .noAccount: return "Sin cuenta"
        case .restricted: return "Restringido"
        case .couldNotDetermine: return "No disponible"
        case .temporarilyUnavailable: return "Error temporal"
        @unknown default: return "Desconocido"
        }
    }

    private var accountStatusColor: Color {
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
}
