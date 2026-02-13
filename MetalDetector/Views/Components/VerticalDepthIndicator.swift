import SwiftUI

/// Vertical indicator showing whether detected metal is above or below the phone.
/// Uses the Z-axis delta from the magnetometer baseline.
struct VerticalDepthIndicator: View {
    let verticalDelta: Double
    let direction: SignalProcessor.VerticalDirection
    let isDetecting: Bool
    
    @State private var arrowPulse: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 6) {
            // "Above" label
            Text(L10n.above)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(direction == .above ? 0.8 : 0.2))
            
            // Up arrow
            Image(systemName: "chevron.up")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(direction == .above ? indicatorColor : .white.opacity(0.15))
                .scaleEffect(direction == .above && isDetecting ? arrowPulse : 1.0)
            
            Image(systemName: "chevron.up")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(direction == .above ? indicatorColor.opacity(0.5) : .white.opacity(0.08))
            
            Spacer()
            
            // Track bar
            ZStack {
                // Background track
                Capsule()
                    .fill(.white.opacity(0.06))
                    .frame(width: 6)
                
                // Level marker
                Capsule()
                    .fill(.white.opacity(0.15))
                    .frame(width: 10, height: 3)
                
                // Active indicator dot
                if isDetecting {
                    Circle()
                        .fill(indicatorColor)
                        .frame(width: 12, height: 12)
                        .shadow(color: indicatorColor, radius: 6)
                        .offset(y: indicatorOffset)
                        .animation(.easeInOut(duration: 0.3), value: verticalDelta)
                }
            }
            
            Spacer()
            
            // Down arrow
            Image(systemName: "chevron.down")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(direction == .below ? indicatorColor.opacity(0.5) : .white.opacity(0.08))
            
            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(direction == .below ? indicatorColor : .white.opacity(0.15))
                .scaleEffect(direction == .below && isDetecting ? arrowPulse : 1.0)
            
            // "Below" label
            Text(L10n.below)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(direction == .below ? 0.8 : 0.2))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .opacity(0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                arrowPulse = 1.3
            }
        }
    }
    
    // MARK: - Computed
    
    private var indicatorOffset: CGFloat {
        // Map verticalDelta to Y offset: negative = up, positive = down
        let maxOffset: CGFloat = 50
        let clamped = max(-60, min(verticalDelta, 60))
        return CGFloat(-clamped / 60.0) * maxOffset
    }
    
    private var indicatorColor: Color {
        switch direction {
        case .above: return Color(red: 0.3, green: 0.8, blue: 1.0) // Cyan-blue
        case .below: return Color(red: 1.0, green: 0.6, blue: 0.2)  // Orange
        case .level: return Color(red: 0.3, green: 0.9, blue: 0.4)  // Green
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 20) {
            VerticalDepthIndicator(verticalDelta: -30, direction: .above, isDetecting: true)
                .frame(width: 44, height: 200)
            VerticalDepthIndicator(verticalDelta: 0, direction: .level, isDetecting: true)
                .frame(width: 44, height: 200)
            VerticalDepthIndicator(verticalDelta: 30, direction: .below, isDetecting: true)
                .frame(width: 44, height: 200)
        }
    }
}
