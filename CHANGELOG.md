# Changelog

All notable changes to MetalDetector will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-02-13

### Added

- 🌍 **Language selector** in Settings — manually switch between Ukrainian 🇺🇦, English 🇬🇧, or Auto-detect
- 🫧 **Spirit Level (Ватерпас)** — new mode with 2D bubble level using accelerometer
  - Real-time tilt measurement (Left-Right & Front-Back)
  - Color-coded status (green = level, yellow = slight tilt, red = tilted)
  - Glass-like bubble with spring physics animation
- ↕️ **Vertical depth indicator** — shows if metal is ABOVE or BELOW the phone using Z-axis magnetic field
  - Animated arrow indicators with glow
  - Color-coded direction (cyan = above, orange = below, green = same level)
- 🔄 **Mode switcher** — pill-shaped tabs to toggle between Metal Detector and Spirit Level
- 📋 **Version display** in Settings (reads from Info.plist)
- 📝 README.md with badges, architecture, and getting started guide
- 📝 CHANGELOG.md with Keep a Changelog format

### Changed

- All UI strings now use centralized L10n localizer
- Radar ring slightly smaller (260px) to fit vertical indicator

## [1.0.0] - 2026-02-13

### Added

- 🧲 Core magnetometer scanning via CoreMotion at 60Hz
- 🎯 Directional radar blip showing WHERE metal is detected (X/Y magnetic components)
- 📊 Real-time waveform visualization with bezier curves
- 🔊 VCO-style audio feedback (frequency scales with detection strength)
- 📳 CoreHaptics feedback with intensity correlated to magnetic flux density
- ⚙️ Signal processing with Low-Pass Filter and auto-calibration
- 🎨 Premium dark UI with animated background, glassmorphism, radar rings
- 📈 Session stats: duration, baseline, peak strength
- ⚠️ Ferromagnetic-only detection disclaimer
- 🔧 Settings screen with audio/haptic toggles
