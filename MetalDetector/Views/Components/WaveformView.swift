import SwiftUI

/// Live waveform display showing recent detection history.
/// Smooth animated line with gradient fill underneath.
struct WaveformView: View {
    let readings: [Double]
    
    @State private var appear = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Background panel
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
                
                if readings.count >= 2 {
                    // Gradient fill under the line
                    fillPath(width: width - 32, height: height - 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    waveColor.opacity(0.3),
                                    waveColor.opacity(0.05),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Main line
                    linePath(width: width - 32, height: height - 24)
                        .stroke(
                            LinearGradient(
                                colors: [waveColor.opacity(0.5), waveColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    // Dot at the end
                    if let last = readings.last {
                        let x = width - 16
                        let y = 12 + (height - 24) * (1 - last)
                        
                        Circle()
                            .fill(waveColor)
                            .frame(width: 6, height: 6)
                            .shadow(color: waveColor, radius: 6)
                            .position(x: x, y: y)
                    }
                } else {
                    // Placeholder
                    Text(L10n.collectingData)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                // Label
                VStack {
                    HStack {
                        Label(L10n.waveform, systemImage: "waveform.path")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.35))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(12)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appear = true
            }
        }
        .opacity(appear ? 1 : 0)
    }
    
    // MARK: - Paths
    
    private func linePath(width: CGFloat, height: CGFloat) -> Path {
        Path { path in
            guard readings.count >= 2 else { return }
            
            let stepX = width / CGFloat(readings.count - 1)
            
            path.move(to: CGPoint(x: 0, y: height * (1 - readings[0])))
            
            for index in 1..<readings.count {
                let x = stepX * CGFloat(index)
                let y = height * (1 - readings[index])
                
                // Smooth curve using quadratic bezier
                let prevX = stepX * CGFloat(index - 1)
                let prevY = height * (1 - readings[index - 1])
                let midX = (prevX + x) / 2
                
                path.addCurve(
                    to: CGPoint(x: x, y: y),
                    control1: CGPoint(x: midX, y: prevY),
                    control2: CGPoint(x: midX, y: y)
                )
            }
        }
    }
    
    private func fillPath(width: CGFloat, height: CGFloat) -> Path {
        var path = linePath(width: width, height: height)
        
        guard readings.count >= 2 else { return path }
        
        let stepX = width / CGFloat(readings.count - 1)
        
        path.addLine(to: CGPoint(x: stepX * CGFloat(readings.count - 1), y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
    
    private var waveColor: Color {
        guard let last = readings.last else { return .cyan }
        
        if last < 0.15 { return Color(red: 0.3, green: 0.7, blue: 1.0) }
        if last < 0.35 { return Color(red: 0.3, green: 0.9, blue: 0.5) }
        if last < 0.6 { return Color(red: 1.0, green: 0.85, blue: 0.2) }
        if last < 0.8 { return Color(red: 1.0, green: 0.5, blue: 0.15) }
        return Color(red: 1.0, green: 0.2, blue: 0.3)
    }
}

#Preview {
    ZStack {
        Color.black
        WaveformView(readings: [0.1, 0.15, 0.12, 0.3, 0.45, 0.5, 0.4, 0.35, 0.6, 0.8, 0.7, 0.5, 0.3])
            .frame(height: 70)
            .padding()
    }
}
