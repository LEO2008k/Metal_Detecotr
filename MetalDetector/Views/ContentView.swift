import SwiftUI

/// Main app mode
enum AppMode: String, CaseIterable {
    case metalDetector
    case bubbleLevel
    
    var icon: String {
        switch self {
        case .metalDetector: return "antenna.radiowaves.left.and.right"
        case .bubbleLevel: return "level"
        }
    }
    
    var label: String {
        switch self {
        case .metalDetector: return L10n.metalDetector
        case .bubbleLevel: return L10n.bubbleLevel
        }
    }
}

struct ContentView: View {
    @State private var viewModel = DetectorViewModel()
    @State private var showSettings = false
    @State private var backgroundRotation: Double = 0
    @State private var currentMode: AppMode = .metalDetector
    
    var body: some View {
        ZStack {
            // MARK: - Animated Background
            AnimatedBackground(
                isScanning: viewModel.isScanning,
                detectionLevel: viewModel.signalProcessor.detectionLevel,
                rotation: backgroundRotation
            )
            .ignoresSafeArea()
            
            // MARK: - Main Content
            VStack(spacing: 0) {
                // Top Bar
                topBar
                
                // Mode Switcher
                modeSwitcher
                    .padding(.top, 8)
                
                // Content based on mode
                switch currentMode {
                case .metalDetector:
                    metalDetectorContent
                case .bubbleLevel:
                    BubbleLevelView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.isScanning)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.signalProcessor.detectionLevel)
        .animation(.easeInOut(duration: 0.35), value: currentMode)
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                backgroundRotation = 360
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(feedbackManager: viewModel.feedbackManager)
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.appTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text(L10n.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    // MARK: - Mode Switcher
    
    private var modeSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(AppMode.allCases, id: \.rawValue) { mode in
                Button {
                    if currentMode == .metalDetector && viewModel.isScanning {
                        viewModel.stopScanning()
                    }
                    currentMode = mode
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 13, weight: .semibold))
                        Text(mode.label)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(currentMode == mode ? .white : .white.opacity(0.4))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        currentMode == mode
                        ? AnyShapeStyle(.ultraThinMaterial)
                        : AnyShapeStyle(.clear)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(currentMode == mode ? .white.opacity(0.15) : .clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.black.opacity(0.3), in: Capsule())
    }
    
    // MARK: - Metal Detector Content
    
    private var metalDetectorContent: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Radar + Vertical Indicator
            HStack(spacing: 12) {
                Spacer()
                
                // Radar Ring Visualization
                RadarRingView(
                    normalizedStrength: viewModel.signalProcessor.normalizedStrength,
                    detectionLevel: viewModel.signalProcessor.detectionLevel,
                    isScanning: viewModel.isScanning,
                    isCalibrating: !viewModel.signalProcessor.isCalibrated && viewModel.isScanning,
                    detectionAngle: viewModel.signalProcessor.detectionAngle,
                    detectionDistance: viewModel.signalProcessor.detectionDistance
                )
                .frame(width: 260, height: 260)
                
                // Vertical depth indicator (above/below)
                if viewModel.isScanning && viewModel.signalProcessor.isCalibrated {
                    VerticalDepthIndicator(
                        verticalDelta: viewModel.signalProcessor.verticalDelta,
                        direction: viewModel.signalProcessor.verticalDirection,
                        isDetecting: viewModel.signalProcessor.isDetecting
                    )
                    .frame(width: 44, height: 200)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                
                Spacer()
            }
            
            Spacer().frame(height: 20)
            
            // Detection Label
            detectionLabel
            
            Spacer().frame(height: 16)
            
            // Stats Row
            if viewModel.isScanning {
                statsRow
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer().frame(height: 12)
            
            // Waveform
            if viewModel.isScanning && viewModel.signalProcessor.isCalibrated {
                WaveformView(readings: viewModel.readingHistory)
                    .frame(height: 70)
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            Spacer()
            
            // Controls
            controlsSection
                .padding(.bottom, 30)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }
    
    // MARK: - Detection Label
    
    private var detectionLabel: some View {
        VStack(spacing: 6) {
            Text(viewModel.statusMessage)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(colorForLevel(viewModel.signalProcessor.detectionLevel))
                .contentTransition(.numericText())
            
            if viewModel.signalProcessor.isCalibrated && viewModel.isScanning {
                Text("\(viewModel.signalProcessor.delta, specifier: "%.1f") µT")
                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        }
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "clock.fill",
                label: L10n.time,
                value: viewModel.formattedDuration
            )
            
            StatCard(
                icon: "waveform.badge.magnifyingglass",
                label: L10n.baseline,
                value: String(format: "%.0f µT", viewModel.signalProcessor.baseline)
            )
            
            StatCard(
                icon: "arrow.up.to.line",
                label: L10n.peak,
                value: String(format: "%.1f µT", viewModel.peakStrength)
            )
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Controls
    
    private var controlsSection: some View {
        HStack(spacing: 24) {
            if viewModel.isScanning {
                SecondaryButton(
                    icon: "arrow.counterclockwise",
                    label: L10n.calibrate
                ) {
                    viewModel.recalibrate()
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            ScanButton(isScanning: viewModel.isScanning) {
                viewModel.toggleScanning()
            }
            
            if viewModel.isScanning {
                SecondaryButton(
                    icon: viewModel.feedbackManager.isAudioEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                    label: viewModel.feedbackManager.isAudioEnabled ? L10n.sound : L10n.muted
                ) {
                    viewModel.feedbackManager.isAudioEnabled.toggle()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func colorForLevel(_ level: SignalProcessor.DetectionLevel) -> Color {
        switch level {
        case .none: return .gray
        case .weak: return Color("signalGreen")
        case .moderate: return Color("signalYellow")
        case .strong: return Color("signalOrange")
        case .veryStrong: return Color("signalRed")
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
