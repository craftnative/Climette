import SwiftUI

enum MainTab: Hashable {
    case weather
    case wardrobe
    case history
    case settings
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .weather

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
            .tag(MainTab.settings)
        }
        .tint(Color("AccentColor"))
    }
}

#Preview {
    MainTabView()
}
