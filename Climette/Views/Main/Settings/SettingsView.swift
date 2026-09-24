import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                Label {
                    Text("settings_profile_option")
                        .foregroundStyle(Color("TextPrimary"))
                } icon: {
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(Color("AccentColor"))
                        .accessibilityHidden(true)
                }
                .accessibilityAddTraits(.isButton)

                Label {
                    Text("settings_notifications_option")
                        .foregroundStyle(Color("TextPrimary"))
                } icon: {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(Color("AccentColor"))
                        .accessibilityHidden(true)
                }
                .accessibilityAddTraits(.isButton)
            } header: {
                Text("settings_general_section")
                    .accessibilityAddTraits(.isHeader)
            }
            .listRowBackground(Color("SurfaceElevated"))
        }
        .scrollContentBackground(.hidden)
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Ajustes"))
    }
}
