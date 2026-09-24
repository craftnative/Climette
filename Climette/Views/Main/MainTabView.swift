import SwiftUI

enum MainTab: Hashable {
    case weather
    case wardrobe
    case history
    case settings
}

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: MainTab = .weather
    @State private var hasMissingPermissions: Bool = false
    
    var locationService: LocationServiceProtocol = LocationService()
    var notificationService: NotificationServiceProtocol = NotificationService()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                WeatherView()
            }
            .tabItem {
                Label("Tiempo", systemImage: "cloud.sun.fill")
            }
            .accessibilityLabel(Text("Tiempo"))
            .accessibilityHint(Text("tab_weather_accessibility_hint"))
            .tag(MainTab.weather)

            NavigationStack {
                WardrobeView()
            }
            .tabItem {
                Label("Armario", systemImage: "tshirt.fill")
            }
            .accessibilityLabel(Text("Armario"))
            .accessibilityHint(Text("tab_wardrobe_accessibility_hint"))
            .tag(MainTab.wardrobe)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Historial", systemImage: "clock.arrow.circlepath")
            }
            .accessibilityLabel(Text("Historial"))
            .accessibilityHint(Text("tab_history_accessibility_hint"))
            .tag(MainTab.history)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Ajustes", systemImage: "gearshape.fill")
            }
            .accessibilityLabel(Text("Ajustes"))
            .accessibilityHint(Text("tab_settings_accessibility_hint"))
            .badge(hasMissingPermissions ? "!" : nil)
            .tag(MainTab.settings)
        }
        .tint(Color("AccentColor"))
        // Reevalúa al cambiar de pestaña y en la carga inicial
        .task(id: selectedTab) {
            await evaluatePermissions()
        }
        // Reevalúa cuando la app vuelve desde Ajustes de iOS a primer plano
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await evaluatePermissions()
                }
            }
        }
    }
    
    @MainActor
    private func evaluatePermissions() async {
        let locationStatus = locationService.authorizationStatus
        let notificationStatus = await notificationService.getAuthorizationStatus()
        
        let isLocationRestricted = (locationStatus == .denied || locationStatus == .restricted)
        let isNotificationRestricted = (notificationStatus == .denied)
        
        hasMissingPermissions = isLocationRestricted || isNotificationRestricted
    }
}
