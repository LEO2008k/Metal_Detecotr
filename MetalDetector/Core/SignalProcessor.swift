import Foundation

/// Processes raw magnetometer readings to filter noise and detect anomalies.
/// Implements a Low-Pass Filter to smooth sensor jitter from internal iPhone components.
@Observable
final class SignalProcessor: @unchecked Sendable {
    
    // MARK: - Published State
    
    /// Smoothed magnetic field magnitude (µT)
    private(set) var smoothedMagnitude: Double = 0
    
    /// Raw magnetic field magnitude (µT)
    private(set) var rawMagnitude: Double = 0
    
    /// Baseline magnetic field (Earth's ~25-65 µT)
    private(set) var baseline: Double = 0
    
    /// Baseline X component
    private(set) var baselineX: Double = 0
    
    /// Baseline Y component
    private(set) var baselineY: Double = 0
    
    /// Delta from baseline — the actual "detection" value
    private(set) var delta: Double = 0
    
    /// Normalized detection strength (0.0 - 1.0)
    private(set) var normalizedStrength: Double = 0
    
    /// Whether a metal object is likely detected
    private(set) var isDetecting: Bool = false
    
    /// Detection level for UI feedback
    private(set) var detectionLevel: DetectionLevel = .none
    
    /// Smoothed X/Y components for directional detection
    private(set) var smoothedX: Double = 0
    private(set) var smoothedY: Double = 0
    
    /// Angle in radians where metal is detected (from atan2 of delta X/Y)
    private(set) var detectionAngle: Double = 0
    
    /// Distance from center for radar blip (0.0 = center, 1.0 = edge)
    private(set) var detectionDistance: Double = 0
    
    // MARK: - Configuration
    
    /// Low-pass filter coefficient (0.0 = no smoothing, 1.0 = infinite smoothing)
    private let filterAlpha: Double = 0.15
    
    /// Threshold for "detection" above baseline (µT)
    private let detectionThreshold: Double = 15.0
    
    /// Strong detection threshold (µT)
    private let strongThreshold: Double = 50.0
    
    /// Very strong detection threshold (µT)
    private let veryStrongThreshold: Double = 120.0
    
    /// Maximum expected delta for normalization
    private let maxDelta: Double = 300.0
    
    // MARK: - Calibration
    
    private var calibrationReadings: [Double] = []
    private var calibrationX: [Double] = []
    private var calibrationY: [Double] = []
    private let calibrationCount = 30
    private(set) var isCalibrated: Bool = false
    
    // MARK: - Detection Level
    
    enum DetectionLevel: Sendable {
        case none
        case weak
        case moderate
        case strong
        case veryStrong
        
        var description: String {
            switch self {
            case .none: return L10n.noSignal
            case .weak: return L10n.weakSignal
            case .moderate: return L10n.moderateSignal
            case .strong: return L10n.strongSignal
            case .veryStrong: return L10n.veryStrongSignal
            }
        }
        
        var color: String {
            switch self {
            case .none: return "dimGreen"
            case .weak: return "signalGreen"
            case .moderate: return "signalYellow"
            case .strong: return "signalOrange"
            case .veryStrong: return "signalRed"
            }
        }
    }
    
    // MARK: - Processing
    
    /// Process a new magnetometer reading
    func process(_ reading: MagnetometerActor.MagneticReading) {
        rawMagnitude = reading.magnitude
        
        // Apply low-pass filter to magnitude
        if smoothedMagnitude == 0 {
            smoothedMagnitude = reading.magnitude
            smoothedX = reading.x
            smoothedY = reading.y
        } else {
            smoothedMagnitude = smoothedMagnitude + filterAlpha * (reading.magnitude - smoothedMagnitude)
            smoothedX = smoothedX + filterAlpha * (reading.x - smoothedX)
            smoothedY = smoothedY + filterAlpha * (reading.y - smoothedY)
        }
        
        // Calibration phase — collect baseline readings
        if !isCalibrated {
            calibrationReadings.append(reading.magnitude)
            calibrationX.append(reading.x)
            calibrationY.append(reading.y)
            if calibrationReadings.count >= calibrationCount {
                baseline = calibrationReadings.reduce(0, +) / Double(calibrationReadings.count)
                baselineX = calibrationX.reduce(0, +) / Double(calibrationX.count)
                baselineY = calibrationY.reduce(0, +) / Double(calibrationY.count)
                isCalibrated = true
            }
            return
        }
        
        // Calculate delta from baseline
        delta = abs(smoothedMagnitude - baseline)
        
        // Calculate directional delta (X/Y deviation from baseline)
        let deltaX = smoothedX - baselineX
        let deltaY = smoothedY - baselineY
        
        // Compute angle where the anomaly is (in radians)
        detectionAngle = atan2(deltaY, deltaX)
        
        // Distance = how far the blip is from center (based on strength)
        let xyMagnitude = sqrt(deltaX * deltaX + deltaY * deltaY)
        detectionDistance = min(xyMagnitude / maxDelta * 2.5, 0.85)
        
        // Normalize to 0-1 range
        normalizedStrength = min(delta / maxDelta, 1.0)
        
        // Determine detection level
        if delta < detectionThreshold {
            detectionLevel = .none
            isDetecting = false
        } else if delta < strongThreshold {
            detectionLevel = delta < 30 ? .weak : .moderate
            isDetecting = true
        } else if delta < veryStrongThreshold {
            detectionLevel = .strong
            isDetecting = true
        } else {
            detectionLevel = .veryStrong
            isDetecting = true
        }
    }
    
    /// Reset calibration to recalibrate the baseline
    func recalibrate() {
        calibrationReadings.removeAll()
        calibrationX.removeAll()
        calibrationY.removeAll()
        isCalibrated = false
        baseline = 0
        baselineX = 0
        baselineY = 0
        delta = 0
        normalizedStrength = 0
        detectionLevel = .none
        isDetecting = false
        detectionAngle = 0
        detectionDistance = 0
    }
}
