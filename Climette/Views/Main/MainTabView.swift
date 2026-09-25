import SwiftUI

enum MainTab: Hashable {
    case recommendation
    case wardrobe
    case history
    case settings
}

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: MainTab = .recommendation
    @State private var hasMissingPermissions: Bool = false
    
    var locationService: LocationServiceProtocol = LocationService()
    var notificationService: NotificationServiceProtocol = NotificationService()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                WeatherView()
            }
            .tabItem {
                Label("Recomendación", systemImage: "sparkles")
            }
            .accessibilityLabel(Text("Recomendación"))
            .accessibilityHint(Text("tab_recommendation_accessibility_hint"))
            .tag(MainTab.recommendation)

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
            .badge(hasMissingPermissions ? Text(verbatim: "!") : nil)
            .tag(MainTab.settings)
        }
        .tint(Color("AccentColor"))
        .task(id: selectedTab) {
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
    
    @MainActor
    private func evaluatePermissions() async {
        let locationStatus = locationService.authorizationStatus
        let notificationStatus = await notificationService.getAuthorizationStatus()
        
        let isLocationRestricted = (locationStatus == .denied || locationStatus == .restricted)
        let isNotificationRestricted = (notificationStatus == .denied)
        
        hasMissingPermissions = isLocationRestricted || isNotificationRestricted
    }
}
