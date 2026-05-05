import SwiftUI

struct SettingsView: View {
    @AppStorage("vibrationIntensity") private var vibrationIntensity = 0.5
    @AppStorage("audioVolume") private var audioVolume = 0.3
    @AppStorage("remInterval") private var remInterval = 90.0 // minutes

    var body: some View {
        Form {
            Section(header: Text("Vibration")) {
                Slider(value: $vibrationIntensity, in: 0...1, step: 0.1) {
                    Text("Intensity")
                }
                Text("Current: \(vibrationIntensity, specifier: "%.1f")")
            }

            Section(header: Text("Audio")) {
                Slider(value: $audioVolume, in: 0...1, step: 0.1) {
                    Text("Volume")
                }
                Text("Current: \(audioVolume, specifier: "%.1f")")
            }

            Section(header: Text("REM Interval")) {
                Slider(value: $remInterval, in: 60...120, step: 10) {
                    Text("Minutes between cues")
                }
                Text("Current: \(Int(remInterval)) minutes")
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}