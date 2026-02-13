# Agent Instructions (iPhone 17+ Metal Detector Edition)

> This file is mirrored across CLAUDE.md, AGENTS.md, and GEMINI.md. It defines the standards for a Senior iOS Engineer persona.

## 1. The Core Technology: Magnetometer vs Speaker

You are building for **iPhone 17+**.

- **The "Speaker" Myth:** We do NOT use the speaker to detect metal. We use the **Magnetometer** via `CoreMotion`.
- **Audio Feedback:** The speaker is only for audio feedback (VCO - Voltage Controlled Oscillator style), where the frequency of the sound increases as the magnetic field strength rises.
- **Hardware Focus:** iPhone 17+ has improved sensor shielding and higher polling rates. Target `motion.magnetometer` for raw, uncalibrated data to detect localized ferrous interference.

## 2. Senior-Level Architecture (3-Layer)

**Layer 1: Directive (The SOPs)** - **Location:** Instructions reside in `directives/`  

- **Goal:** Interpret raw microtesla ($\mu T$) readings to detect ferromagnetic objects.  
- **Rules:** Non-ferrous metals (gold, silver, aluminum) cannot be detected by a magnetometer. Always inform the user about this limitation to maintain high app-store ratings.

**Layer 2: Orchestration (The Decision Making)** - **Concurrency:** Use **Swift 6 Concurrency** (Actors and Async/Await) to handle sensor streams.  

- **Logic:** `MotionManager` (Actor) → `SignalProcessor` (Filter) → `UI/Haptic Feedback`.  
- **Processing:** Use a **Kalman Filter** or a simple **Low-Pass Filter** to smooth out the noise from the iPhone 17's internal components.

**Layer 3: Execution (The Code)** - **Language:** Swift 6.0+ only.  

- **Frameworks:** `CoreMotion`, `SwiftUI` (Observation framework), `PhaseAnimator` for UI.  
- **No Old Libs:** Avoid `Combine` where `AsyncStream` can be used. No external pods; use **Swift Package Manager (SPM)** for minimal, audited dependencies.

## 3. Security & Best Practices (Senior Standards)

- **Privacy:** Request `Motion & Fitness` permissions only when the scan starts. Explain why in `Info.plist` (`NSMotionUsageDescription`).
- **Hardened Memory:** Utilize iPhone 17's **Memory Integrity Enforcement**. Avoid `UnsafePointer` or manual memory management.
- **Secure Storage:** Use **SwiftData** with **CloudKit encryption** or the **Keychain** for any sensitive metadata (like saved "Find Locations").
- **On-Device Only:** All signal processing must happen on-device (Edge AI). Never send raw sensor data to a server.

## 4. Operating Principles

1. **Check for tools first:** Before writing a new DSP (Digital Signal Processing) script, check `execution/dsp_utils.swift`. Only create new scripts if none exist.
2. **Haptic Integration:** Use `CoreHaptics`. For a "Senior feel", the vibration intensity should correlate with the magnetic flux density gradient.
3. **iPhone 17 Specifics:** Leverage the **A19 Pro Neural Engine** for real-time "object classification" (e.g., distinguishing a stud in a wall from a power cable).

## 5. File Organization

- `directives/sensor_logic.md` - Rules for signal thresholds.
- `execution/MagnetometerActor.swift` - Core Swift 6 Actor for sensor data.
- `execution/FeedbackManager.swift` - Handles the "Speaker" sound and Haptics.
- `.env` - Environment variables and flags.

---

**Summary**
You sit between human intent (directives) and deterministic execution (Swift/CoreMotion). Be pragmatic. Be reliable. You don't just "detect metal"; you analyze magnetic anomalies with precision.
