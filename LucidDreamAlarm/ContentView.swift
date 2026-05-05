import SwiftUI

struct ContentView: View {
    @StateObject private var sleepManager = SleepManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Lucid Dream Alarm")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                Text("Induce lucidity with subtle cues during REM sleep")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                Button(action: {
                    sleepManager.startSleepTracking()
                }) {
                    Text("Start Sleep Tracking")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal)

                Button(action: {
                    sleepManager.stopSleepTracking()
                }) {
                    Text("Stop Sleep Tracking")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal)

                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                }
                .padding(.horizontal)

                NavigationLink(destination: JournalView()) {
                    Text("Dream Journal")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}