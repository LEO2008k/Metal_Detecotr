# MetalDetector 🔍📱

> iPhone metal detector app using the built-in magnetometer sensor.

![iOS](https://img.shields.io/badge/iOS-17%2B-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.0-orange?logo=swift)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- 🧲 **Real magnetometer** — uses CoreMotion magnetic field sensor, not gimmicks
- 🎯 **Directional radar** — shows WHERE the metal is on an animated radar display
- 🔊 **VCO audio feedback** — tone frequency increases with detection strength
- 📳 **Haptic feedback** — vibration intensity correlates with magnetic flux density
- 📊 **Live waveform** — real-time signal visualization with smooth bezier curves
- 🌍 **Bilingual** — Ukrainian 🇺🇦 and English 🇬🇧 auto-detected from device language
- 🎨 **Premium UI** — dark sci-fi aesthetic with glassmorphism, animated backgrounds, pulsing radar rings

## Architecture

```
MetalDetector/
├── Core/
│   ├── MagnetometerActor.swift   — Swift Actor for 60Hz sensor streaming
│   ├── SignalProcessor.swift     — Low-Pass Filter, calibration, directional detection
│   ├── FeedbackManager.swift     — VCO audio + CoreHaptics
│   ├── DetectorViewModel.swift   — ViewModel orchestrating all components
│   ├── Localizer.swift           — UK/EN localization
│   └── AppVersion.swift          — Version management
├── Views/
│   ├── ContentView.swift         — Main screen
│   ├── SettingsView.swift        — Settings & info
│   └── Components/
│       ├── AnimatedBackground.swift — Reactive gradient background
│       ├── RadarRingView.swift      — Radar with metal blip
│       ├── WaveformView.swift       — Signal waveform graph
│       └── UIComponents.swift       — Buttons, cards
└── Assets.xcassets/              — Colors, icons
```

## How It Works

1. **Calibration** — On start, 30 readings establish baseline magnetic field (~25-65 µT)
2. **Detection** — Deviations from baseline indicate nearby ferromagnetic objects
3. **Direction** — X/Y magnetic components via `atan2()` determine the direction of the anomaly
4. **Feedback** — Audio frequency + haptic intensity scale with detection strength

## ⚠️ Limitations

- ✅ Detects: **iron, steel, nickel** (ferromagnetic metals)
- ❌ Cannot detect: **gold, silver, copper, aluminum** (non-magnetic metals)
- Works best on **physical iPhone** (magnetometer not available in Simulator)

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Physical iPhone (magnetometer required)

## Getting Started

```bash
git clone https://github.com/YourUsername/MetalDetector.git
cd MetalDetector
open MetalDetector.xcodeproj
```

Select your iPhone as target → ⌘+R

## Version History

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT License — see [LICENSE](LICENSE) for details.
