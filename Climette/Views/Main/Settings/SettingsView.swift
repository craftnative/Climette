import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(LocationService.self) private var locationService
    @Environment(NotificationService.self) private var notificationService
    
    @Query(sort: \UserProfileEntity.updatedAt, order: .reverse)
    private var userProfiles: [UserProfileEntity]

    @Query(sort: \LocationStateEntity.lastUpdated, order: .reverse)
    private var locationStates: [LocationStateEntity]

    @State private var locationStatus: LocationPermissionStatus = .notDetermined
    @State private var notificationStatus: NotificationPermissionStatus = .notDetermined
    
    @State private var dbErrorMessage: String?

    var body: some View {
        Form {
            if let dbErrorMessage {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fallo en Base de Datos")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.red)
                        Text(dbErrorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowBackground(Color("SurfaceElevated"))
            }
            
            if hasMissingPermissions {
                Section {
                    if locationStatus == .denied || locationStatus == .restricted {
                        PermissionWarningRow(
                            icon: "location.slash.fill",
                            title: "Ubicación desactivada",
                            description: "Necesario para precisión en cambios de localización."
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

            if notificationStatus == .authorized {
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
            }
            
            if let profile = userProfiles.first {
                ThermalSensitivitySection(userProfile: profile)
                ClothingPreferenceSection(userProfile: profile)
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
            
            CloudKitSyncSection()
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
        do {
            var needsSave = false

            var profileDescriptor = FetchDescriptor<UserProfileEntity>()
            profileDescriptor.fetchLimit = 1
            let existingProfiles = try modelContext.fetch(profileDescriptor)
            if existingProfiles.isEmpty {
                modelContext.insert(UserProfileEntity(from: UserProfile()))
                needsSave = true
            }

            var locationDescriptor = FetchDescriptor<LocationStateEntity>()
            locationDescriptor.fetchLimit = 1
            let existingLocations = try modelContext.fetch(locationDescriptor)
            if existingLocations.isEmpty {
                modelContext.insert(LocationStateEntity(from: LocationState()))
                needsSave = true
            }

            if needsSave {
                try modelContext.save()
            }
        } catch {
            dbErrorMessage = error.localizedDescription
            print("⚠️ Error SwiftData (SettingsView): \(error)")
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
