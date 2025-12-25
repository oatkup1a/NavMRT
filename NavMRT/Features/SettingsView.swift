import SwiftUI

struct SettingsView: View {
    @AppStorage("navmrt.autostart") private var autoStartNav: Bool = true

    var body: some View {
        Form {
            Section("Navigation") {
                Toggle("Auto-start navigation", isOn: $autoStartNav)
                    .accessibilityLabel("Auto start navigation")
                    .accessibilityHint("When enabled, navigation starts automatically when you open the Navigator screen")
            }

            Section("Notes") {
                Text("Auto-start is recommended for VoiceOver users so they don’t need to find the Start button.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}
