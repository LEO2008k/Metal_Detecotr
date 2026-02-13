import SwiftUI

/// Concentric radar rings that pulse and glow based on detection strength.
/// Shows a directional blip indicating WHERE the metal is detected.
struct RadarRingView: View {
    let normalizedStrength: Double
    let detectionLevel: SignalProcessor.DetectionLevel
    let isScanning: Bool
    let isCalibrating: Bool
    let detectionAngle: Double   // radians — direction of metal
    let detectionDistance: Double // 0-1 — how far from center
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var sweepAngle: Double = 0
    @State private var glowOpacity: Double = 0.3
    @State private var blipPulse: CGFloat = 1.0
    
    private let ringCount = 4
    private let radarSize: CGFloat = 260
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            activeColor.opacity(glowOpacity * normalizedStrength),
                            activeColor.opacity(0.05),
                            .clear
                        ],
                        center: .center,
                        startRadius: 80,
                        endRadius: 160
                    )
                )
                .scaleEffect(pulseScale)
            
            // Concentric rings
            ForEach(0..<ringCount, id: \.self) { index in
                let progress = Double(index + 1) / Double(ringCount)
                let ringSize = progress * radarSize
                let isActive = normalizedStrength > (Double(index) / Double(ringCount))
                
                Circle()
                    .stroke(
                        isActive ? activeColor.opacity(0.6 - progress * 0.3) : Color.white.opacity(0.08),
                        lineWidth: isActive ? 2.5 : 1
                    )
                    .frame(width: ringSize, height: ringSize)
                    .scaleEffect(isActive && isScanning ? 1.0 + CGFloat(normalizedStrength) * 0.03 : 1.0)
            }
            
            // Sweep line (radar style)
            if isScanning {
                SweepLine(angle: sweepAngle, color: activeColor)
                    .frame(width: radarSize, height: radarSize)
            }
            
            // Cross-hairs
            CrossHairs()
                .frame(width: radarSize, height: radarSize)
                .opacity(0.15)
            
            // MARK: - Metal Detection Blip 🎯
            if isScanning && detectionLevel != .none {
                MetalBlip(
                    angle: detectionAngle,
                    distance: detectionDistance,
                    radarRadius: radarSize / 2,
                    color: activeColor,
                    level: detectionLevel,
                    blipPulse: blipPulse
                )
            }
            
            // Center circle
            ZStack {
                // Glow ring
                Circle()
                    .stroke(activeColor.opacity(0.5), lineWidth: 3)
                    .frame(width: 76, height: 76)
                    .blur(radius: 4)
                
                // Glass circle
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                // Center content
                if isCalibrating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.2)
                } else if isScanning {
                    VStack(spacing: 1) {
                        Image(systemName: detectionIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(activeColor)
                            .symbolEffect(.pulse, isActive: detectionLevel != .none)
                        
                        Text("\(Int(normalizedStrength * 100))%")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: isScanning) { _, newValue in
            if newValue {
                startAnimations()
            }
        }
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        sweepAngle = 0
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            sweepAngle = 360
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
            pulseScale = 1.08
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever()) {
            glowOpacity = 0.6
        }
        
        withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
            blipPulse = 1.4
        }
    }
    
    // MARK: - Helpers
    
    private var activeColor: Color {
        switch detectionLevel {
        case .none: return Color(red: 0.3, green: 0.7, blue: 1.0)
        case .weak: return Color(red: 0.3, green: 0.9, blue: 0.5)
        case .moderate: return Color(red: 1.0, green: 0.85, blue: 0.2)
        case .strong: return Color(red: 1.0, green: 0.5, blue: 0.15)
        case .veryStrong: return Color(red: 1.0, green: 0.2, blue: 0.3)
        }
    }
    
    private var detectionIcon: String {
        switch detectionLevel {
        case .none: return "wave.3.right"
        case .weak: return "wave.3.right"
        case .moderate: return "antenna.radiowaves.left.and.right"
        case .strong: return "bolt.fill"
        case .veryStrong: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Metal Blip View

/// A glowing dot on the radar showing the direction and proximity of detected metal.
struct MetalBlip: View {
    let angle: Double       // radians
    let distance: Double    // 0.0 - 1.0
    let radarRadius: CGFloat
    let color: Color
    let level: SignalProcessor.DetectionLevel
    let blipPulse: CGFloat
    
    var body: some View {
        let clampedDistance = max(0.15, min(distance, 0.85))
        let radius = radarRadius * clampedDistance
        // Offset from center: angle is from atan2(y,x), adjust so "up" is -π/2 
        let x = Foundation.cos(angle) * radius
        let y = Foundation.sin(angle) * radius
        let blipSize: CGFloat = blipSizeForLevel
        
        ZStack {
            // Outer glow ring
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: blipSize * 3, height: blipSize * 3)
                .scaleEffect(blipPulse)
            
            // Middle ring
            Circle()
                .stroke(color.opacity(0.4), lineWidth: 1.5)
                .frame(width: blipSize * 2, height: blipSize * 2)
                .scaleEffect(blipPulse * 0.9)
            
            // Core dot
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, color],
                        center: .center,
                        startRadius: 0,
                        endRadius: blipSize / 2
                    )
                )
                .frame(width: blipSize, height: blipSize)
                .shadow(color: color, radius: 8)
                .shadow(color: color.opacity(0.5), radius: 16)
            
            // Direction indicator line from center
        }
        .offset(x: x, y: y)
        .animation(.easeInOut(duration: 0.3), value: angle)
        .animation(.easeInOut(duration: 0.3), value: distance)
    }
    
    private var blipSizeForLevel: CGFloat {
        switch level {
        case .none: return 6
        case .weak: return 10
        case .moderate: return 14
        case .strong: return 18
        case .veryStrong: return 22
        }
    }
}

