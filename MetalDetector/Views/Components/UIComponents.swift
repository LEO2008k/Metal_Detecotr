import SwiftUI

/// Premium scan button with pulsing glow animation when active.
struct ScanButton: View {
    let isScanning: Bool
    let action: () -> Void
    
    @State private var pulseOuter = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer pulse rings when scanning
                if isScanning {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.red.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                            .frame(width: 90 + CGFloat(i) * 16, height: 90 + CGFloat(i) * 16)
                            .scaleEffect(pulseOuter ? 1.1 : 0.95)
                            .opacity(pulseOuter ? 0 : 0.6)
                            .animation(
                                .easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.3),
                                value: pulseOuter
                            )
                    }
                }
                
                // Button outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: isScanning
                            ? [Color.red.opacity(0.8), Color.red.opacity(0.4)]
                            : [Color.cyan.opacity(0.6), Color.blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 82, height: 82)
                
                // Button fill
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isScanning
                            ? [Color(red: 0.9, green: 0.15, blue: 0.2), Color(red: 0.7, green: 0.1, blue: 0.15)]
                            : [Color(red: 0.15, green: 0.6, blue: 1.0), Color(red: 0.1, green: 0.4, blue: 0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: isScanning ? .red.opacity(0.4) : .cyan.opacity(0.3), radius: 12)
                
                // Icon
                if isScanning {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white)
                        .frame(width: 22, height: 22)
                } else {
                    Image(systemName: "waveform.badge.magnifyingglass")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: isScanning)
        .onAppear {
            pulseOuter = true
        }
    }
}

/// Secondary action button with glassmorphism style.
struct SecondaryButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .buttonStyle(.plain)
    }
}

/// Glassmorphic stat card for displaying scan metrics.
struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
            
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.85))
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 30) {
            ScanButton(isScanning: false) {}
            ScanButton(isScanning: true) {}
            
            HStack(spacing: 16) {
                StatCard(icon: "clock.fill", label: "Час", value: "02:45")
                StatCard(icon: "waveform", label: "Базова", value: "48 µT")
                StatCard(icon: "arrow.up", label: "Пік", value: "120 µT")
            }
            .padding(.horizontal)
            
            HStack(spacing: 24) {
                SecondaryButton(icon: "arrow.counterclockwise", label: "Калібрувати") {}
                SecondaryButton(icon: "speaker.wave.2.fill", label: "Звук") {}
            }
        }
    }
}
