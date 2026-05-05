# Lucid Dream Alarm iOS App

A beautiful and user-friendly SwiftUI-based iOS app that helps induce lucid dreaming by detecting REM sleep periods and delivering subtle cues like vibrations and audio to wake consciousness in dreams without fully waking the user.

## Features

- **Elegant UI**: Gradient backgrounds, SF Symbols icons, and smooth animations for an appealing experience.
- **Sleep Tracking**: Uses HealthKit for sleep data and accelerometer for REM detection proxies.
- **Customizable Cues**: Adjustable vibration intensity, audio volume, and REM interval settings.
- **Dream Journal**: Record and review dreams with a polished interface.
- **Status Indicators**: Visual feedback on tracking status.
- **Privacy-Focused**: Minimal permissions required, data stored locally.

## Screenshots (Conceptual)

- **Home Screen**: Gradient background with moon icon, status indicator, and action buttons.
- **Settings**: Organized sections with sliders and icons for easy customization.
- **Journal**: Card-based layout for dream entries, with add sheet for new dreams.

## Setup Instructions

1. Open Xcode on macOS (iOS development requires Xcode).
2. Create a new SwiftUI project named "LucidDreamAlarm".
3. Replace the generated files with the files from this directory:
   - LucidDreamAlarmApp.swift
   - ContentView.swift
   - SleepManager.swift
   - SettingsView.swift
   - JournalView.swift
4. Add the necessary frameworks to your project:
   - HealthKit
   - CoreMotion
   - AVFoundation
   - CoreHaptics
   - AudioToolbox
5. Enable HealthKit capabilities in the project settings (Signing & Capabilities tab).
6. Enable Background Modes for Location updates and Background fetch if needed for continuous monitoring.
7. Build and run on a physical iOS device (simulator lacks accelerometer and HealthKit data).

## Implementation Notes

- Uses HealthKit for sleep data (requires iOS 13+ and user permission)
- CoreMotion for accelerometer to detect subtle movements during REM (proxy for REM detection)
- AVFoundation and AudioToolbox for audio playback
- CoreHaptics for vibration patterns
- UserNotifications for scheduling alarms
- Background tasks for alarm scheduling

## Effectiveness

Based on research, subtle stimuli during estimated REM periods can induce lucidity in 20-50% of users without causing full awakenings. The app uses gentle vibrations in rhythm and system sounds to avoid startling the user.

## Limitations

- No direct EEG access on iOS; uses approximations
- Requires physical device for sensor data
- Background execution may be limited by iOS power management

## Future Improvements

- Integrate with Apple Watch for better sleep tracking
- Add binaural beat audio files
- Implement more advanced motion analysis for REM detection
- Add reality check notifications during the day
- Dark mode support and accessibility features

## Future Improvements

- Integrate with Apple Watch for better sleep tracking
- Add binaural beat audio files
- Implement more advanced motion analysis for REM detection
- Add reality check notifications during the day