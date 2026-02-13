import SwiftUI
@preconcurrency import CoreMotion

/// Construction-style spirit level with horizontal and vertical vials.
/// Shows bubble that slides within glass tubes based on device tilt.
struct BubbleLevelView: View {
    @State private var pitch: Double = 0  // front-back tilt
    @State private var roll: Double = 0   // left-right tilt
    @State private var isActive = false
    
    private let motionManager = CMMotionManager()
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            // ====== HORIZONTAL VIAL (Left-Right) ======
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
                    Text(L10n.leftRight)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                    Spacer()
                    Text(String(format: "%+.1f°", roll))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(colorForAngle(roll))
                }
                .padding(.horizontal, 4)
                
                LevelVial(
                    offset: roll,
                    isHorizontal: true,
                    color: colorForAngle(roll)
                )
                .frame(height: 56)
            }
            .padding(.horizontal, 24)
            
            // ====== CIRCULAR BULL'S EYE (2D) ======
            BullsEyeLevel(roll: roll, pitch: pitch)
                .frame(width: 200, height: 200)
            
            // ====== VERTICAL VIAL (Front-Back) ======
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.up.and.down")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
                    Text(L10n.frontBack)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                    Spacer()
                    Text(String(format: "%+.1f°", pitch))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(colorForAngle(pitch))
                }
                .padding(.horizontal, 4)
                
                LevelVial(
                    offset: pitch,
                    isHorizontal: true,
                    color: colorForAngle(pitch)
                )
                .frame(height: 56)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Status
            Text(levelStatusText)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(overallColor)
                .padding(.bottom, 20)
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
            self.roll = data.acceleration.x * 90.0
            self.pitch = data.acceleration.y * 90.0
        }
        isActive = true
    }
    
    private func stopMotion() {
        motionManager.stopAccelerometerUpdates()
        isActive = false
    }
    
    // MARK: - Helpers
    
    private func colorForAngle(_ angle: Double) -> Color {
        let absAngle = abs(angle)
        if absAngle < 1.5 { return Color(red: 0.2, green: 0.9, blue: 0.4) }
        if absAngle < 5 { return Color(red: 1.0, green: 0.85, blue: 0.2) }
        return Color(red: 1.0, green: 0.3, blue: 0.3)
    }
    
    private var overallColor: Color {
        let total = sqrt(roll * roll + pitch * pitch)
        if total < 2 { return Color(red: 0.2, green: 0.9, blue: 0.4) }
        if total < 8 { return Color(red: 1.0, green: 0.85, blue: 0.2) }
        return Color(red: 1.0, green: 0.3, blue: 0.3)
    }
    
    private var levelStatusText: String {
        let total = sqrt(roll * roll + pitch * pitch)
        if total < 2 { return L10n.levelPerfect }
        if total < 8 { return L10n.levelSlightTilt }
        return L10n.levelTilted
    }
}

// MARK: - Level Vial (tube with bubble)

/// A single construction-level vial (glass tube with liquid and a bubble).
struct LevelVial: View {
    let offset: Double      // degrees of tilt
    let isHorizontal: Bool
    let color: Color
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let bubbleWidth: CGFloat = 50
            let maxTravel = (width - bubbleWidth) / 2 - 8
            let bubbleOffset = CGFloat(max(-1, min(offset / 15.0, 1))) * maxTravel
            
            ZStack {
                // Glass tube body
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.08, green: 0.15, blue: 0.1).opacity(0.9),
                                Color(red: 0.05, green: 0.2, blue: 0.1).opacity(0.8),
                                Color(red: 0.08, green: 0.15, blue: 0.1).opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Glass tube border
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .white.opacity(0.05),
                                .white.opacity(0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
                
                // Graduation marks
                ForEach(-3..<4, id: \.self) { i in
                    let x = CGFloat(i) * (width / 8)
                    Rectangle()
                        .fill(.white.opacity(i == 0 ? 0.4 : 0.1))
                        .frame(width: i == 0 ? 2 : 1, height: i == 0 ? height * 0.6 : height * 0.35)
                        .offset(x: x)
                }
                
                // Liquid shimmer (top highlight)
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.08), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .padding(2)
                
                // THE BUBBLE
                ZStack {
                    // Bubble shadow
                    Capsule()
                        .fill(color.opacity(0.2))
                        .frame(width: bubbleWidth + 6, height: height - 10)
                        .blur(radius: 4)
                    
                    // Bubble body
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.15),
                                    color.opacity(0.05),
                                    color.opacity(0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: bubbleWidth, height: height - 14)
                    
                    // Bubble border
                    Capsule()
                        .stroke(color.opacity(0.4), lineWidth: 1)
                        .frame(width: bubbleWidth, height: height - 14)
                    
                    // Bubble highlight (glass reflection)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: bubbleWidth - 8, height: (height - 14) * 0.4)
                        .offset(y: -(height - 14) * 0.15)
                }
                .offset(x: bubbleOffset)
                .animation(.interpolatingSpring(stiffness: 120, damping: 14), value: offset)
            }
        }
    }
}

// MARK: - Bull's Eye Level (circular 2D)

/// Small circular bull's eye level — shows combined X/Y tilt.
struct BullsEyeLevel: View {
    let roll: Double
    let pitch: Double
    
    var body: some View {
        let maxOffset: CGFloat = 70
        let bubbleX = CGFloat(max(-1, min(roll / 20.0, 1))) * maxOffset
        let bubbleY = CGFloat(max(-1, min(-pitch / 20.0, 1))) * maxOffset
        let tiltTotal = sqrt(roll * roll + pitch * pitch)
        
        let bubbleColor: Color = {
            if tiltTotal < 2 { return Color(red: 0.2, green: 0.9, blue: 0.4) }
            if tiltTotal < 8 { return Color(red: 1.0, green: 0.85, blue: 0.2) }
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        }()
        
        ZStack {
            // Outer housing
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.06, green: 0.14, blue: 0.08),
                            Color(red: 0.04, green: 0.1, blue: 0.06)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
            
            // Concentric rings
            ForEach(1..<5, id: \.self) { i in
                Circle()
                    .stroke(.white.opacity(i == 1 ? 0.2 : 0.06), lineWidth: i == 1 ? 1.5 : 0.5)
                    .frame(width: CGFloat(i) * 40, height: CGFloat(i) * 40)
            }
            
            // Crosshair
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(width: 1, height: 180)
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(width: 180, height: 1)
            
            // Center target
            Circle()
                .stroke(.green.opacity(0.5), lineWidth: 2)
                .frame(width: 30, height: 30)
            
            // THE BUBBLE
            ZStack {
                Circle()
                    .fill(bubbleColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .blur(radius: 6)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.3),
                                bubbleColor.opacity(0.15),
                                bubbleColor.opacity(0.05)
                            ],
                            center: .init(x: 0.35, y: 0.35),
                            startRadius: 0,
                            endRadius: 14
                        )
                    )
                    .frame(width: 28, height: 28)
                
                Circle()
                    .stroke(bubbleColor.opacity(0.5), lineWidth: 1)
                    .frame(width: 28, height: 28)
                
                // Highlight
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.4), .clear],
                            center: .init(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 8
                        )
                    )
                    .frame(width: 14, height: 14)
                    .offset(x: -3, y: -3)
            }
            .offset(x: bubbleX, y: bubbleY)
            .animation(.interpolatingSpring(stiffness: 100, damping: 12), value: roll)
            .animation(.interpolatingSpring(stiffness: 100, damping: 12), value: pitch)
            
            // Border
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            
            // Glass reflection
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.06), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(3)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BubbleLevelView()
    }
}
