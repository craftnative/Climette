import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @Query private var userProfiles: [UserProfileEntity]
    @Query private var locationStates: [LocationStateEntity]

    var locationService: LocationServiceProtocol = LocationService()
    var notificationService: NotificationServiceProtocol = NotificationService()

    @State private var locationStatus: LocationPermissionStatus = .notDetermined
    @State private var notificationStatus: NotificationPermissionStatus = .notDetermined

    var body: some View {
        Form {
            CloudKitSyncSection()
            
            if hasMissingPermissions {
                Section {
                    if locationStatus == .denied || locationStatus == .restricted {
                        PermissionWarningRow(
                            icon: "location.slash.fill",
                            title: "Ubicación desactivada",
                            description: "Necesario para precisión hiperlocal."
                        )
                    }
                    if notificationStatus == .denied {
                        PermissionWarningRow(
                            icon: "bell.slash.fill",
                            title: "Notificaciones desactivadas",
                            description: "Necesario para recomendaciones."
                        )
                    }
                    
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Abrir Ajustes del Sistema")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
                } header: {
                    Text("Permisos Requeridos")
                }
                .listRowBackground(Color("SurfaceElevated"))
            }

            if let profile = userProfiles.first {
                NotificationSettingsSection(userProfile: profile)
            } else if !hasMissingPermissions {
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Cargando perfil...")
                        Spacer()
                    }
                }
                .listRowBackground(Color("SurfaceElevated"))
            }

            if let location = locationStates.first {
                LocationSettingsSection(locationState: location)
            } else if !hasMissingPermissions {
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Cargando ubicación...")
                        Spacer()
                    }
                }
                .listRowBackground(Color("SurfaceElevated"))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Ajustes"))
        .task {
            ensureInitialEntitiesExist()
            await evaluatePermissions()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await evaluatePermissions()
                }
            }
        }
    }

    private var hasMissingPermissions: Bool {
        locationStatus == .denied || locationStatus == .restricted || notificationStatus == .denied
    }

    @MainActor
    private func evaluatePermissions() async {
        locationStatus = locationService.authorizationStatus
        notificationStatus = await notificationService.getAuthorizationStatus()
    }

    private func ensureInitialEntitiesExist() {
        var needsSave = false
        if userProfiles.isEmpty {
            modelContext.insert(UserProfileEntity(from: UserProfile()))
            needsSave = true
        }
        if locationStates.isEmpty {
            modelContext.insert(LocationStateEntity(from: LocationState()))
            needsSave = true
        }
        if needsSave {
            try? modelContext.save()
        }
    }
}

struct PermissionWarningRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .font(.title2)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("TextPrimary"))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            }
        }
        .padding(.vertical, 4)
    }
}
