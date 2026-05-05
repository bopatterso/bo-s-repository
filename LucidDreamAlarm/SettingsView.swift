import SwiftUI

struct SettingsView: View {
    @AppStorage("vibrationIntensity") private var vibrationIntensity = 0.5
    @AppStorage("audioVolume") private var audioVolume = 0.3
    @AppStorage("remInterval") private var remInterval = 90.0 // minutes

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            Form {
                Section(header: HStack {
                    Image(systemName: "waveform")
                    Text("Vibration")
                }) {
                    VStack(alignment: .leading) {
                        Slider(value: $vibrationIntensity, in: 0...1, step: 0.1)
                            .accentColor(.blue)
                        Text("Intensity: \(vibrationIntensity, specifier: "%.1f")")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Audio")
                }) {
                    VStack(alignment: .leading) {
                        Slider(value: $audioVolume, in: 0...1, step: 0.1)
                            .accentColor(.purple)
                        Text("Volume: \(audioVolume, specifier: "%.1f")")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: HStack {
                    Image(systemName: "clock")
                    Text("REM Interval")
                }) {
                    VStack(alignment: .leading) {
                        Slider(value: $remInterval, in: 60...120, step: 10)
                            .accentColor(.green)
                        Text("Minutes between cues: \(Int(remInterval))")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: HStack {
                    Image(systemName: "info.circle")
                    Text("About")
                }) {
                    Text("This app uses accelerometer data as a proxy for REM sleep detection. Subtle vibrations and sounds help induce lucidity without waking you fully.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .background(Color.clear)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}