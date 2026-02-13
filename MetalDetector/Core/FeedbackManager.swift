import AVFoundation
import CoreHaptics
import UIKit

/// Manages audio (VCO-style tone) and haptic feedback correlated with detection strength.
@Observable
final class FeedbackManager {
    
    // MARK: - Audio
    
    private var audioEngine: AVAudioEngine?
    private var toneNode: AVAudioSourceNode?
    private var currentFrequency: Double = 200
    private var targetFrequency: Double = 200
    private var phase: Double = 0
    private let sampleRate: Double = 44100
    
    /// Audio feedback enabled
    var isAudioEnabled: Bool = true
    
    /// Haptic feedback enabled
    var isHapticEnabled: Bool = true
    
    // MARK: - Haptics
    
    private var hapticEngine: CHHapticEngine?
    private var hapticPlayer: CHHapticAdvancedPatternPlayer?
    private var lastHapticTime: Date = .distantPast
    
    // MARK: - Frequency Range (VCO style)
    
    private let minFrequency: Double = 200    // Low tone when no detection
    private let maxFrequency: Double = 1800   // High-pitched beep at strong detection
    
    // MARK: - State
    
    private(set) var isRunning: Bool = false
    
    // MARK: - Lifecycle
    
    func start() {
        setupAudio()
        setupHaptics()
        isRunning = true
    }
    
    func stop() {
        stopAudio()
        stopHaptics()
        isRunning = false
    }
    
    // MARK: - Update Feedback
    
    /// Update feedback intensity based on normalized detection strength (0.0 - 1.0)
    func updateFeedback(strength: Double, level: SignalProcessor.DetectionLevel) {
        // Audio: map strength to frequency (VCO-style)
        if isAudioEnabled && level != .none {
            targetFrequency = minFrequency + (maxFrequency - minFrequency) * strength
        } else {
            targetFrequency = 0
        }
        
        // Haptics: intensity correlates with magnetic flux density gradient
        if isHapticEnabled && level != .none {
            triggerHaptic(intensity: Float(strength), level: level)
        }
    }
    
    // MARK: - Audio Setup
    
    private func setupAudio() {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        toneNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let buffer = ablPointer[0]
            let buf = buffer.mData!.assumingMemoryBound(to: Float.self)
            
            // Smooth frequency transition
            let freq = self.currentFrequency + (self.targetFrequency - self.currentFrequency) * 0.05
            self.currentFrequency = freq
            
            for frame in 0..<Int(frameCount) {
                if freq > 0 {
                    let value = sin(self.phase * 2.0 * .pi)
                    buf[frame] = Float(value * 0.3) // Volume at 30%
                    self.phase += freq / self.sampleRate
                    if self.phase >= 1.0 { self.phase -= 1.0 }
                } else {
                    buf[frame] = 0
                }
            }
            return noErr
        }
        
        guard let toneNode = toneNode else { return }
        
        audioEngine.attach(toneNode)
        audioEngine.connect(toneNode, to: audioEngine.mainMixerNode, format: format)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }
    
    private func stopAudio() {
        audioEngine?.stop()
        if let toneNode = toneNode {
            audioEngine?.detach(toneNode)
        }
        toneNode = nil
        audioEngine = nil
    }
    
    // MARK: - Haptic Setup
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.playsHapticsOnly = true
            try hapticEngine?.start()
            
            hapticEngine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason)")
                self?.hapticEngine = nil
            }
            
            hapticEngine?.resetHandler = { [weak self] in
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Haptic engine creation failed: \(error)")
        }
    }
    
    private func triggerHaptic(intensity: Float, level: SignalProcessor.DetectionLevel) {
        guard let hapticEngine = hapticEngine else { return }
        
        // Rate-limit haptic events based on detection level
        let minInterval: TimeInterval
        switch level {
        case .none: return
        case .weak: minInterval = 0.5
        case .moderate: minInterval = 0.25
        case .strong: minInterval = 0.1
        case .veryStrong: minInterval = 0.05
        }
        
        let now = Date()
        guard now.timeIntervalSince(lastHapticTime) >= minInterval else { return }
        lastHapticTime = now
        
        do {
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: intensity)
            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensityParam, sharpness],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Haptic playback failed: \(error)")
        }
    }
    
    private func stopHaptics() {
        hapticEngine?.stop()
        hapticEngine = nil
    }
}
