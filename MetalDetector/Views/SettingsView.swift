import SwiftUI

/// Settings screen for configuring audio and haptic feedback.
struct SettingsView: View {
    let feedbackManager: FeedbackManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.06, blue: 0.12)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Feedback Section
                        settingsSection(title: L10n.feedback) {
                            SettingsToggle(
                                icon: "speaker.wave.2.fill",
                                title: L10n.audioSignal,
                                subtitle: L10n.audioDescription,
                                isOn: Binding(
                                    get: { feedbackManager.isAudioEnabled },
                                    set: { feedbackManager.isAudioEnabled = $0 }
                                )
                            )
                            
                            Divider().opacity(0.1)
                            
                            SettingsToggle(
                                icon: "hand.tap.fill",
                                title: L10n.hapticFeedback,
                                subtitle: L10n.hapticDescription,
                                isOn: Binding(
                                    get: { feedbackManager.isHapticEnabled },
                                    set: { feedbackManager.isHapticEnabled = $0 }
                                )
                            )
                        }
                        
                        // Info Section
                        settingsSection(title: L10n.aboutApp) {
                            InfoRow(icon: "cpu", title: L10n.sensor, value: L10n.magnetometer)
                            Divider().opacity(0.1)
                            InfoRow(icon: "waveform.path", title: L10n.filter, value: "Low-Pass")
                            Divider().opacity(0.1)
                            InfoRow(icon: "bolt.heart.fill", title: L10n.frequency, value: "60 Hz")
                            Divider().opacity(0.1)
                            InfoRow(icon: "tag.fill", title: "Version", value: AppVersion.display)
                        }
                        
                        // Limitations
                        settingsSection(title: L10n.limitations) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(.init(L10n.limitationText1))
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.6))
                                
                                Text(.init(L10n.limitationText2))
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Version
                        Text(L10n.versionInfo)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.2))
                            .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.done) {
                        dismiss()
                    }
                    .foregroundStyle(.cyan)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
    
    // MARK: - Section Builder
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .textCase(.uppercase)
            
            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
}

// MARK: - Settings Toggle

struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.cyan)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.cyan)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.cyan.opacity(0.6))
                .frame(width: 32, height: 32)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView(feedbackManager: FeedbackManager())
        .preferredColorScheme(.dark)
}
