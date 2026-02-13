@preconcurrency import CoreMotion
import Foundation

/// Actor responsible for streaming raw magnetometer data from the iPhone's sensor.
/// Uses uncalibrated magnetic field data to detect localized ferrous interference.
actor MagnetometerActor {
    
    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 1.0 / 60.0 // 60 Hz polling rate
    
    /// Current magnetic field strength in microtesla (µT)
    struct MagneticReading: Sendable {
        let x: Double
        let y: Double
        let z: Double
        let magnitude: Double
        let timestamp: Date
        
        init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
            self.magnitude = sqrt(x * x + y * y + z * z)
            self.timestamp = Date()
        }
    }
    
    /// Check if magnetometer is available on this device
    var isAvailable: Bool {
        motionManager.isMagnetometerAvailable
    }
    
    /// Start streaming magnetometer data as an AsyncStream
    func startStream() -> AsyncStream<MagneticReading> {
        let manager = self.motionManager
        let interval = self.updateInterval
        
        return AsyncStream { continuation in
            manager.magnetometerUpdateInterval = interval
            manager.startMagnetometerUpdates(to: .main) { data, error in
                guard let data = data, error == nil else { return }
                
                let reading = MagneticReading(
                    x: data.magneticField.x,
                    y: data.magneticField.y,
                    z: data.magneticField.z
                )
                continuation.yield(reading)
            }
            
            continuation.onTermination = { _ in
                manager.stopMagnetometerUpdates()
            }
        }
    }
    
    /// Stop all magnetometer updates
    func stop() {
        motionManager.stopMagnetometerUpdates()
    }
}
