import SwiftUI

/// Premium animated background with rotating gradient orbs that react to detection level.
struct AnimatedBackground: View {
    let isScanning: Bool
    let detectionLevel: SignalProcessor.DetectionLevel
    let rotation: Double
    
    var body: some View {
        ZStack {
            // Base dark gradient
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.12),
                    Color(red: 0.06, green: 0.02, blue: 0.10),
                    Color(red: 0.02, green: 0.02, blue: 0.06),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Ambient orb 1
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            orbColor.opacity(0.3),
                            orbColor.opacity(0.05),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -200)
                .rotationEffect(.degrees(rotation))
                .blur(radius: 60)
            
            // Ambient orb 2
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            secondOrbColor.opacity(0.2),
                            secondOrbColor.opacity(0.03),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: 120, y: 300)
                .rotationEffect(.degrees(-rotation * 0.7))
                .blur(radius: 80)
            
            // Subtle grid pattern overlay
            GridPatternView()
                .opacity(isScanning ? 0.06 : 0.03)
            
            // Noise texture
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.05)
        }
        .animation(.easeInOut(duration: 1.0), value: detectionLevel)
    }
    
    private var orbColor: Color {
        switch detectionLevel {
        case .none: return Color(red: 0.2, green: 0.5, blue: 1.0) // Blue
        case .weak: return Color(red: 0.2, green: 0.8, blue: 0.5) // Green
        case .moderate: return Color(red: 0.9, green: 0.8, blue: 0.2) // Yellow
        case .strong: return Color(red: 1.0, green: 0.5, blue: 0.2) // Orange
        case .veryStrong: return Color(red: 1.0, green: 0.2, blue: 0.3) // Red
        }
    }
    
    private var secondOrbColor: Color {
        switch detectionLevel {
        case .none: return Color(red: 0.4, green: 0.2, blue: 0.8)
        case .weak: return Color(red: 0.1, green: 0.6, blue: 0.5)
        case .moderate: return Color(red: 0.8, green: 0.6, blue: 0.1)
        case .strong: return Color(red: 0.9, green: 0.3, blue: 0.1)
        case .veryStrong: return Color(red: 0.9, green: 0.1, blue: 0.4)
        }
    }
}

/// Subtle grid lines for a techy sci-fi feel
struct GridPatternView: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 30
            
            // Vertical lines
            var x: CGFloat = 0
            while x < size.width {
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                context.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 0.5)
                x += spacing
            }
            
            // Horizontal lines
            var y: CGFloat = 0
            while y < size.height {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 0.5)
                y += spacing
            }
        }
    }
}

#Preview {
    AnimatedBackground(
        isScanning: true,
        detectionLevel: .moderate,
        rotation: 45
    )
}
