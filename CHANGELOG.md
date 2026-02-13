# Changelog

All notable changes to MetalDetector will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-13

### Added

- 🧲 Core magnetometer scanning via CoreMotion at 60Hz
- 🎯 Directional radar blip showing WHERE metal is detected (X/Y magnetic components)
- 📊 Real-time waveform visualization with bezier curves
- 🔊 VCO-style audio feedback (frequency scales with detection strength)
- 📳 CoreHaptics feedback with intensity correlated to magnetic flux density
- ⚙️ Signal processing with Low-Pass Filter and auto-calibration
- 🌍 Bilingual support: Ukrainian 🇺🇦 & English 🇬🇧 (auto-detected)
- 🎨 Premium dark UI with animated background, glassmorphism, radar rings
- 📈 Session stats: duration, baseline, peak strength
- ⚠️ Ferromagnetic-only detection disclaimer
- 🔧 Settings screen with audio/haptic toggles
