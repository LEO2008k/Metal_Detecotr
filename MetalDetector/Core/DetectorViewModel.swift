import SwiftUI

/// Main ViewModel that orchestrates the magnetometer, signal processor, and feedback manager.
@Observable
@MainActor
final class DetectorViewModel {
    
    // MARK: - Dependencies
    
    let signalProcessor = SignalProcessor()
    let feedbackManager = FeedbackManager()
    private let magnetometer = MagnetometerActor()
    
    // MARK: - State
    
    private(set) var isScanning: Bool = false
    private(set) var isMagnetometerAvailable: Bool = true
    private(set) var statusMessage: String = L10n.readyToSearch
    
    /// History of recent readings for the waveform display
    private(set) var readingHistory: [Double] = []
    private let maxHistoryCount = 80
    
    /// Scan session stats
    private(set) var scanDuration: TimeInterval = 0
    private(set) var peakStrength: Double = 0
    
    private var scanTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    
    // MARK: - Actions
    
    func toggleScanning() {
        if isScanning {
            stopScanning()
        } else {
            startScanning()
        }
    }
    
    func startScanning() {
        guard !isScanning else { return }
        
        isScanning = true
        scanDuration = 0
        peakStrength = 0
        readingHistory.removeAll()
        signalProcessor.recalibrate()
        feedbackManager.start()
        statusMessage = L10n.calibrating
        
        // Start timer
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                scanDuration += 1
            }
        }
        
        // Start sensor stream
        scanTask = Task {
            let stream = await magnetometer.startStream()
            for await reading in stream {
                guard !Task.isCancelled else { break }
                
                signalProcessor.process(reading)
                
                if signalProcessor.isCalibrated {
                    if statusMessage == L10n.calibrating {
                        statusMessage = L10n.scanning
                    }
                    
                    // Update feedback
                    feedbackManager.updateFeedback(
                        strength: signalProcessor.normalizedStrength,
                        level: signalProcessor.detectionLevel
                    )
                    
                    // Track history for waveform
                    readingHistory.append(signalProcessor.normalizedStrength)
                    if readingHistory.count > maxHistoryCount {
                        readingHistory.removeFirst()
                    }
                    
                    // Track peak
                    if signalProcessor.delta > peakStrength {
                        peakStrength = signalProcessor.delta
                    }
                    
                    // Update status
                    statusMessage = signalProcessor.detectionLevel.description
                }
            }
        }
    }
    
    func stopScanning() {
        scanTask?.cancel()
        timerTask?.cancel()
        scanTask = nil
        timerTask = nil
        
        feedbackManager.stop()
        
        Task {
            await magnetometer.stop()
        }
        
        isScanning = false
        statusMessage = L10n.stopped
    }
    
    func recalibrate() {
        signalProcessor.recalibrate()
        statusMessage = L10n.calibrating
    }
    
    /// Formatted scan duration
    var formattedDuration: String {
        let minutes = Int(scanDuration) / 60
        let seconds = Int(scanDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
