import SwiftUI

struct SessionPlayerView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataService = DataService.shared

    let session: Session

    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var totalTime: Double = 0
    @State private var timer: Timer?
    @State private var showCompleteAlert = false
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Video area (placeholder)
                ZStack {
                    heroGradient
                        .frame(height: 300)

                    // Glow effect
                    Circle()
                        .fill(FLEKKSGradients.tealGlowIntense)
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .scaleEffect(isGlowing ? 1.1 : 1.0)
                        .opacity(isGlowing ? 0.8 : 0.5)

                    VStack(spacing: 16) {
                        Text(iconForFocusArea(session.focusArea))
                            .font(.system(size: 80))
                            .scaleEffect(isGlowing ? 1.05 : 1.0)

                        if session.videoUrl == nil {
                            Text("Video Coming Soon")
                                .font(FLEKKSFonts.bodyMedium(14))
                                .foregroundColor(.textMuted)
                        }
                    }

                    // Close button
                    VStack {
                        HStack {
                            Button(action: { appState.endSession() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            Spacer()

                            // Session progress
                            Text("Day \(session.dayNumber)")
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Capsule())
                        }
                        .padding()
                        Spacer()
                    }
                }

                // Session info
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.title)
                            .font(FLEKKSFonts.heading(24))
                            .foregroundColor(.textPrimary)

                        Text(session.focusArea)
                            .font(FLEKKSFonts.body(14))
                            .foregroundColor(.textSecondary)
                    }

                    // Progress bar
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.bgElevated)
                                    .frame(height: 6)

                                RoundedRectangle(cornerRadius: 3)
                                    .fill(FLEKKSGradients.accentGradientVibrant)
                                    .frame(width: geometry.size.width * (currentTime / max(totalTime, 1)), height: 6)
                            }
                        }
                        .frame(height: 6)

                        HStack {
                            Text(formatTime(currentTime))
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)
                            Spacer()
                            Text(formatTime(totalTime))
                                .font(FLEKKSFonts.labelMedium)
                                .foregroundColor(.textMuted)
                        }
                    }

                    // Playback controls
                    HStack(spacing: 32) {
                        Button(action: { currentTime = max(0, currentTime - 15) }) {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 28))
                                .foregroundColor(.textSecondary)
                        }

                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 72))
                                .foregroundStyle(FLEKKSGradients.accentGradient)
                        }

                        Button(action: { currentTime = min(totalTime, currentTime + 15) }) {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 28))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)

                    // Current move indicator
                    CurrentMoveCard()

                    Spacer()

                    // Complete session button
                    Button(action: { showCompleteAlert = true }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Mark Complete")
                        }
                        .font(FLEKKSFonts.bodySemibold(16))
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(24)
            }
        }
        .onAppear {
            totalTime = Double(session.durationMinutes * 60)
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("Complete Session?", isPresented: $showCompleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Complete") {
                completeSession()
            }
        } message: {
            Text("Mark this session as complete and record your progress.")
        }
    }

    private var heroGradient: LinearGradient {
        if let team = appState.selectedTeam {
            switch team.heroGradient {
            case .green: return FLEKKSGradients.heroGreen
            case .purple: return FLEKKSGradients.heroPurple
            case .blue: return FLEKKSGradients.heroBlue
            }
        }
        return FLEKKSGradients.heroGreen
    }

    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if currentTime < totalTime {
                    currentTime += 1
                } else {
                    timer?.invalidate()
                    isPlaying = false
                    showCompleteAlert = true
                }
            }
        } else {
            timer?.invalidate()
        }
    }

    private func completeSession() {
        timer?.invalidate()
        Task {
            try? await dataService.markSessionComplete(
                session: session,
                durationSeconds: Int(currentTime)
            )
            appState.incrementStreak()
            appState.endSession()
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func iconForFocusArea(_ area: String) -> String {
        switch area.lowercased() {
        case let a where a.contains("hip"): return "🦵"
        case let a where a.contains("back") || a.contains("spine"): return "🧘"
        case let a where a.contains("core"): return "💪"
        case let a where a.contains("shoulder"): return "🙆"
        case let a where a.contains("hamstring"): return "🏃"
        case let a where a.contains("pike"): return "🤸"
        case let a where a.contains("glute"): return "🍑"
        case let a where a.contains("assessment"): return "📋"
        default: return "✨"
        }
    }
}

// MARK: - Current Move Card
struct CurrentMoveCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CURRENT MOVE")
                .font(FLEKKSFonts.labelSmall)
                .foregroundStyle(FLEKKSGradients.accentGradient)
                .tracking(1.5)

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.bgElevated)
                        .frame(width: 56, height: 56)
                    Text("🦵")
                        .font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("90/90 Hip Stretch")
                        .font(FLEKKSFonts.bodySemibold(16))
                        .foregroundColor(.textPrimary)
                    Text("Hold for 45 seconds each side")
                        .font(FLEKKSFonts.body(13))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Text("0:45")
                    .font(FLEKKSFonts.headingHeavy(24))
                    .foregroundStyle(FLEKKSGradients.accentGradient)
            }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(FLEKKSGradients.borderGradientSubtle, lineWidth: 1)
            )
        }
    }
}

#Preview {
    SessionPlayerView(session: Session.lowBackSessions[0])
        .environmentObject(AppState())
}
