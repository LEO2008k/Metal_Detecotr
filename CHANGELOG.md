# Changelog

All notable changes to MetalDetector will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-02-16

### Added

- 🔊 **Sound Meter (Шумомір)** — new tool for measuring ambient noise levels (dB)
  - Real-time analog gauge and digital readout
  - History graph and Avg/Max stats
  - Privacy-first: analyzes audio stream in RAM, never saves to file (`/dev/null`)
- 📏 **Ruler (Лінійка)** — visual ruler for measuring small objects on screen
  - Dual scale: Centimeters (Left) and Inches (Right)
  - Draggable slider for precise measurement
- 🛠️ **Rebranding** — App renamed to **"Smart Tools"** (formerly MetalDetector) to reflect expanded functionality
- 🔁 **Universal Toolset** — 4 main modes: Metal Detector, Spirit Level, Ruler, Sound Meter

### Changed

- Updated `Info.plist` with microphone usage description for Sound Meter
- App title in header changed to "Smart Tools"

## [1.1.1] - 2026-02-13

### Changed

- Renamed 'Ватерпас' → 'Рівень' in Ukrainian
- Redesigned bubble level to look like a real construction level

## [1.1.0] - 2026-02-13

### Added

- 🌍 **Language selector** in Settings
- 🫧 **Spirit Level** mode
- ↕️ **Vertical depth indicator** for Metal Detector
- 🔄 **Mode switcher**

## [1.0.0] - 2026-02-13

### Added

- Initial release with Metal Detector feature
