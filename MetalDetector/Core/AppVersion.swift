import Foundation

/// App version management — reads from Info.plist and provides display string.
struct AppVersion {
    /// Marketing version (e.g. "1.0.0")
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Build number (e.g. "1")
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Full display string (e.g. "1.0.0 (1)")
    static var display: String {
        "\(version) (\(build))"
    }
}
