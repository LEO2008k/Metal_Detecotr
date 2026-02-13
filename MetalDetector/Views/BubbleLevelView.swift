import SwiftUI
@preconcurrency import CoreMotion

/// Bubble level (spirit level) view using accelerometer data.
/// Shows a 2D bubble that moves based on device tilt.
struct BubbleLevelView: View {
    @State private var pitch: Double = 0  // front-back tilt
    @State private var roll: Double = 0   // left-right tilt
    @State private var isActive = false
    
    private let motionManager = CMMotionManager()
    private let levelSize: CGFloat = 260
    private let bubbleSize: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 24) {
            // Title
            VStack(spacing: 4) {
                Text(L10n.bubbleLevel)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(L10n.bubbleLevelSubtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            // Level visualization
            ZStack {
                // Outer ring glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [levelColor.opacity(0.15), .clear],
                            center: .center,
                            startRadius: levelSize / 2 - 20,
                            endRadius: levelSize / 2 + 30
                        )
                    )
                    .frame(width: levelSize + 60, height: levelSize + 60)
                
                // Outer circle
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: levelSize, height: levelSize)
                
                // Grid rings
                ForEach(1..<4, id: \.self) { i in
                    let size = levelSize * CGFloat(i) / 4.0
                    Circle()
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                        .frame(width: size, height: size)
                }
                
                // Cross hairs
                CrossHairsLevel()
                    .frame(width: levelSize, height: levelSize)
                    .opacity(0.12)
                
                // Center target (where bubble should be)
                Circle()
                    .stroke(Color.green.opacity(0.4), lineWidth: 2)
                    .frame(width: bubbleSize + 8, height: bubbleSize + 8)
                
                Circle()
                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    .frame(width: bubbleSize + 20, height: bubbleSize + 20)
                
                // The bubble
                ZStack {
                    // Glow
                    Circle()
                        .fill(levelColor.opacity(0.3))
                        .frame(width: bubbleSize + 16, height: bubbleSize + 16)
                        .blur(radius: 8)
                    
                    // Main bubble
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.9),
                                    levelColor.opacity(0.8),
                                    levelColor.opacity(0.5)
                                ],
                                center: .init(x: 0.35, y: 0.35),
                                startRadius: 0,
                                endRadius: bubbleSize / 2
                            )
                        )
                        .frame(width: bubbleSize, height: bubbleSize)
                        .shadow(color: levelColor.opacity(0.5), radius: 10)
                    
                    // Highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.6), .clear],
                                center: .init(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: bubbleSize / 3
                            )
                        )
                        .frame(width: bubbleSize * 0.6, height: bubbleSize * 0.6)
                        .offset(x: -bubbleSize * 0.1, y: -bubbleSize * 0.1)
                }
                .offset(x: bubbleOffsetX, y: bubbleOffsetY)
                .animation(.interpolatingSpring(stiffness: 80, damping: 12), value: pitch)
                .animation(.interpolatingSpring(stiffness: 80, damping: 12), value: roll)
                
                // Degree labels
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(String(format: "%.1f°", tiltAngle))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(levelColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .frame(width: levelSize, height: levelSize)
            }
            
            // Tilt values
            HStack(spacing: 20) {
                TiltCard(
                    label: L10n.leftRight,
                    value: roll,
                    icon: "arrow.left.and.right"
                )
                
                TiltCard(
                    label: L10n.frontBack,
                    value: pitch,
                    icon: "arrow.up.and.down"
                )
            }
            .padding(.horizontal, 24)
            
            // Level status
            Text(levelStatusText)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(levelColor)
                .padding(.top, 8)
            
            Spacer()
        }
        .onAppear { startMotion() }
        .onDisappear { stopMotion() }
    }
    
    // MARK: - Motion
    
    private func startMotion() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            guard let data = data else { return }
            // Accelerometer gives gravity components: x = roll, y = pitch
            self.roll = data.acceleration.x * 90.0   // degrees
            self.pitch = data.acceleration.y * 90.0   // degrees
        }
        isActive = true
    }
    
    private func stopMotion() {
        motionManager.stopAccelerometerUpdates()
        isActive = false
    }
    
    // MARK: - Computed
    
    private var bubbleOffsetX: CGFloat {
        let maxOffset = (levelSize - bubbleSize) / 2 - 10
        return CGFloat(roll / 45.0) * maxOffset  // ±45° = full range
    }
    
    private var bubbleOffsetY: CGFloat {
        let maxOffset = (levelSize - bubbleSize) / 2 - 10
        return CGFloat(-pitch / 45.0) * maxOffset
    }
    
    private var tiltAngle: Double {
        sqrt(pitch * pitch + roll * roll)
    }
    
    private var levelColor: Color {
        let angle = tiltAngle
        if angle < 2 {
            return Color(red: 0.2, green: 0.9, blue: 0.4) // Green - level!
        } else if angle < 8 {
            return Color(red: 1.0, green: 0.85, blue: 0.2) // Yellow
        } else {
            return Color(red: 1.0, green: 0.3, blue: 0.3) // Red
        }
    }
    
    private var levelStatusText: String {
        let angle = tiltAngle
        if angle < 2 {
            return L10n.levelPerfect
        } else if angle < 8 {
            return L10n.levelSlightTilt
        } else {
            return L10n.levelTilted
        }
    }
}

// MARK: - Tilt Card

struct TiltCard: View {
    let label: String
    let value: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.cyan.opacity(0.6))
            
            Text(String(format: "%+.1f°", value))
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Cross Hairs for Level

struct CrossHairsLevel: View {
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
        Color.black.ignoresSafeArea()
        BubbleLevelView()
    }
}
