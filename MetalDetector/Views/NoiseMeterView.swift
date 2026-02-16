import SwiftUI
import AVFoundation

struct NoiseMeterView: View {
    @State private var decibels: Double = 0
    @State private var peakDecibels: Double = 0
    @State private var avgDecibels: Double = 0
    @State private var isRecording = false
    @State private var permissionGranted = false
    @State private var history: [Double] = Array(repeating: 0, count: 60)
    
    // Audio Engine
    private let recorder: AVAudioRecorder
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init() {
        let url = URL(fileURLWithPath: "/dev/null")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.isMeteringEnabled = true
        } catch {
            print("Audio Recorder error: \(error)")
            recorder = try! AVAudioRecorder(url: url, settings: settings) // Fallback
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Title
            VStack(spacing: 4) {
                Text(L10n.soundMeter)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(L10n.decibels)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
            // Permission request or Main UI
            if permissionGranted {
               mainContent
            } else {
                permissionView
            }
        }
        .onAppear {
            checkPermission()
        }
        .onDisappear {
            stopRecording()
        }
        .onReceive(timer) { _ in
            if isRecording {
                updateLevels()
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Gauge / Meter
            ZStack {
                // Background Arc
                Circle()
                    .trim(from: 0.15, to: 0.85)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.green, .yellow, .red]),
                            center: .center,
                            startAngle: .degrees(135),
                            endAngle: .degrees(405)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(90))
                    .opacity(0.3)
                
                // Active Arc
                Circle()
                    .trim(from: 0.15, to: 0.15 + (0.7 * CGFloat(min(decibels, 120) / 120)))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.green, .yellow, .red]),
                            center: .center,
                            startAngle: .degrees(135),
                            endAngle: .degrees(405)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(90))
                    .shadow(color: colorForDb(decibels), radius: 10)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: decibels)
                
                // Value Text
                VStack(spacing: 0) {
                    Text(String(format: "%.1f", decibels))
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    
                    Text("dB")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text(statusText)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(colorForDb(decibels))
                        .padding(.top, 8)
                        .id(statusText) // Force transition
                        .transition(.opacity.combined(with: .scale))
                }
            }
            
            // Stats
            HStack(spacing: 20) {
                StatCard(icon: "waveform", label: L10n.avg, value: String(format: "%.1f", avgDecibels))
                StatCard(icon: "arrow.up.to.line", label: L10n.max, value: String(format: "%.1f", peakDecibels))
            }
            .padding(.horizontal, 24)
            
            // Waveform Graph
            HStack(spacing: 2) {
                ForEach(0..<history.count, id: \.self) { i in
                    let height = CGFloat(history[i]) / 120.0 * 60.0
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForDb(history[i]).opacity(0.6))
                        .frame(height: max(2, height))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .frame(height: 60)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Control Button
            Button {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.title2)
                    Text(isRecording ? L10n.stop : L10n.start)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(width: 160, height: 56)
                .background(isRecording ? Color.red : Color.cyan)
                .clipShape(Capsule())
                .shadow(color: (isRecording ? Color.red : Color.cyan).opacity(0.4), radius: 10)
            }
            .padding(.bottom, 40)
        }
    }
    
    private var permissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text(L10n.microphone)
                .font(.title3)
            Button("Allow Microphone Access") {
                requestPermission()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Logic
    
    private func checkPermission() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            permissionGranted = true
            startRecording()
        case .denied:
            permissionGranted = false
        case .undetermined:
            requestPermission()
        @unknown default:
            break
        }
    }
    
    private func requestPermission() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.permissionGranted = granted
                if granted { startRecording() }
            }
        }
    }
    
    private func startRecording() {
        guard permissionGranted else { return }
        
        // Configure Session
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            recorder.record()
            isRecording = true
            // Reset stats
            peakDecibels = 0
            avgDecibels = 0
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    private func stopRecording() {
        recorder.stop()
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func updateLevels() {
        recorder.updateMeters()
        
        // Convert dBFS (-160 to 0) to approx SPL (0 to 120)
        // dBFS 0 is max volume. -160 is silence.
        // Usually microphone sensitivity offset is around +100 to +110 depending on device.
        let power = Double(recorder.averagePower(forChannel: 0))
        let offset: Double = 100 
        let spl = max(0, power + offset)
        
        self.decibels = spl
        if spl > peakDecibels { peakDecibels = spl }
        
        // Simple moving average
        if avgDecibels == 0 { avgDecibels = spl }
        else { avgDecibels = 0.95 * avgDecibels + 0.05 * spl }
        
        // Update history
        history.removeFirst()
        history.append(spl)
    }
    
    // MARK: - Helpers
    
    private func colorForDb(_ db: Double) -> Color {
        if db < 50 { return .green }
        if db < 80 { return .yellow }
        if db < 100 { return .orange }
        return .red
    }
    
    private var statusText: String {
        if decibels < 40 { return L10n.quiet }
        if decibels < 75 { return L10n.moderateNoise }
        if decibels < 95 { return L10n.loud }
        return L10n.veryLoud
    }
}

#Preview {
    NoiseMeterView()
        .preferredColorScheme(.dark)
}
