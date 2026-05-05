import SwiftUI

struct ContentView: View {
    @StateObject private var sleepManager = SleepManager()

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    Spacer()

                    // App title with icon
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        VStack(alignment: .leading) {
                            Text("Lucid Dream")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Alarm")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Text("Induce lucidity with gentle cues during REM sleep")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer()

                    // Status indicator
                    if sleepManager.isTracking {
                        HStack {
                            Image(systemName: "eye.fill")
                                .foregroundColor(.green)
                            Text("Sleep Tracking Active")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(20)
                    }

                    // Buttons
                    VStack(spacing: 20) {
                        Button(action: {
                            sleepManager.startSleepTracking()
                        }) {
                            HStack {
                                Image(systemName: "bed.double.fill")
                                Text("Start Sleep Tracking")
                            }
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)

                        Button(action: {
                            sleepManager.stopSleepTracking()
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop Sleep Tracking")
                            }
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                    }

                    Spacer()

                    // Navigation links
                    HStack(spacing: 20) {
                        NavigationLink(destination: SettingsView()) {
                            VStack {
                                Image(systemName: "gear")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Settings")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }

                        NavigationLink(destination: JournalView()) {
                            VStack {
                                Image(systemName: "book.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Journal")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
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