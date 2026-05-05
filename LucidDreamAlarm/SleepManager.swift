import Foundation
import HealthKit
import CoreMotion
import UserNotifications
import AVFoundation
import CoreHaptics
import AudioToolbox

class SleepManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private let motionManager = CMMotionManager()
    private var audioPlayer: AVAudioPlayer?
    private var hapticEngine: CHHapticEngine?

    @Published var isTracking = false

    init() {
        requestPermissions()
    }

    func requestPermissions() {
        // HealthKit
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            if let error = error {
                print("HealthKit auth error: \(error)")
            }
        }

        // Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification auth error: \(error)")
            }
        }
    }

    func startSleepTracking() {
        isTracking = true

        // Start accelerometer monitoring
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 10.0 // 10 Hz
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                if let data = data {
                    self.processMotionData(data)
                }
            }
        }

        // Schedule alarms based on settings
        let interval = UserDefaults.standard.double(forKey: "remInterval")
        let intervalSeconds = interval > 0 ? interval * 60 : 90 * 60 // default 90 minutes
        for i in 1...5 {
            let delay = TimeInterval(i) * intervalSeconds
            scheduleAlarm(delay: delay)
        }
    }

    func stopSleepTracking() {
        isTracking = false
        motionManager.stopAccelerometerUpdates()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func processMotionData(_ data: CMAccelerometerData) {
        // Basic REM proxy: low and variable acceleration might indicate REM
        let magnitude = sqrt(data.acceleration.x * data.acceleration.x +
                             data.acceleration.y * data.acceleration.y +
                             data.acceleration.z * data.acceleration.z)
        // In a real app, collect data over time and analyze patterns
        if magnitude < 1.0 && isTracking {
            print("Potential REM motion: \(magnitude)")
            // Could trigger additional cues here
        }
    }

    private func scheduleAlarm(delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Lucid Cue"
        content.body = "A gentle reminder to check your reality"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }

        // Trigger vibration and audio at the same time
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.playVibration()
            self.playAudio()
        }
    }

    private func playVibration() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()

            // Create a pattern of gentle pulses
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic error: \(error)")
        }
    }

    private func playAudio() {
        // Play a subtle system sound
        // In a real app, load a custom audio file for binaural beats
        AudioServicesPlaySystemSound(1052) // Subtle SMS-like sound
    }
}