// MARK: - Direction Line (from center to blip)

struct DirectionLine: View {
    let angle: Double
    let distance: Double
    let radarRadius: CGFloat
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let clampedDistance = max(0.15, min(distance, 0.85))
            let endRadius = radarRadius * clampedDistance
            
            let endPoint = CGPoint(
                x: center.x + Foundation.cos(angle) * endRadius,
                y: center.y + Foundation.sin(angle) * endRadius
            )
            
            let path = Path { p in
                p.move(to: center)
                p.addLine(to: endPoint)
            }
            
            context.stroke(
                path,
                with: .color(color.opacity(0.3)),
                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
            )
        }
    }
}

// MARK: - Sweep Line

struct SweepLine: View {
    let angle: Double
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            let startAngle = Angle(degrees: angle - 30)
            let endAngle = Angle(degrees: angle)
            
            let path = Path { p in
                p.move(to: center)
                p.addArc(center: center, radius: radius,
                         startAngle: startAngle, endAngle: endAngle,
                         clockwise: false)
                p.closeSubpath()
            }
            
            context.fill(
                path,
                with: .linearGradient(
                    Gradient(colors: [color.opacity(0.0), color.opacity(0.15)]),
                    startPoint: CGPoint(
                        x: center.x + Foundation.cos(startAngle.radians) * radius,
                        y: center.y + Foundation.sin(startAngle.radians) * radius
                    ),
                    endPoint: CGPoint(
                        x: center.x + Foundation.cos(endAngle.radians) * radius,
                        y: center.y + Foundation.sin(endAngle.radians) * radius
                    )
                )
            )
            
            let edgeEnd = CGPoint(
                x: center.x + Foundation.cos(endAngle.radians) * radius,
                y: center.y + Foundation.sin(endAngle.radians) * radius
            )
            let edgePath = Path { p in
                p.move(to: center)
                p.addLine(to: edgeEnd)
            }
            context.stroke(edgePath, with: .color(color.opacity(0.6)), lineWidth: 1.5)
        }
        .rotationEffect(.degrees(-90))
    }
}

// MARK: - Cross Hairs

struct CrossHairs: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            let vPath = Path { p in
                p.move(to: CGPoint(x: center.x, y: center.y - radius))
                p.addLine(to: CGPoint(x: center.x, y: center.y + radius))
            }
            context.stroke(vPath, with: .color(.white), lineWidth: 0.5)
            
            let hPath = Path { p in
                p.move(to: CGPoint(x: center.x - radius, y: center.y))
                p.addLine(to: CGPoint(x: center.x + radius, y: center.y))
            }
            context.stroke(hPath, with: .color(.white), lineWidth: 0.5)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        RadarRingView(
            normalizedStrength: 0.6,
            detectionLevel: .moderate,
            isScanning: true,
            isCalibrating: false,
            detectionAngle: .pi / 4,
            detectionDistance: 0.5
        )
        .frame(width: 280, height: 280)
    }
}
